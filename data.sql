-- =========================
-- PROFIL PENGGUNA (SATU-SATUNYA KE AUTH)
-- =========================
create table profil_pengguna (
  id uuid primary key references auth.users(id) on delete cascade,
  nama_lengkap varchar not null,
  peran varchar not null check (peran in ('admin', 'petugas', 'peminjam')),
  dibuat_pada timestamptz default now()
);

-- =========================
-- KATEGORI ALAT
-- =========================
create table kategori_alat (
  id bigserial primary key,
  kode varchar unique not null,
  nama varchar not null,
  dibuat_pada timestamptz default now()
);

-- =========================
-- ALAT
-- =========================
create table alat (
  id bigserial primary key,
  nama varchar not null,
  kategori_id bigint references kategori_alat(id),
  kondisi varchar not null check (kondisi in ('baik', 'rusak_ringan', 'rusak_berat')),
  status varchar not null check (status in ('tersedia', 'dipinjam', 'tidak_layak')),
  url_gambar text,
  dibuat_pada timestamptz default now()
);

-- =========================
-- PEMINJAMAN
-- =========================
create table peminjaman (
  id bigserial primary key,
  peminjam_id uuid references profil_pengguna(id),
  disetujui_oleh uuid references profil_pengguna(id),
  tanggal_pinjam timestamptz not null,
  tanggal_jatuh_tempo timestamptz not null,
  tanggal_kembali timestamptz,
  status varchar not null check (
    status in ('menunggu', 'disetujui', 'ditolak', 'dikembalikan')
  ),
  hari_terlambat int default 0,
  alasan text,
  dibuat_pada timestamptz default now()
);

-- =========================
-- DETAIL PEMINJAMAN
-- =========================
create table detail_peminjaman (
  id bigserial primary key,
  peminjaman_id bigint references peminjaman(id) on delete cascade,
  alat_id bigint references alat(id),
  kondisi_saat_pinjam varchar,
  kondisi_saat_kembali varchar,
  dibuat_pada timestamptz default now()
);

-- =========================
-- ATURAN DENDA
-- =========================
create table aturan_denda (
  id bigserial primary key,
  jenis varchar not null check (jenis in ('terlambat', 'rusak', 'hilang')),
  jumlah numeric not null,
  keterangan text
);

-- =========================
-- DENDA
-- =========================
create table denda (
  id bigserial primary key,
  peminjaman_id bigint references peminjaman(id) on delete cascade,
  aturan_denda_id bigint references aturan_denda(id),
  jumlah numeric not null,
  dibuat_pada timestamptz default now()
);

-- =========================
-- LOG AKTIVITAS
-- =========================
create table log_aktivitas (
  id bigserial primary key,
  pengguna_id uuid references profil_pengguna(id),
  aksi varchar not null,
  entitas varchar not null,
  entitas_id bigint,
  nilai_lama jsonb,
  nilai_baru jsonb,
  dibuat_pada timestamptz default now()
);


-- 2.
-- =========================
-- SETUJUI PEMINJAMAN
-- =========================
create or replace procedure setujui_peminjaman(
  p_peminjaman_id bigint,
  p_petugas_id uuid
)
language plpgsql
as $$
begin
  update peminjaman
  set status = 'disetujui',
      disetujui_oleh = p_petugas_id
  where id = p_peminjaman_id;

  update alat
  set status = 'dipinjam'
  where id in (
    select alat_id
    from detail_peminjaman
    where peminjaman_id = p_peminjaman_id
  );
end;
$$;

create or replace function approve_peminjaman(p_peminjaman_id int)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update peminjaman
  set status = 'dipinjam',
      disetujui_pada = now()
  where id = p_peminjaman_id;
end;
$$;


create or replace function approve_peminjaman(
  p_peminjaman_id int
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  -- validasi: hanya petugas yang boleh approve
  if not exists (
    select 1
    from profil_pengguna
    where id = auth.uid()
      and peran = 'petugas'
  ) then
    raise exception 'Hanya petugas yang boleh menyetujui peminjaman';
  end if;

  update peminjaman
  set
    status = 'dipinjam',
    disetujui_oleh = auth.uid(),
    disetujui_pada = now(),
    diperbarui_pada = now()
  where id = p_peminjaman_id
    and status = 'menunggu';

  if not found then
    raise exception 'Peminjaman tidak ditemukan atau status bukan menunggu';
  end if;
end;
$$;


-- =========================
-- PENGEMBALIAN PEMINJAMAN
-- =========================
create or replace procedure pengembalian_peminjaman(
  p_peminjaman_id bigint
)
language plpgsql
as $$
begin
  update peminjaman
  set status = 'dikembalikan',
      tanggal_kembali = now()
  where id = p_peminjaman_id;

  update alat
  set status = 'tersedia'
  where id in (
    select alat_id
    from detail_peminjaman
    where peminjaman_id = p_peminjaman_id
  );
end;
$$;

--baru
create or replace function proses_pengembalian(
  p_peminjaman_id int,
  p_kondisi_kembali text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  -- validasi hanya petugas
  if not exists (
    select 1
    from profil_pengguna
    where id = auth.uid()
      and peran = 'petugas'
  ) then
    raise exception 'Hanya petugas yang boleh memproses pengembalian';
  end if;

  update peminjaman
  set
    status = 'dikembalikan',
    dikembalikan_pada = now(),
    dikembalikan_oleh = auth.uid(),
    kondisi_kembali = p_kondisi_kembali,
    diperbarui_pada = now()
  where id = p_peminjaman_id
    and status = 'dipinjam';

  if not found then
    raise exception 'Peminjaman tidak ditemukan atau status bukan dipinjam';
  end if;
end;
$$;


-- 3.fungsi
create or replace function hitung_hari_terlambat(
  p_jatuh_tempo timestamptz,
  p_tanggal_kembali timestamptz
)
returns int
language plpgsql
as $$
begin
  if p_tanggal_kembali <= p_jatuh_tempo then
    return 0;
  end if;

  return extract(day from p_tanggal_kembali - p_jatuh_tempo);
end;
$$;

-- 4.treger
-- =====================================================
-- TRIGGER & FUNCTION TRIGGER
-- SISTEM PEMINJAMAN ALAT TATA BUSANA
-- =====================================================


-- =====================================================
-- 1. TRIGGER SIGNUP USER
-- Otomatis membuat data profil_pengguna setelah signup
-- =====================================================

create or replace function handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  v_peran text;
begin
  -- Ambil peran dari metadata user
  v_peran := new.raw_user_meta_data->>'peran';

  -- Validasi peran (hindari error CHECK constraint)
  if v_peran not in ('admin', 'petugas', 'peminjam') then
    v_peran := 'peminjam';
  end if;

  -- Insert data ke tabel profil_pengguna
  insert into profil_pengguna (id, nama_lengkap, peran)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'nama_lengkap', 'Pengguna'),
    v_peran
  );

  return new;
end;
$$;


drop trigger if exists on_auth_user_created on auth.users;

create trigger on_auth_user_created
after insert on auth.users
for each row
execute function handle_new_user();


-- =====================================================
-- 2. TRIGGER HITUNG KETERLAMBATAN PEMINJAMAN
-- Menghitung hari terlambat saat pengembalian
-- =====================================================

create or replace function trg_hitung_keterlambatan()
returns trigger
language plpgsql
as $$
begin
  if new.tanggal_kembali is not null then
    new.hari_terlambat :=
      hitung_hari_terlambat(
        new.tanggal_jatuh_tempo,
        new.tanggal_kembali
      );
  end if;

  return new;
end;
$$;


drop trigger if exists hitung_keterlambatan on peminjaman;

create trigger hitung_keterlambatan
before update on peminjaman
for each row
execute function trg_hitung_keterlambatan();


-- =====================================================
-- 3. TRIGGER LOG AKTIVITAS
-- Mencatat aktivitas insert, update, delete peminjaman
-- =====================================================

-- Pastikan kolom pengguna_id boleh NULL
alter table log_aktivitas
alter column pengguna_id drop not null;


create or replace function trg_log_aktivitas()
returns trigger
language plpgsql
security definer
as $$
declare
  v_user_id uuid;
begin
  -- auth.uid() bisa NULL jika tidak ada session (AMAN)
  v_user_id := auth.uid();

  insert into log_aktivitas (
    pengguna_id,
    aksi,
    entitas,
    entitas_id,
    nilai_lama,
    nilai_baru
  )
  values (
    v_user_id,
    TG_OP,
    TG_TABLE_NAME,
    coalesce(new.id, old.id),
    to_jsonb(old),
    to_jsonb(new)
  );

  return coalesce(new, old);
end;
$$;


drop trigger if exists log_peminjaman on peminjaman;

create trigger log_peminjaman
after insert or update or delete
on peminjaman
for each row
execute function trg_log_aktivitas();

-- TRIGGER PENGAMAN (ANTI SPOOFING)

create or replace function trg_force_peminjam_login()
returns trigger
language plpgsql
as $$
begin
  new.peminjam_id := auth.uid();
  return new;
end;
$$;

create trigger force_peminjam_login
before insert on peminjaman
for each row
execute function trg_force_peminjam_login();



-- 5.seen data
-- =====================================
-- SEED DATA KATEGORI ALAT TATA BUSANA
-- =====================================
insert into kategori_alat (kode, nama) values
('MESIN', 'Mesin Jahit'),
('POTONG', 'Alat Potong'),
('UKUR', 'Alat Ukur'),
('SETRIKA', 'Alat Setrika'),
('BAHAN', 'Perlengkapan Menjahit');

-- =====================================
-- SEED DATA ALAT PRAKTIK TATA BUSANA
-- =====================================
insert into alat (nama, kategori_id, kondisi, status, url_gambar) values
-- Mesin Jahit
('Mesin Jahit High Speed', 1, 'baik', 'tersedia', null),
('Mesin Obras', 1, 'baik', 'tersedia', null),
('Mesin Jahit Portable', 1, 'baik', 'tersedia', null),

-- Alat Potong
('Gunting Kain Besar', 2, 'baik', 'tersedia', null),
('Gunting Benang', 2, 'baik', 'tersedia', null),
('Cutter Kain', 2, 'baik', 'tersedia', null),

-- Alat Ukur
('Meteran Jahit', 3, 'baik', 'tersedia', null),
('Penggaris Pola 60 cm', 3, 'baik', 'tersedia', null),
('Penggaris Lengkung', 3, 'baik', 'tersedia', null),

-- Alat Setrika
('Setrika Uap', 4, 'baik', 'tersedia', null),
('Setrika Listrik', 4, 'baik', 'tersedia', null),

-- Perlengkapan Menjahit
('Manekin Jahit', 5, 'baik', 'tersedia', null),
('Jarum Jahit Set', 5, 'baik', 'tersedia', null),
('Benang Jahit Warna', 5, 'baik', 'tersedia', null),
('Pendedel Jahitan', 5, 'baik', 'tersedia', null),
('Pita Pola', 5, 'baik', 'tersedia', null);


-- ==========================================================================

-- isis data dumy

insert into kategori_alat (kode, nama) values
('MESIN', 'Mesin Jahit'),
('POTONG', 'Alat Potong'),
('UKUR', 'Alat Ukur'),
('SETRIKA', 'Alat Setrika'),
('BAHAN', 'Perlengkapan Menjahit');

insert into alat (nama, kategori_id, kondisi, status) values
-- Mesin Jahit
('Mesin Jahit High Speed', 1, 'baik', 'tersedia'),
('Mesin Obras', 1, 'baik', 'tersedia'),

-- Alat Potong
('Gunting Kain Besar', 2, 'baik', 'tersedia'),
('Gunting Benang', 2, 'baik', 'tersedia'),

-- Alat Ukur
('Meteran Jahit', 3, 'baik', 'tersedia'),
('Penggaris Pola', 3, 'baik', 'tersedia'),

-- Setrika
('Setrika Uap', 4, 'baik', 'tersedia'),

-- Perlengkapan
('Manekin Jahit', 5, 'baik', 'tersedia'),
('Jarum Jahit', 5, 'baik', 'tersedia');

insert into aturan_denda (jenis, jumlah, keterangan) values
('terlambat', 5000, 'Denda per hari keterlambatan'),
('rusak', 50000, 'Kerusakan alat'),
('hilang', 200000, 'Alat hilang');

insert into aturan_denda (jenis, jumlah, keterangan) values
('terlambat', 5000, 'Denda per hari keterlambatan'),
('rusak', 50000, 'Kerusakan alat'),
('hilang', 200000, 'Alat hilang');

insert into peminjaman (
  peminjam_id,
  tanggal_pinjam,
  tanggal_jatuh_tempo,
  status,
  alasan
) values (
  'd1addca8-eb64-424c-a603-c6e5deedce70',
  now() - interval '2 days',
  now() + interval '3 days',
  'menunggu',
  'Praktikum membuat rok'
);

insert into detail_peminjaman (
  peminjaman_id,
  alat_id,
  kondisi_saat_pinjam
) values
(1, 1, 'baik'), -- Mesin Jahit
(1, 3, 'baik'), -- Gunting Kain
(1, 5, 'baik'); -- Meteran

insert into peminjaman (
  peminjam_id,
  disetujui_oleh,
  tanggal_pinjam,
  tanggal_jatuh_tempo,
  status,
  alasan
) values (
  'd1addca8-eb64-424c-a603-c6e5deedce70',
  '34990c67-d931-4518-9bf2-edecf6ad8177',
  now() - interval '7 days',
  now() - interval '3 days',
  'disetujui',
  'Praktik menjahit blus'
);

insert into detail_peminjaman (peminjaman_id, alat_id, kondisi_saat_pinjam) values
(2, 2, 'baik'), -- Mesin Obras
(2, 4, 'baik'); -- Gunting Benang

update peminjaman
set tanggal_kembali = now()
where id = 2;

insert into denda (
  peminjaman_id,
  aturan_denda_id,
  jumlah
) values (
  2,
  1,
  15000 -- 3 hari x 5000
);




-- rls
alter table peminjaman enable row level security;

create policy "peminjam hanya bisa insert miliknya"
on peminjaman
for insert
with check (auth.uid() = peminjam_id);

create policy "peminjam hanya lihat miliknya"
on peminjaman
for select
using (auth.uid() = peminjam_id);


create policy "petugas bisa lihat semua pengajuan"
on peminjaman
for select
using (
  exists (
    select 1
    from profil_pengguna
    where id = auth.uid()
    and peran = 'petugas'
  )
);


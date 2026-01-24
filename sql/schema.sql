-- =====================================================
-- SCHEMA / STRUCTURE
-- =====================================================

-- =========================
-- PROFIL PENGGUNA
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

-- =========================
-- ROW LEVEL SECURITY (RLS)
-- =========================
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

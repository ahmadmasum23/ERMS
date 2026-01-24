-- =====================================================
-- TRIGGERS
-- =====================================================

-- =========================
-- TRIGGER SIGNUP USER
-- =========================
create or replace function handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  v_peran text;
begin
  v_peran := new.raw_user_meta_data->>'peran';

  if v_peran not in ('admin', 'petugas', 'peminjam') then
    v_peran := 'peminjam';
  end if;

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

-- =========================
-- TRIGGER HITUNG KETERLAMBATAN
-- =========================
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

-- =========================
-- TRIGGER LOG AKTIVITAS
-- =========================
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

-- =========================
-- TRIGGER PENGAMAN (ANTI SPOOFING)
-- =========================
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

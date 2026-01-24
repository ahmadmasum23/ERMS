-- =====================================================
-- FUNCTIONS
-- =====================================================

-- =========================
-- APPROVE PEMINJAMAN (VALIDASI PETUGAS)
-- =========================
create or replace function approve_peminjaman(
  p_peminjaman_id int
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
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
-- PROSES PENGEMBALIAN (VALIDASI PETUGAS)
-- =========================
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

-- =========================
-- HITUNG HARI TERLAMBAT
-- =========================
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

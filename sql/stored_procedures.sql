-- =====================================================
-- STORED PROCEDURES
-- =====================================================

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

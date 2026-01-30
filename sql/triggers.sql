CREATE OR REPLACE FUNCTION public.log_activity_fn()
RETURNS trigger AS $$
DECLARE
  entity_id bigint;
BEGIN
  -- Handle different ID types based on table
  IF TG_TABLE_NAME = 'profil_pengguna' THEN
    -- For profil_pengguna, don't store the UUID in entitas_id (bigint column)
    entity_id := NULL;
  ELSE
    -- For other tables, cast the ID to bigint
    entity_id := COALESCE(NEW.id, OLD.id)::bigint;
  END IF;

  INSERT INTO public.log_aktivitas (
    pengguna_id,
    aksi,
    entitas,
    entitas_id,
    nilai_lama,
    nilai_baru
  )
  VALUES (
    auth.uid(),              -- user yang login
    TG_OP,                   -- INSERT / UPDATE / DELETE
    TG_TABLE_NAME,           -- nama tabel
    entity_id,
    to_jsonb(OLD),
    to_jsonb(NEW)
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER log_peminjaman
AFTER INSERT OR UPDATE OR DELETE ON public.peminjaman
FOR EACH ROW EXECUTE FUNCTION public.log_activity_fn();

CREATE TRIGGER log_detail_peminjaman
AFTER INSERT OR UPDATE OR DELETE ON public.detail_peminjaman
FOR EACH ROW EXECUTE FUNCTION public.log_activity_fn();

CREATE TRIGGER log_alat
AFTER INSERT OR UPDATE OR DELETE ON public.alat
FOR EACH ROW EXECUTE FUNCTION public.log_activity_fn();

CREATE TRIGGER log_profil_pengguna
AFTER INSERT OR UPDATE OR DELETE ON public.profil_pengguna
FOR EACH ROW EXECUTE FUNCTION public.log_activity_fn();

CREATE OR REPLACE FUNCTION public.kurangi_stok_alat()
RETURNS trigger AS $$
BEGIN
  UPDATE public.alat
  SET stok = stok - 1,
      status = CASE WHEN stok - 1 = 0 THEN 'dipinjam' ELSE status END
  WHERE id = NEW.alat_id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_kurangi_stok
AFTER INSERT ON public.detail_peminjaman
FOR EACH ROW EXECUTE FUNCTION public.kurangi_stok_alat();

CREATE OR REPLACE FUNCTION public.tambah_stok_alat()
RETURNS trigger AS $$
BEGIN
  IF NEW.kondisi_saat_kembali IS NOT NULL THEN
    UPDATE public.alat
    SET stok = stok + 1,
        status = 'tersedia'
    WHERE id = NEW.alat_id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_tambah_stok
AFTER UPDATE ON public.detail_peminjaman
FOR EACH ROW
WHEN (OLD.kondisi_saat_kembali IS NULL AND NEW.kondisi_saat_kembali IS NOT NULL)
EXECUTE FUNCTION public.tambah_stok_alat();

CREATE OR REPLACE FUNCTION public.hitung_keterlambatan()
RETURNS trigger AS $$
BEGIN
  IF NEW.tanggal_kembali IS NOT NULL THEN
    NEW.hari_terlambat :=
      GREATEST(0, DATE_PART('day', NEW.tanggal_kembali - NEW.tanggal_jatuh_tempo));
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_hitung_telat
BEFORE UPDATE ON public.peminjaman
FOR EACH ROW EXECUTE FUNCTION public.hitung_keterlambatan();


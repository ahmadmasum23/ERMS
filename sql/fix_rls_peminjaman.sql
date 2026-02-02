-- Fix RLS policies for peminjaman table
-- This should be run in your Supabase SQL editor

-- First, let's check existing policies
-- SELECT * FROM pg_policy WHERE polrelid = 'peminjaman'::regclass;

-- Drop existing conflicting policies
DROP POLICY IF EXISTS "peminjam hanya lihat miliknya" ON peminjaman;
DROP POLICY IF EXISTS "petugas bisa lihat semua pengajuan" ON peminjaman;

-- Create proper policies for peminjam (borrower)
CREATE POLICY "peminjam bisa lihat pengajuan sendiri" 
ON peminjaman 
FOR SELECT 
USING (
  auth.uid() = peminjam_id
  OR EXISTS (
    SELECT 1 FROM profil_pengguna 
    WHERE id = auth.uid() AND peran = 'petugas'
  )
  OR EXISTS (
    SELECT 1 FROM profil_pengguna 
    WHERE id = auth.uid() AND peran = 'admin'
  )
);

-- Create policy for petugas (staff) to see all records
CREATE POLICY "petugas bisa lihat semua peminjaman" 
ON peminjaman 
FOR SELECT 
USING (
  EXISTS (
    SELECT 1 FROM profil_pengguna 
    WHERE id = auth.uid() AND peran IN ('petugas', 'admin')
  )
);

-- Ensure the table has RLS enabled
ALTER TABLE peminjaman ENABLE ROW LEVEL SECURITY;

-- Grant necessary permissions
GRANT SELECT ON peminjaman TO authenticated;
GRANT INSERT ON peminjaman TO authenticated;
GRANT UPDATE ON peminjaman TO authenticated;
-- ============================================
-- SCHEMA: profiles table
-- ============================================
-- Update schema untuk menambahkan date_of_birth dan phone
-- ============================================

-- ALTER TABLE untuk menambahkan kolom baru (jika table sudah ada)
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS date_of_birth DATE,
ADD COLUMN IF NOT EXISTS phone TEXT;

-- ============================================
-- ATAU jika membuat table baru:
-- ============================================

CREATE TABLE IF NOT EXISTS public.profiles (
  id uuid NOT NULL,
  username text NOT NULL,
  email text,
  hobby text,
  bio text,
  avatar_url text,
  date_of_birth date,
  phone text,
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT profiles_pkey PRIMARY KEY (id),
  CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);

-- ============================================
-- CATATAN:
-- ============================================
-- 1. date_of_birth: tipe DATE untuk menyimpan tanggal lahir
-- 2. phone: tipe TEXT untuk menyimpan nomor telepon
-- 3. Kedua field ini nullable (optional)
-- ============================================


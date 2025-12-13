-- ============================================
-- TRIGGER: create_profile_on_signup
-- ============================================
-- Trigger ini akan otomatis membuat profile baru
-- ketika user baru melakukan signup di auth.users
-- ============================================

-- 1. Buat Function
CREATE OR REPLACE FUNCTION public.create_profile_on_signup()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  INSERT INTO public.profiles (
    id,
    username,
    email,
    hobby,
    bio,
    avatar_url,
    date_of_birth,
    phone,
    updated_at
  )
  VALUES (
    NEW.id,
    -- Username: ambil dari metadata, atau dari email
    COALESCE(
      NEW.raw_user_meta_data->>'username',
      NEW.raw_user_meta_data->>'full_name',
      SPLIT_PART(NEW.email, '@', 1)
    ),
    NEW.email,
    -- hobby dan bio default NULL (optional fields)
    NULL,
    NULL,
    -- Avatar URL: ambil dari Google jika ada
    NEW.raw_user_meta_data->>'avatar_url',
    -- date_of_birth dan phone default NULL (optional fields)
    NULL,
    NULL,
    NOW()
  );
  RETURN NEW;
END;
$$;

-- 2. Buat Trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.create_profile_on_signup();

-- ============================================
-- CATATAN:
-- ============================================
-- 1. Function ini akan otomatis dipanggil saat user baru signup
-- 2. Username akan diambil dari:
--    - raw_user_meta_data->>'username' (jika ada)
--    - raw_user_meta_data->>'full_name' (jika username tidak ada)
--    - SPLIT_PART(email, '@', 1) (fallback: ambil dari email)
-- 3. hobby dan bio akan NULL (bisa diisi nanti di profile screen)
-- 4. avatar_url akan diambil dari Google jika signup via OAuth
-- 5. date_of_birth dan phone akan NULL (bisa diisi nanti di profile screen)
-- 6. updated_at otomatis diisi dengan timestamp sekarang
-- ============================================


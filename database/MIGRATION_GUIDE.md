# Migration Guide: Menambahkan date_of_birth dan phone

## Langkah-langkah Update Database

### 1. Update Schema Database

Jalankan SQL berikut di Supabase SQL Editor:

```sql
-- Tambahkan kolom baru ke tabel profiles
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS date_of_birth DATE,
ADD COLUMN IF NOT EXISTS phone TEXT;
```

**ATAU** jika ingin membuat table baru, gunakan file `schema_profiles.sql`

### 2. Update Trigger

Jalankan file `trigger_create_profile_on_signup.sql` yang sudah diupdate untuk include field baru.

## File yang Sudah Diupdate

### ✅ Database Files:
1. **`database/schema_profiles.sql`** - Schema dengan field baru
2. **`database/trigger_create_profile_on_signup.sql`** - Trigger sudah diupdate

### ✅ Flutter Files:
1. **`lib/models/profile_model.dart`** - Model sudah include `dateOfBirth` dan `phone`
2. **`lib/services/supabase_service.dart`** - Method `updateProfile()` sudah support field baru
3. **`lib/screens/home/profile_screen.dart`** - UI sudah load dan save field baru

## Testing

Setelah update database:

1. **Test Load Profile:**
   - Buka profile screen
   - Pastikan date of birth dan phone muncul jika sudah diisi

2. **Test Save Profile:**
   - Edit profile
   - Isi date of birth dan phone
   - Klik "Save Changes"
   - Pastikan data tersimpan

3. **Test New User Signup:**
   - Signup user baru
   - Cek di database bahwa profile dibuat dengan `date_of_birth` dan `phone` = NULL

## Catatan Penting

- `date_of_birth` menggunakan tipe **DATE** di PostgreSQL
- `phone` menggunakan tipe **TEXT** (bisa menyimpan format apapun: +62, dll)
- Kedua field ini **nullable** (optional)
- Format date yang dikirim ke database: **YYYY-MM-DD** (contoh: 1995-05-16)

## Rollback (Jika Perlu)

Jika ingin menghapus field:

```sql
ALTER TABLE public.profiles 
DROP COLUMN IF EXISTS date_of_birth,
DROP COLUMN IF EXISTS phone;
```

**PERINGATAN:** Hapus field hanya jika yakin, karena akan kehilangan data!


# Database Setup

## Trigger: create_profile_on_signup

Trigger ini otomatis membuat record di tabel `profiles` ketika user baru melakukan signup.

### Cara Install di Supabase:

1. Buka Supabase Dashboard
2. Pergi ke **SQL Editor**
3. Copy-paste isi file `trigger_create_profile_on_signup.sql`
4. Klik **Run** untuk menjalankan SQL

### Schema yang Dibutuhkan:

```sql
CREATE TABLE public.profiles (
  id uuid NOT NULL,
  username text NOT NULL,
  email text,
  hobby text,
  bio text,
  avatar_url text,
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT profiles_pkey PRIMARY KEY (id),
  CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);
```

### Cara Kerja:

1. **Saat User Signup** (via email/password atau OAuth):
   - Trigger `on_auth_user_created` otomatis dipanggil
   - Function `create_profile_on_signup()` dijalankan
   - Record baru dibuat di tabel `profiles`

2. **Field yang Diisi Otomatis**:
   - `id`: dari `auth.users.id`
   - `username`: dari metadata atau email
   - `email`: dari `auth.users.email`
   - `avatar_url`: dari Google OAuth (jika signup via Google)
   - `updated_at`: timestamp sekarang
   - `hobby`: NULL (bisa diisi nanti)
   - `bio`: NULL (bisa diisi nanti)

3. **Prioritas Username**:
   - `raw_user_meta_data->>'username'` (jika ada)
   - `raw_user_meta_data->>'full_name'` (jika username tidak ada)
   - `SPLIT_PART(email, '@', 1)` (fallback: ambil dari email)

### Testing:

Setelah trigger diinstall, coba:
1. Signup user baru via email/password
2. Signup user baru via Google OAuth
3. Cek tabel `profiles` - seharusnya ada record baru

### Troubleshooting:

Jika trigger tidak jalan:
1. Pastikan function dan trigger sudah dibuat (cek di SQL Editor)
2. Pastikan RLS (Row Level Security) di tabel `profiles` sudah dikonfigurasi
3. Pastikan user memiliki permission untuk insert ke tabel `profiles`


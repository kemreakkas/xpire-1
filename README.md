# Xpire

Xpire, hedef tamamladıkça XP kazanıp seviye atladığınız **offline-first** (Hive) bir hedef takip uygulamasının MVP sürümüdür.

## Tech stack

- Flutter (stable)
- Riverpod
- Supabase (auth + database, cloud-first)
- Hive (local cache only)
- GoRouter
- Material 3 (dark default)

## Kurulum

```bash
flutter pub get
flutter analyze
```

## Çalıştırma

- Android/iOS (cihaz/emülatör):

```bash
flutter run
```

- Web (Chrome):

```bash
flutter run -d chrome
```

## Build (Release)

- Web:

```bash
flutter build web --release
```

Çıktı klasörü: `build/web`

- Android App Bundle:

```bash
flutter build appbundle --release
```

- iOS (macOS gerekli):

```bash
flutter build ios --release
```

## App icon (launcher icon)

Kaynak dosya: `assets/icon.png`

İkon üretimi:

```bash
flutter pub run flutter_launcher_icons
```

## Splash screen notu (placeholder)

Henüz splash üretilmiyor. İleride `flutter_native_splash` eklenerek kolayca üretilebilir.

## build_runner notu

Şu an codegen kullanılmıyor (Hive adapter’ları manuel). İleride eklenecekse:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Deploy readiness (MVP)

Before going live, ensure:

- **Auth:** Login/register and auth state work with Supabase (see Supabase section below).
- **RLS:** Run both migration files so Row Level Security is enabled on all tables.
- **Premium:** No hardcoded premium bypass; free limits (e.g. 3 goals) and premium features are enforced via `PremiumController` and profile `isPremiumEffective`.
- **Layout:** Responsive layout works on web (e.g. `ResponsiveCenter`, `maxWidth: 820`).
- **Builds:** Android and web release builds compile (see below).

---

## How to deploy web

1. Configure Supabase (see **How to configure Supabase** below).
2. Build: `flutter build web --release` (with `--dart-define=SUPABASE_URL=...` and `--dart-define=SUPABASE_ANON_KEY=...` for production).
3. Deploy the `build/web` folder to a static host:
   - **Firebase Hosting:** `firebase deploy` (after `firebase init hosting`, set `public` to `build/web`)
   - **Netlify / Vercel:** Connect repo and set build output to `build/web`, or upload the folder (see **Vercel** below).
   - **GitHub Pages:** Push `build/web` to `gh-pages` or use Actions; set base-href if needed: `flutter build web --release --base-href "/xpire/"`

### Vercel (production)

1. **Project:** Import the repo in Vercel; root directory = repo root.
2. **Build & Output:**
   - **Build Command:**  
     `flutter build web --release --dart-define=SUPABASE_URL=$SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY`
   - **Output Directory:** `build/web`
3. **Environment variables:** In Vercel project → Settings → Environment Variables, add:
   - `SUPABASE_URL` = your Supabase project URL
   - `SUPABASE_ANON_KEY` = your Supabase anon/public key
4. **SPA routing:** `vercel.json` already includes rewrites so unknown routes serve `index.html` (path-based routing works).
5. **Supabase auth (web):** In Supabase Dashboard → Authentication → URL Configuration, set **Site URL** to your Vercel production URL (e.g. `https://your-app.vercel.app`) and add the same URL to **Redirect URLs** so login and email confirmation work in production.

---

## How to build Android

1. Install Android SDK and accept licenses.
2. (Optional) Set env for Supabase: `--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`
3. Build APK: `flutter build apk --release`
4. Build App Bundle (for Play Store): `flutter build appbundle --release`

Outputs: `build/app/outputs/flutter-apk/app-release.apk` and `build/app/outputs/bundle/release/app-release.aab`.

---

## How to configure Supabase

1. Create a project at [supabase.com](https://supabase.com).
2. In **Project Settings → API**, copy **Project URL** and **anon public** key.
3. Run migrations in **SQL Editor** (in order):
   - `supabase/migrations/20250117000000_initial_schema.sql`
   - `supabase/migrations/20250117000001_rls.sql`
   - `supabase/migrations/20250217000000_challenge_progress_fields.sql`
4. Enable **Email** auth in **Authentication → Providers** if needed.
5. Run the app with keys:
   ```bash
   flutter run --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_ANON_KEY=your-anon-key
   ```
   Or use `env.example` and your CI/env to pass the same values.

---

## Web deploy (notlar)

`flutter build web --release` sonrası `build/web` klasörünü host edin.

Opsiyonlar:
- Firebase Hosting
- Netlify
- Vercel
- GitHub Pages (base-href ayarı gerekebilir)

## Konfigürasyon

Basit env bilgileri: `lib/core/config/app_env.dart` (flavor desteği sonraki fazda genişletilecek).

## Supabase (SaaS)

Auth ve veri Supabase üzerinden yönetilir. Yapılandırma yoksa uygulama yalnızca yerel Hive ile çalışır (giriş ekranı atlanır).

### Ortam değişkenleri

`env.example` dosyasını referans alın. Çalıştırırken:

```bash
flutter run --dart-define=SUPABASE_URL=https://PROJECT.supabase.co --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

### Veritabanı şeması

`supabase/migrations/` içindeki SQL dosyalarını Supabase SQL Editor’da sırayla çalıştırın:

1. `20250117000000_initial_schema.sql` — tablolar (users, goals, completions, challenge_progress)
2. `20250117000001_rls.sql` — Row Level Security politikaları
3. `20250217000000_challenge_progress_fields.sql` — challenge engine alanları (current_day, failed_at, goal_ids)

### Akış

- Giriş yoksa: Login / Register ekranı
- Giriş sonrası: Profil ve veriler Supabase’den çekilir, Hive’a önbelleklenir
- Değişiklikler: Önce Supabase’e yazılır, sonra yerel önbellek güncellenir
- Premium: `users.subscription_status` (free | active | canceled) sunucu otoritesi için kullanılır

## Premium Integration

Premium, `in_app_purchase` paketi ile entegre edilmiştir. Şu an **mock product ID** kullanılıyor; gerçek mağaza yapılandırması için aşağıdaki adımlar gerekir.

### Product ID’ler

- `lib/core/constants/premium_constants.dart` içinde tanımlı:
  - `xpire_premium_monthly` (aylık)
  - `xpire_premium_yearly` (yıllık)

### Mağaza tarafı

- **App Store Connect:** In-App Purchases bölümünde aynı ID’lerle non-consumable veya subscription ürünleri oluşturun.
- **Google Play Console:** Monetize → Products → In-app products bölümünde aynı ID’lerle ürünleri tanımlayın.

Gerçek yayında **backend doğrulama** (receipt / token doğrulama) eklenmelidir; şu an istemci tarafında satın alma durumu kabul edilip profil `isPremium` olarak güncellenmektedir.

### Web

Web’de satın alma devre dışıdır; kullanıcıya “Premium purchases available on mobile only” mesajı gösterilir. Geliştirme modunda (release değilken) “Dev: Enable Premium” ile test için premium açılabilir.

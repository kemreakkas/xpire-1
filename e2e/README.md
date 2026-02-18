# Xpire E2E Tests (Playwright)

Tarayıcı tabanlı uçtan uca testler. Flutter web build’i üzerinde çalışır.

## Gereksinimler

- Node.js 18+
- Flutter web build: `flutter build web --release` (proje kökünden)

**Not:** Varsayılan build CanvasKit kullanır; metin canvas’ta çizildiği için testler yalnızca URL ve sayfa yüklenmesini doğrular. Metin/buton bazlı testler için HTML renderer ile build alın:  
`flutter build web --release --web-renderer html`

## Kurulum

```bash
cd e2e
npm install
npx playwright install
```

## Çalıştırma

1. Önce web build alın (proje kökünde):
   ```bash
   flutter build web --release
   ```

2. Testleri çalıştırın:
   ```bash
   cd e2e
   npm test
   ```

Playwright otomatik olarak `build/web` klasörünü 8080 portunda sunar ve testleri çalıştırır.

## Diğer komutlar

- `npm run test:ui` — Playwright UI ile testleri çalıştırır
- `npm run test:headed` — Tarayıcı penceresi açık test

## Testler

- **app.spec.ts**: Uygulama yükleme, login/register sayfaları, URL yönlendirme, sidebar navigasyon (web geniş görünüm), SPA refresh (404 olmamalı).

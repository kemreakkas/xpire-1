# Xpire — Deploy Öncesi Kontrol Listesi

Deploy etmeden önce aşağıdaki maddeleri doğrulayın.

---

## 1️⃣ 40 Template

| Kontrol | Durum | Not |
|--------|--------|-----|
| Statik liste kodda var mı? | ✅ | `lib/data/content/default_goal_templates.dart` — 40 şablon (8 kategori × 5) |
| UI'dan seçilebiliyor mu? | ✅ | `GoalCreatePage` → "Use Template" sekmesi, kategori filtresi, şablon listesi |
| DB'ye yazılıyor mu? | ✅ | Şablon seçilip kaydedilince **Goal** olarak `SupabaseGoalRepository.upsert` + Hive cache |

**Doğrulama:** Yeni hedef oluştur → "Use Template" → bir şablon seç → Kaydet → Goals listesinde görünmeli, Supabase `goals` tablosunda satır oluşmalı.

---

## 2️⃣ 12 Challenge

| Kontrol | Durum | Not |
|--------|--------|-----|
| Default challenge listesi var mı? | ✅ | `lib/data/content/default_challenges.dart` — 12 challenge tanımlı |
| Dashboard'da listeleniyor mu? | ✅ | Aktif challenge yokken "Recommended challenges" (ilk 3), "Start a Challenge" CTA |
| Başlatılabiliyor mu? | ✅ | Challenge detay sayfasında "Start challenge" → `ChallengeEngine.startChallenge()` |
| ChallengeEngine bağlı mı? | ✅ | Supabase açıkken `challengeEngineProvider` kullanılıyor; başlatma ve günlük ilerleme engine üzerinden |

**Doğrulama:** Dashboard → Start a Challenge → bir challenge seç → Start → Aktif challenge kartı ve oluşan hedefler görünmeli.

---

## 3️⃣ Challenge Engine

| Kontrol | Durum | Not |
|--------|--------|-----|
| Gün atlama kontrolü var mı? | ✅ | `ChallengeEngine.checkDaySkipped()` — beklenen gün tamamlanmamışsa `failedAt` set edilir |
| Day completion tetikleniyor mu? | ✅ | `GoalActionsController.completeGoal()` sonrası `engine.recordDayCompleted()` çağrılıyor |
| Fail logic var mı? | ✅ | `checkDaySkipped` → `today.isAfter(expectedDay) && completedDays < currentDay` → `failedAt` + analytics `challenge_failed` |
| Bonus XP ekleniyor mu? | ✅ | `recordDayCompleted` içinde `currentDay > durationDays` → `xpService.grantBonusXp`, `isCompleted = true`, analytics `challenge_completed` |

**Doğrulama:** Aktif challenge ile bir hedefi tamamla → progress güncellenmeli; tüm günleri tamamla → bonus XP ve "Challenge completed" görünmeli. Bir gün atla → challenge failed.

---

## 4️⃣ Supabase

| Kontrol | Durum | Not |
|--------|--------|-----|
| RLS aktif mi? | ✅ | `supabase/migrations/20250117000001_rls.sql` — users, goals, completions, challenge_progress |
| user_id doğru bağlanıyor mu? | ✅ | Tüm repository'ler `_client.auth.currentUser?.id` ile yazıyor |
| Test kullanıcı ile veri yazılabiliyor mu? | Manuel | Supabase Dashboard → Table Editor ile kontrol edin |
| Web'de auth redirect çalışıyor mu? | ✅ | `GoRouter` redirect: giriş yoksa `/login`, giriş varsa auth sayfalarından `/dashboard` |

**Doğrulama:** Web'de çalıştır → Login/Register → Dashboard'da veri oluştur → Supabase Dashboard'da ilgili tablolarda `user_id` ile satırlar görünmeli.

**Migration sırası:**  
1) `20250117000000_initial_schema.sql`  
2) `20250117000001_rls.sql`  
3) `20250217000000_challenge_progress_fields.sql` (current_day, failed_at, goal_ids)

---

## 5️⃣ Analytics

| Event | Bağlı mı? | Nerede |
|-------|-----------|--------|
| user_registered | ✅ | `RegisterPage` — kayıt başarılı sonrası |
| goal_created | ✅ | `GoalCreatePage._saveGoal` — hedef kaydedildikten sonra |
| goal_completed | ✅ | `GoalActionsController.completeGoal` |
| challenge_started | ✅ | `ChallengeDetailPage._startChallenge` (Supabase + Hive path) |
| challenge_day_completed | ✅ | `GoalActionsController` — challenge hedefi tamamlanınca gün ilerlemesi |
| challenge_failed | ✅ | `ChallengeEngine.checkDaySkipped` |
| challenge_completed | ✅ | `ChallengeEngine.recordDayCompleted` (tüm günler tamamlanınca) + `ChallengeDetailPage._claimBonus` (Hive path) |
| premium_clicked | ✅ | `PremiumPage` — Buy butonları |

**Not:** Analytics şu an `DefaultAnalyticsService` ile debug log; Firebase/PostHog için implementasyon değiştirilebilir.

---

## 6️⃣ Production Readiness

| Kontrol | Durum | Not |
|--------|--------|-----|
| Android release build | Manuel | `flutter build appbundle --release` — CI veya lokal deneyin |
| Web release build | Manuel | `flutter build web --release` — `build/web` çıktısı |
| Responsive layout (desktop) | ✅ | `ResponsiveCenter`, `maxWidth: 820` (Dashboard vb.) |
| Crash handling | ✅ | `main.dart` — `FlutterError.onError` + `runZonedGuarded` ile log |

**Komutlar:**
- Web: `flutter build web --release`
- Android: `flutter build appbundle --release` veya `flutter build apk --release`

---

## Hızlı Test Akışı

1. Supabase URL + anon key ile çalıştır.
2. Yeni hesap oluştur → `user_registered` (log).
3. "Use Template" ile hedef oluştur → `goal_created`; Supabase `goals` tablosunda satır.
4. Bir challenge başlat → `challenge_started`; dashboard'da aktif challenge kartı.
5. Challenge hedeflerinden birini tamamla → `goal_completed`, `challenge_day_completed`; progress güncellenir.
6. Challenge'ı bitir veya bir gün atla → bonus XP veya fail; `challenge_completed` / `challenge_failed`.

Tüm maddeler ✅ ise deploy için hazırsınız.

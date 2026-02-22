// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Xpire';

  @override
  String get signIn => 'Giriş yap';

  @override
  String get createAccount => 'Hesap oluştur';

  @override
  String get dontHaveAccount => 'Hesabınız yok mu? ';

  @override
  String get email => 'E-posta';

  @override
  String get emailHint => 'ornek@email.com';

  @override
  String get password => 'Şifre';

  @override
  String get confirmPassword => 'Şifre tekrar';

  @override
  String get enterEmail => 'E-postanızı girin';

  @override
  String get enterValidEmail => 'Geçerli bir e-posta girin';

  @override
  String get enterPassword => 'Şifrenizi girin';

  @override
  String get atLeast6Chars => 'En az 6 karakter';

  @override
  String get passwordsDoNotMatch => 'Şifreler eşleşmiyor';

  @override
  String get alreadyHaveAccount => 'Zaten hesabınız var mı? Giriş yap';

  @override
  String get supabaseNotConfigured =>
      'Supabase yapılandırılmadı. SUPABASE_URL ve SUPABASE_ANON_KEY ayarlayın.';

  @override
  String get authError => 'Kimlik doğrulama hatası';

  @override
  String get dashboard => 'Xpire';

  @override
  String get stats => 'İstatistikler';

  @override
  String get profile => 'Profil';

  @override
  String get level => 'Seviye';

  @override
  String get totalXp => 'Toplam XP';

  @override
  String get streak => 'Seri';

  @override
  String get premium => 'Premium';

  @override
  String get premiumActive => 'Aktif';

  @override
  String get premiumNotActive => 'Aktif değil';

  @override
  String get upgradeToPremium => 'Premium\'a geç';

  @override
  String get signOut => 'Çıkış yap';

  @override
  String get yourInfo => 'Bilgileriniz';

  @override
  String get fullName => 'Ad soyad';

  @override
  String get username => 'Kullanıcı adı';

  @override
  String get age => 'Yaş';

  @override
  String get occupation => 'Meslek';

  @override
  String get focusCategory => 'Odak kategorisi';

  @override
  String get optional => 'İsteğe bağlı';

  @override
  String get none => 'Yok';

  @override
  String get saveProfile => 'Profili kaydet';

  @override
  String get profileSaved => 'Profil kaydedildi';

  @override
  String get newGoal => 'Yeni hedef';

  @override
  String get createCustom => 'Özel oluştur';

  @override
  String get useTemplate => 'Önerilenleri kullan';

  @override
  String get title => 'Başlık';

  @override
  String get category => 'Kategori';

  @override
  String get difficulty => 'Zorluk';

  @override
  String get enterTitle => 'Bir başlık girin';

  @override
  String get keepLonger => 'Biraz daha uzun yazın';

  @override
  String get save => 'Kaydet';

  @override
  String get all => 'Tümü';

  @override
  String fromTemplate(String title) {
    return 'Önerilen: $title';
  }

  @override
  String get daily => 'Günlük';

  @override
  String get onceADay => 'Günde 1 kez';

  @override
  String get weekly => 'Haftalık';

  @override
  String get challenges => 'Rutinler';

  @override
  String get challengesIntro =>
      'Yapılandırılmış rutinlerle alışkanlık edinin. Tüm hedefleri tamamlayarak bonus XP kazanın.';

  @override
  String get challengesEmpty =>
      'Şu an rutin bulunmuyor. Başlamak için panelden hedef oluşturabilirsiniz.';

  @override
  String get challengesEmptyTitle => 'Henüz rutin yok';

  @override
  String get challengesNoActiveTitle => 'Henüz Aktif Rutin Yok';

  @override
  String get challengesNoActiveSubtitle =>
      'Bonus XP kazanmaya başlamak için ilk 7 günlük rutininize başlayın.';

  @override
  String get challengesNoActiveSubtitleShort =>
      'İlk 7 günlük rutininize başlayın.';

  @override
  String get browseChallenges => 'Rutinlere Göz At';

  @override
  String get activeChallengesSection => 'Aktif Rutinler';

  @override
  String get myActiveChallengesSection => 'Aktif Rutinlerim';

  @override
  String get communityChallengesSection => 'Topluluk Rutinleri';

  @override
  String get startNewChallengeSection => 'Yeni Rutin Başlat';

  @override
  String get scrollToTemplates => 'Önerilenlere git';

  @override
  String participantsCount(int count) {
    return '$count katılımcı';
  }

  @override
  String get joinChallenge => 'Katıl';

  @override
  String get joined => 'Katıldın';

  @override
  String get createChallenge => 'Rutin Oluştur';

  @override
  String get challengeCreated => 'Rutin oluşturuldu.';

  @override
  String get quitChallenge => 'Rutinden vazgeç';

  @override
  String get quitChallengeConfirm =>
      'Bu rutinden vazgeçmek istediğinize emin misiniz?';

  @override
  String get yes => 'Evet';

  @override
  String get no => 'Hayır';

  @override
  String get challengeDescription => 'Açıklama';

  @override
  String get challengeDescriptionHint => 'Rutin hakkında kısa açıklama';

  @override
  String get enterDescription => 'Bir açıklama girin';

  @override
  String get durationDays => 'Süre (gün)';

  @override
  String get rewardXp => 'Ödül XP';

  @override
  String get dailyChallengeLimitReached =>
      'Günlük rutin oluşturma limitine ulaştınız (günde 2).';

  @override
  String get dailyLimitTooltip => 'Günlük limit doldu. Yarın tekrar deneyin.';

  @override
  String get startChallengeButton => 'Rutini Başlat';

  @override
  String get challengesLoadError =>
      'Rutinler yüklenemedi. Tekrar denemek için çekin.';

  @override
  String daysBonusXp(int days, int xp) {
    return '$days gün · $xp bonus XP';
  }

  @override
  String get activeGoals => 'Aktif hedefler';

  @override
  String get todaysSuggestedGoals => 'Bugünün Önerilen Hedefleri';

  @override
  String get todaysAIPlan => 'Bugünün AI Planı';

  @override
  String get reminderBannerMessage =>
      'Bugünkü hedeflerinizi henüz tamamlamadınız.';

  @override
  String get dailyReminders => 'Günlük hatırlatmalar';

  @override
  String get enableDailyReminder => 'Günlük hatırlatmayı aç';

  @override
  String get reminderTime => 'Hatırlatma saati';

  @override
  String get recommendedChallenges => 'Önerilen rutinler';

  @override
  String get recommendedGoals => 'Önerilen hedefler';

  @override
  String get startChallenge => 'Hedef başlat';

  @override
  String dayProgress(int current, int total) {
    return 'Gün $current / $total';
  }

  @override
  String bonusXp(int xp) {
    return 'Bonus: +$xp XP';
  }

  @override
  String daysLeft(int count) {
    return '$count gün kaldı';
  }

  @override
  String daysCompleted(int count) {
    return '$count gün tamamlandı';
  }

  @override
  String get complete => 'Tamamla';

  @override
  String get done => 'Tamamlandı';

  @override
  String get noActiveGoals =>
      'Henüz aktif hedef yok.\nİlk hedefinizi oluşturmak için + dokunun.';

  @override
  String get noActiveGoalsTitle => 'Henüz hedef yok';

  @override
  String get noActiveGoalsDescription =>
      'XP kazanmak ve seri oluşturmak için ilk hedefinizi ekleyin.';

  @override
  String get freeGoalLimitReached =>
      'Ücretsiz limit: En fazla 10 aktif hedef ekleyebilirsiniz.';

  @override
  String get goalsCompleted => 'Tamamlanan hedef';

  @override
  String get currentStreak => 'Mevcut seri';

  @override
  String get completedToday => 'Bugün tamamlanan';

  @override
  String get daysSuffix => ' gün';

  @override
  String get premiumFeature => 'Premium özellik';

  @override
  String get advancedStatsDesc =>
      'Haftalık ortalama, en verimli kategori, 30 günlük trend';

  @override
  String get upgrade => 'Yükselt';

  @override
  String get premiumPageTitle => 'Premium';

  @override
  String get unlockPotential => 'Potansiyelinizi açığa çıkarın';

  @override
  String get youHavePremium => 'Premium üyeliğiniz var';

  @override
  String get premiumActivated => 'Premium etkinleştirildi';

  @override
  String get somethingWentWrong => 'Bir şeyler yanlış gitti';

  @override
  String get invalidEmailPassword => 'Geçersiz e-posta veya şifre.';

  @override
  String get confirmEmailFirst => 'Giriş yapmadan önce e-postanızı onaylayın.';

  @override
  String get emailAlreadyRegistered => 'Bu e-posta zaten kayıtlı.';

  @override
  String get passwordMinLength => 'Şifre en az 6 karakter olmalıdır.';

  @override
  String get passwordTooWeak => 'Şifre çok zayıf. En az 6 karakter kullanın.';

  @override
  String get tooManyAttempts =>
      'Çok fazla deneme. Birkaç dakika sonra tekrar deneyin.';

  @override
  String get tryAgain => 'Bir şeyler yanlış gitti. Tekrar deneyin.';

  @override
  String get min6Chars => 'En az 6 karakter';

  @override
  String levelLabel(int level) {
    return 'Seviye $level';
  }

  @override
  String get levelUpTitle => 'Seviye atladın!';

  @override
  String levelUpMessage(int level) {
    return 'Seviye $level oldun. Devam et!';
  }

  @override
  String dailyXpAvailable(int xp) {
    return 'Bugün alınabilecek XP: $xp';
  }

  @override
  String get completedTodayCount => 'Bugün tamamlanan';

  @override
  String get todayAlreadyCompleted => 'Bugün zaten tamamlandı.';

  @override
  String get goalNotFound => 'Hedef bulunamadı.';

  @override
  String get fitness => 'Fitness';

  @override
  String get study => 'Çalışma';

  @override
  String get work => 'İş';

  @override
  String get focus => 'Odak';

  @override
  String get mind => 'Zihin';

  @override
  String get health => 'Sağlık';

  @override
  String get finance => 'Finans';

  @override
  String get selfGrowth => 'Kişisel gelişim';

  @override
  String get general => 'Genel';

  @override
  String get digitalDetox => 'Dijital Detoks';

  @override
  String get social => 'Sosyal';

  @override
  String get creativity => 'Yaratıcılık';

  @override
  String get discipline => 'Disiplin';

  @override
  String get easy => 'Kolay';

  @override
  String get medium => 'Orta';

  @override
  String get hard => 'Zor';

  @override
  String get easyXp => 'Kolay (10 XP)';

  @override
  String get mediumXp => 'Orta (25 XP)';

  @override
  String get hardXp => 'Zor (50 XP)';

  @override
  String get language => 'Dil';

  @override
  String get english => 'English';

  @override
  String get turkish => 'Türkçe';

  @override
  String get systemDefault => 'Sistem varsayılanı';

  @override
  String xpEarned(int xp) {
    return '+$xp XP';
  }

  @override
  String xpEarnedLevelUp(int xp, int level) {
    return '+$xp XP — Seviye atladın! (Sev. $level)';
  }

  @override
  String get activeChallenge => 'Aktif rutin';

  @override
  String get challengesCompleted => 'Tamamlanan rutinler';

  @override
  String get completionsByCategory => 'Kategoriye göre tamamlamalar';

  @override
  String get advancedStats => 'Gelişmiş istatistikler';

  @override
  String get weeklyXp => 'Haftalık XP';

  @override
  String get mostProductiveCategory => 'En verimli kategori';

  @override
  String get last30Days => 'Son 30 gün';

  @override
  String get challengeNotFound => 'Rutin bulunamadı';

  @override
  String get goalsInThisChallenge => 'Bu rutindeki hedefler';

  @override
  String get challengeCompleted => 'Rutin tamamlandı!';

  @override
  String bonusXpAddedWhenFinished(int xp) {
    return 'Bitirdiğinizde +$xp XP eklendi.';
  }

  @override
  String get youAreDoingThisChallenge => 'Bu rutini yapıyorsunuz';

  @override
  String get alreadyHaveActiveChallenge => 'Zaten aktif bir rutininiz var.';

  @override
  String challengeStartedMessage(String title, int xp) {
    return '$title başlatıldı! Günde 1 hedef tamamlayarak $xp bonus XP kazanın.';
  }

  @override
  String challengeStartedMessageOffline(String title, int xp) {
    return '$title başlatıldı! Hedefleri tamamlayarak $xp bonus XP kazanın.';
  }

  @override
  String get claimBonus => 'Bonusu al';

  @override
  String claimBonusXp(int xp) {
    return '$xp bonus XP al';
  }

  @override
  String bonusXpClaimed(int xp) {
    return '+$xp bonus XP alındı!';
  }

  @override
  String progressPercent(String percent) {
    return 'İlerleme: %$percent';
  }

  @override
  String daysCount(int count) {
    return '$count gün';
  }

  @override
  String bonusXpLabel(int xp) {
    return '$xp bonus XP';
  }

  @override
  String get benefits => 'Avantajlar';

  @override
  String get unlimitedGoals => 'Sınırsız hedef';

  @override
  String get streakProtection => 'Seri koruması';

  @override
  String get premiumPurchasesMobileOnly =>
      'Premium satın alma yalnızca mobilde kullanılabilir.';

  @override
  String get devPremiumEnabled => 'Geliştirici: Premium etkinleştirildi';

  @override
  String get devEnablePremium => 'Geliştirici: Premium\'u etkinleştir';

  @override
  String get restorePurchases => 'Satın almaları geri yükle';

  @override
  String get restoreRequested => 'Geri yükleme isteği gönderildi';

  @override
  String get monthly => 'Aylık';

  @override
  String get yearly => 'Yıllık';

  @override
  String get buy => 'Satın al';

  @override
  String get unknownRoutingError => 'Bilinmeyen yönlendirme hatası';

  @override
  String get leaderboard => 'Liderlik Tablosu';

  @override
  String get challengeLeaderboard => 'Mücadele Liderliği';

  @override
  String get weeklyLeaderboard => 'Haftalık Liderlik';

  @override
  String get yourRank => 'Sıralaman';

  @override
  String get completedDaysLabel => 'Gün';

  @override
  String get noLeaderboardYet => 'Henüz kayıt yok';

  @override
  String get rankLabel => 'Sıra';

  @override
  String xpCount(Object count) {
    return '$count XP';
  }
}

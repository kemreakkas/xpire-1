/// Mock product IDs for premium. Replace with real IDs when configuring
/// App Store / Play Console.
abstract final class PremiumConstants {
  static const String premiumMonthly = 'xpire_premium_monthly';
  static const String premiumWeekly = 'xpire_premium_weekly';

  // Consumables (Tüketilebilir Tek Seferlik Mağaza Ürünleri)
  static const String freezePack3 = 'xpire_freeze_pack_3';
  static const String xpPack500 = 'xpire_xp_pack_500';

  static const List<String> productIds = [
    premiumMonthly,
    premiumWeekly,
    freezePack3,
    xpPack500,
  ];
}

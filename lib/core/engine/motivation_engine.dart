import 'dart:math';

import 'user_profile_analyzer.dart';

final _rng = Random();

/// 50 rule-based motivation messages in 5 groups. No external API.
class MotivationEngine {
  MotivationEngine._();

  static const List<String> _lowEnergy = [
    "Küçük adımlar da sayılır. Bugün minik bir galibiyet elde et.",
    "Mükemmel olmak zorunda değilsin. Sadece elinden geleni yap.",
    "Dinlenmek de planın bir parçası. Hafif bir çaba bile seni ileri taşır.",
    "Enerjin düşük mü? Sadece bir şey seç ve onu başar.",
    "Bugün kendine nazik davran. Tek bir hedef yeterli.",
    "Bugünkü en iyi performansın farklı görünebilir. Bu sorun değil.",
    "5 dakikalık bir ilerleme bile bir ilerlemedir.",
    "Kendine iyi davran. Yarın yepyeni bir gün.",
    "Küçük bir adım atmak, hiç atmamaktan iyidir. Bunu yapabilirsin.",
    "Gerekiyorsa durakla. Sonra bir adım daha at.",
  ];

  static const List<String> _highEnergy = [
    "Harika gidiyorsun. Bu enerjiyi büyük bir başarıya dönüştür.",
    "Enerjik bir gün! İki veya üç galibiyeti üst üste diz.",
    "Rüzgarı arkana aldın. Bunu bilinçli bir şekilde kullan.",
    "Bugün sınırlarını biraz daha zorlama günü.",
    "Serin, bunu yapabileceğini kanıtlıyor. Git ve al.",
    "Bu enerjiyi akıllıca kullan. Odaklanmış tek bir adım.",
    "Bir şeyler inşa ediyorsun. Ritmi koru.",
    "Güçlü günler birikerek büyür. Bugünü değerli kıl.",
    "Arzun var. Bunu net bir hedefe yönelt.",
    "Enerji bir hediyedir. Onu önemli şeyler için harca.",
  ];

  static const List<String> _streakBoost = [
    "Serin, ne kadar istikrarlı olduğunun kanıtıdır. Devam et.",
    "Yeni bir gün, yeni bir galibiyet. Seriyi koru.",
    "Buraya kadar durmak için gelmedin.",
    "Bu seriyi sen inşa ettin, kendiliğinden olmadı.",
    "Bir gün daha. Ne yapman gerektiğini biliyorsun.",
    "Bu seri kararlı olduğunu gösteriyor. Bugün de kendini göster.",
    "İstikrar yoğunluğu yener. Bunu tam şu an yaşıyorsun.",
    "Zinciri kırma. Bugün yalnızca tek bir hedef.",
    "Bu seri senin başarın. Onu gururla taşı.",
    "Vazgeçmediğin her gün daha da güçleniyorsun.",
  ];

  static const List<String> _comebackMode = [
    "Bugün yeniden birinci gün. Bu tamamen normal.",
    "Her büyük geri dönüş sağlam bir adımla başlar.",
    "Serin mi bozuldu? Hiç sorun değil. Bugün taze bir başlangıç yap.",
    "Başlamak için en iyi zaman dündü. İkinci en iyi zaman ise şu an.",
    "Bugün için tek bir hedef. Geri dönüşün bu olacak.",
    "Sıfırdan değil, biriktirdiğin tecrübelerle başlıyorsun.",
    "Geri dönüş modu: Önce bir galibiyet al, ardından devamını getir.",
    "Bugün nasıl olacağını dün belirlemez. Harekete geç.",
    "Sıfırla ve yeniden başla. Küçük bir başarı bile önemlidir.",
    "Bir sonraki büyük serin bugünden itibaren başlıyor.",
  ];

  static const List<String> _consistencyReward = [
    "Sürekli çaba gösteriyorsun. Asıl zafer işte budur.",
    "İstikrar senin süper gücün. Onu en iyi şekilde kullanıyorsun.",
    "İstikrarlı ilerleme her zaman kazanır. Doğru yoldasın.",
    "Alışkanlıkların kökleşiyor. Ritmini asla bozma.",
    "Küçük adımlarla geçen bir gün daha. Asıl gelişim böyle olur.",
    "Kendine olan inancını her gün bir adım daha büyütüyorsun.",
    "Çoğu insan yarı yolda bırakır. Fakat sen hâlâ buradasın.",
    "Düzenli çabanın ne kadar işe yaradığının canlı kanıtısın.",
    "Gösterişli olmasa da kararlısın. Bu senin gücün.",
    "Motoru sıcak tut. Bugün gerçekten çok önemli.",
  ];

  /// Picks a message based on [profile] and [streak]. Uses streak_boost when
  /// streak > 5, comeback_mode when streak == 0, low_energy when energy is low.
  static String generateMotivation(SmartProfile smartProfile, int streak) {
    final group = _selectGroup(smartProfile, streak);
    final list = _messagesForGroup(group);
    return list[_rng.nextInt(list.length)];
  }

  static MotivationGroup _selectGroup(SmartProfile profile, int streak) {
    if (streak > 5) return MotivationGroup.streakBoost;
    if (streak == 0) return MotivationGroup.comebackMode;
    if (profile.energyLevel == EnergyLevel.low) {
      return MotivationGroup.lowEnergy;
    }
    if (profile.energyLevel == EnergyLevel.high) {
      return MotivationGroup.highEnergy;
    }
    return MotivationGroup.consistencyReward;
  }

  static List<String> _messagesForGroup(MotivationGroup g) {
    return switch (g) {
      MotivationGroup.lowEnergy => _lowEnergy,
      MotivationGroup.highEnergy => _highEnergy,
      MotivationGroup.streakBoost => _streakBoost,
      MotivationGroup.comebackMode => _comebackMode,
      MotivationGroup.consistencyReward => _consistencyReward,
    };
  }
}

enum MotivationGroup {
  lowEnergy,
  highEnergy,
  streakBoost,
  comebackMode,
  consistencyReward,
}

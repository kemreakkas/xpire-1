/// Simple profanity filter for Turkish and English content.
/// Checks usernames and text fields for inappropriate words.
class ProfanityFilter {
  ProfanityFilter._();

  /// Turkish profanity / slang words (lowercase).
  static const _turkishWords = <String>{
    'amk',
    'aq',
    'amına',
    'amina',
    'orospu',
    'piç',
    'pic',
    'siktir',
    'siktirgit',
    'sikerim',
    'sikeyim',
    'yarrak',
    'yarak',
    'göt',
    'got',
    'meme',
    'pezevenk',
    'kahpe',
    'ibne',
    'gerizekalı',
    'gerizekali',
    'mal',
    'salak',
    'aptal',
    'dangalak',
    'hıyar',
    'hiyar',
    'züppе',
    'gavat',
    'oç',
    'oc',
    'mk',
    'sg',
    'ananı',
    'anani',
    'bacını',
    'bacini',
    'sik',
    'am',
    'taşak',
    'tasak',
    'döl',
    'dol',
    'yavşak',
    'yavsak',
    'puşt',
    'pust',
    'sürtük',
    'surtuk',
    'kaltak',
    'fahişe',
    'fahise',
    'kevaşe',
    'kevase',
    'manyak',
    'dingil',
    'kodumun',
    'hassiktir',
    'amcık',
    'amcik',
    'dalyarak',
    'dallama',
    'andaval',
    'bok',
    'boktan',
    's2m',
    's2k',
    'skim',
    'skm',
    'ananın',
    'ananin',
  };

  /// English profanity words (lowercase).
  static const _englishWords = <String>{
    'fuck',
    'shit',
    'ass',
    'asshole',
    'bitch',
    'bastard',
    'dick',
    'penis',
    'vagina',
    'whore',
    'slut',
    'cunt',
    'nigger',
    'nigga',
    'faggot',
    'fag',
    'retard',
    'damn',
    'piss',
    'cock',
    'pussy',
    'motherfucker',
    'bullshit',
    'wtf',
    'stfu',
  };

  /// All blocked words combined.
  static final _allWords = <String>{..._turkishWords, ..._englishWords};

  /// Returns `true` if the [text] contains profanity.
  static bool containsProfanity(String text) {
    if (text.trim().isEmpty) return false;
    final lower = text.toLowerCase().trim();

    // Exact match (the whole input is a bad word)
    if (_allWords.contains(lower)) return true;

    // Check each word in the text
    // Split on non-alphanumeric (including Turkish chars)
    final words = lower.split(RegExp(r'[^a-zçğıöşüâîû0-9]+'));
    for (final word in words) {
      if (word.isEmpty) continue;
      if (_allWords.contains(word)) return true;
    }

    // Check for leet-speak / number substitutions
    final normalized = lower
        .replaceAll('0', 'o')
        .replaceAll('1', 'i')
        .replaceAll('3', 'e')
        .replaceAll('4', 'a')
        .replaceAll('5', 's')
        .replaceAll('7', 't')
        .replaceAll('@', 'a')
        .replaceAll('\$', 's');

    if (normalized != lower) {
      final normalizedWords = normalized.split(RegExp(r'[^a-zçğıöşüâîû0-9]+'));
      for (final word in normalizedWords) {
        if (word.isEmpty) continue;
        if (_allWords.contains(word)) return true;
      }
    }

    return false;
  }

  /// Returns `null` if clean, or an error message if profanity is detected.
  static String? validate(String? text, {String? errorMessage}) {
    if (text == null || text.trim().isEmpty) return null;
    if (containsProfanity(text)) {
      return errorMessage ?? 'Uygunsuz ifade içeriyor';
    }
    return null;
  }
}

import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/app_localizations.dart';

class ShareService {
  static const String appStoreUrl =
      'https://play.google.com/store/apps/details?id=com.taurusapp.xpire';

  static Future<void> shareGoal(String goalTitle, AppLocalizations l10n) async {
    final String text =
        '${l10n.shareGoalPrefix} "$goalTitle" ${l10n.shareAppSuffix}\n\n$appStoreUrl';
    await Share.share(text);
  }

  static Future<void> shareChallenge(
    String challengeTitle,
    AppLocalizations l10n,
  ) async {
    final String text =
        '${l10n.shareChallengePrefix} "$challengeTitle" ${l10n.shareAppSuffix}\n\n$appStoreUrl';
    await Share.share(text);
  }

  static Future<void> shareApp(AppLocalizations l10n) async {
    final String text = '${l10n.shareAppMessage}\n\n$appStoreUrl';
    await Share.share(text);
  }

  static Future<void> inviteViaWhatsApp(String text) async {
    final String url = 'whatsapp://send?text=${Uri.encodeComponent(text)}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      // Fallback to generic share if WhatsApp not installed
      await Share.share(text);
    }
  }
}

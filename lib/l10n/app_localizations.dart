import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Xpire'**
  String get appTitle;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get emailHint;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get enterValidEmail;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @atLeast6Chars.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get atLeast6Chars;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get alreadyHaveAccount;

  /// No description provided for @supabaseNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Supabase is not configured. Set SUPABASE_URL and SUPABASE_ANON_KEY.'**
  String get supabaseNotConfigured;

  /// No description provided for @authError.
  ///
  /// In en, this message translates to:
  /// **'Auth error'**
  String get authError;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Xpire'**
  String get dashboard;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get stats;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @totalXp.
  ///
  /// In en, this message translates to:
  /// **'Total XP'**
  String get totalXp;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @premiumActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get premiumActive;

  /// No description provided for @premiumNotActive.
  ///
  /// In en, this message translates to:
  /// **'Not active'**
  String get premiumNotActive;

  /// No description provided for @upgradeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremium;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @yourInfo.
  ///
  /// In en, this message translates to:
  /// **'Your info'**
  String get yourInfo;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @occupation.
  ///
  /// In en, this message translates to:
  /// **'Occupation'**
  String get occupation;

  /// No description provided for @focusCategory.
  ///
  /// In en, this message translates to:
  /// **'Focus category'**
  String get focusCategory;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @saveProfile.
  ///
  /// In en, this message translates to:
  /// **'Save profile'**
  String get saveProfile;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get profileSaved;

  /// No description provided for @newGoal.
  ///
  /// In en, this message translates to:
  /// **'New goal'**
  String get newGoal;

  /// No description provided for @createCustom.
  ///
  /// In en, this message translates to:
  /// **'Create Custom'**
  String get createCustom;

  /// No description provided for @useTemplate.
  ///
  /// In en, this message translates to:
  /// **'Use Template'**
  String get useTemplate;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @difficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// No description provided for @enterTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter a title'**
  String get enterTitle;

  /// No description provided for @keepLonger.
  ///
  /// In en, this message translates to:
  /// **'Keep it a bit longer'**
  String get keepLonger;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @fromTemplate.
  ///
  /// In en, this message translates to:
  /// **'From template: {title}'**
  String fromTemplate(String title);

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @challenges.
  ///
  /// In en, this message translates to:
  /// **'Challenges'**
  String get challenges;

  /// No description provided for @challengesIntro.
  ///
  /// In en, this message translates to:
  /// **'Build habits with structured challenges. Complete all goals to earn bonus XP.'**
  String get challengesIntro;

  /// No description provided for @challengesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No challenges right now. Create goals from the dashboard to get started.'**
  String get challengesEmpty;

  /// No description provided for @daysBonusXp.
  ///
  /// In en, this message translates to:
  /// **'{days} days · {xp} bonus XP'**
  String daysBonusXp(int days, int xp);

  /// No description provided for @activeGoals.
  ///
  /// In en, this message translates to:
  /// **'Active goals'**
  String get activeGoals;

  /// No description provided for @recommendedChallenges.
  ///
  /// In en, this message translates to:
  /// **'Recommended challenges'**
  String get recommendedChallenges;

  /// No description provided for @recommendedGoals.
  ///
  /// In en, this message translates to:
  /// **'Recommended goals'**
  String get recommendedGoals;

  /// No description provided for @startChallenge.
  ///
  /// In en, this message translates to:
  /// **'Start a Challenge'**
  String get startChallenge;

  /// No description provided for @dayProgress.
  ///
  /// In en, this message translates to:
  /// **'Day {current} / {total}'**
  String dayProgress(int current, int total);

  /// No description provided for @bonusXp.
  ///
  /// In en, this message translates to:
  /// **'Bonus: +{xp} XP'**
  String bonusXp(int xp);

  /// No description provided for @daysLeft.
  ///
  /// In en, this message translates to:
  /// **'{count} days left'**
  String daysLeft(int count);

  /// No description provided for @daysCompleted.
  ///
  /// In en, this message translates to:
  /// **'{count} days completed'**
  String daysCompleted(int count);

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @noActiveGoals.
  ///
  /// In en, this message translates to:
  /// **'No active goals yet.\nTap + to create your first one.'**
  String get noActiveGoals;

  /// No description provided for @goalsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Goals completed'**
  String get goalsCompleted;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current streak'**
  String get currentStreak;

  /// No description provided for @completedToday.
  ///
  /// In en, this message translates to:
  /// **'Completed today'**
  String get completedToday;

  /// No description provided for @daysSuffix.
  ///
  /// In en, this message translates to:
  /// **' days'**
  String get daysSuffix;

  /// No description provided for @premiumFeature.
  ///
  /// In en, this message translates to:
  /// **'Premium Feature'**
  String get premiumFeature;

  /// No description provided for @advancedStatsDesc.
  ///
  /// In en, this message translates to:
  /// **'Weekly average, most productive category, 30-day trend'**
  String get advancedStatsDesc;

  /// No description provided for @upgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade;

  /// No description provided for @premiumPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premiumPageTitle;

  /// No description provided for @unlockPotential.
  ///
  /// In en, this message translates to:
  /// **'Unlock your full potential'**
  String get unlockPotential;

  /// No description provided for @youHavePremium.
  ///
  /// In en, this message translates to:
  /// **'You have Premium'**
  String get youHavePremium;

  /// No description provided for @premiumActivated.
  ///
  /// In en, this message translates to:
  /// **'Premium activated'**
  String get premiumActivated;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @invalidEmailPassword.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password.'**
  String get invalidEmailPassword;

  /// No description provided for @confirmEmailFirst.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your email before signing in.'**
  String get confirmEmailFirst;

  /// No description provided for @emailAlreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered.'**
  String get emailAlreadyRegistered;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password should be at least 6 characters.'**
  String get passwordMinLength;

  /// No description provided for @passwordTooWeak.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak. Use at least 6 characters.'**
  String get passwordTooWeak;

  /// No description provided for @tooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please try again in a few minutes.'**
  String get tooManyAttempts;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get tryAgain;

  /// No description provided for @min6Chars.
  ///
  /// In en, this message translates to:
  /// **'Min 6 characters'**
  String get min6Chars;

  /// No description provided for @levelLabel.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String levelLabel(int level);

  /// No description provided for @completedTodayCount.
  ///
  /// In en, this message translates to:
  /// **'Completed today'**
  String get completedTodayCount;

  /// No description provided for @todayAlreadyCompleted.
  ///
  /// In en, this message translates to:
  /// **'Already completed today.'**
  String get todayAlreadyCompleted;

  /// No description provided for @goalNotFound.
  ///
  /// In en, this message translates to:
  /// **'Goal not found.'**
  String get goalNotFound;

  /// No description provided for @fitness.
  ///
  /// In en, this message translates to:
  /// **'Fitness'**
  String get fitness;

  /// No description provided for @study.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get study;

  /// No description provided for @work.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get work;

  /// No description provided for @focus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get focus;

  /// No description provided for @mind.
  ///
  /// In en, this message translates to:
  /// **'Mind'**
  String get mind;

  /// No description provided for @health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get health;

  /// No description provided for @finance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get finance;

  /// No description provided for @selfGrowth.
  ///
  /// In en, this message translates to:
  /// **'Self Growth'**
  String get selfGrowth;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @digitalDetox.
  ///
  /// In en, this message translates to:
  /// **'Digital Detox'**
  String get digitalDetox;

  /// No description provided for @social.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get social;

  /// No description provided for @creativity.
  ///
  /// In en, this message translates to:
  /// **'Creativity'**
  String get creativity;

  /// No description provided for @discipline.
  ///
  /// In en, this message translates to:
  /// **'Discipline'**
  String get discipline;

  /// No description provided for @easy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @hard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hard;

  /// No description provided for @easyXp.
  ///
  /// In en, this message translates to:
  /// **'Easy (10 XP)'**
  String get easyXp;

  /// No description provided for @mediumXp.
  ///
  /// In en, this message translates to:
  /// **'Medium (25 XP)'**
  String get mediumXp;

  /// No description provided for @hardXp.
  ///
  /// In en, this message translates to:
  /// **'Hard (50 XP)'**
  String get hardXp;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @turkish.
  ///
  /// In en, this message translates to:
  /// **'Türkçe'**
  String get turkish;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get systemDefault;

  /// No description provided for @xpEarned.
  ///
  /// In en, this message translates to:
  /// **'+{xp} XP'**
  String xpEarned(int xp);

  /// No description provided for @xpEarnedLevelUp.
  ///
  /// In en, this message translates to:
  /// **'+{xp} XP — Level Up! (Lv {level})'**
  String xpEarnedLevelUp(int xp, int level);

  /// No description provided for @activeChallenge.
  ///
  /// In en, this message translates to:
  /// **'Active challenge'**
  String get activeChallenge;

  /// No description provided for @challengesCompleted.
  ///
  /// In en, this message translates to:
  /// **'Challenges completed'**
  String get challengesCompleted;

  /// No description provided for @completionsByCategory.
  ///
  /// In en, this message translates to:
  /// **'Completions by category'**
  String get completionsByCategory;

  /// No description provided for @advancedStats.
  ///
  /// In en, this message translates to:
  /// **'Advanced stats'**
  String get advancedStats;

  /// No description provided for @weeklyXp.
  ///
  /// In en, this message translates to:
  /// **'Weekly XP'**
  String get weeklyXp;

  /// No description provided for @mostProductiveCategory.
  ///
  /// In en, this message translates to:
  /// **'Most productive category'**
  String get mostProductiveCategory;

  /// No description provided for @last30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get last30Days;

  /// No description provided for @challengeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Challenge not found'**
  String get challengeNotFound;

  /// No description provided for @goalsInThisChallenge.
  ///
  /// In en, this message translates to:
  /// **'Goals in this challenge'**
  String get goalsInThisChallenge;

  /// No description provided for @challengeCompleted.
  ///
  /// In en, this message translates to:
  /// **'Challenge completed!'**
  String get challengeCompleted;

  /// No description provided for @bonusXpAddedWhenFinished.
  ///
  /// In en, this message translates to:
  /// **'+{xp} XP was added when you finished.'**
  String bonusXpAddedWhenFinished(int xp);

  /// No description provided for @youAreDoingThisChallenge.
  ///
  /// In en, this message translates to:
  /// **'You are doing this challenge'**
  String get youAreDoingThisChallenge;

  /// No description provided for @alreadyHaveActiveChallenge.
  ///
  /// In en, this message translates to:
  /// **'You already have an active challenge.'**
  String get alreadyHaveActiveChallenge;

  /// No description provided for @challengeStartedMessage.
  ///
  /// In en, this message translates to:
  /// **'{title} started! Complete 1 goal per day to earn {xp} bonus XP.'**
  String challengeStartedMessage(String title, int xp);

  /// No description provided for @challengeStartedMessageOffline.
  ///
  /// In en, this message translates to:
  /// **'{title} started! Complete goals to earn {xp} bonus XP.'**
  String challengeStartedMessageOffline(String title, int xp);

  /// No description provided for @claimBonus.
  ///
  /// In en, this message translates to:
  /// **'Claim bonus'**
  String get claimBonus;

  /// No description provided for @claimBonusXp.
  ///
  /// In en, this message translates to:
  /// **'Claim {xp} bonus XP'**
  String claimBonusXp(int xp);

  /// No description provided for @bonusXpClaimed.
  ///
  /// In en, this message translates to:
  /// **'+{xp} bonus XP claimed!'**
  String bonusXpClaimed(int xp);

  /// No description provided for @progressPercent.
  ///
  /// In en, this message translates to:
  /// **'Progress: {percent}%'**
  String progressPercent(String percent);

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String daysCount(int count);

  /// No description provided for @bonusXpLabel.
  ///
  /// In en, this message translates to:
  /// **'{xp} bonus XP'**
  String bonusXpLabel(int xp);

  /// No description provided for @benefits.
  ///
  /// In en, this message translates to:
  /// **'Benefits'**
  String get benefits;

  /// No description provided for @unlimitedGoals.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Goals'**
  String get unlimitedGoals;

  /// No description provided for @streakProtection.
  ///
  /// In en, this message translates to:
  /// **'Streak Protection'**
  String get streakProtection;

  /// No description provided for @premiumPurchasesMobileOnly.
  ///
  /// In en, this message translates to:
  /// **'Premium purchases available on mobile only.'**
  String get premiumPurchasesMobileOnly;

  /// No description provided for @devPremiumEnabled.
  ///
  /// In en, this message translates to:
  /// **'Dev: Premium enabled'**
  String get devPremiumEnabled;

  /// No description provided for @devEnablePremium.
  ///
  /// In en, this message translates to:
  /// **'Dev: Enable Premium'**
  String get devEnablePremium;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get restorePurchases;

  /// No description provided for @restoreRequested.
  ///
  /// In en, this message translates to:
  /// **'Restore requested'**
  String get restoreRequested;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @buy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get buy;

  /// No description provided for @unknownRoutingError.
  ///
  /// In en, this message translates to:
  /// **'Unknown routing error'**
  String get unknownRoutingError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Xpire';

  @override
  String get signIn => 'Sign in';

  @override
  String get createAccount => 'Create account';

  @override
  String get dontHaveAccount => 'Don\'t have an account? ';

  @override
  String get email => 'Email';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get enterEmail => 'Enter your email';

  @override
  String get enterValidEmail => 'Enter a valid email';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get atLeast6Chars => 'At least 6 characters';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get alreadyHaveAccount => 'Already have an account? Sign in';

  @override
  String get supabaseNotConfigured =>
      'Supabase is not configured. Set SUPABASE_URL and SUPABASE_ANON_KEY.';

  @override
  String get authError => 'Auth error';

  @override
  String get dashboard => 'Xpire';

  @override
  String get stats => 'Stats';

  @override
  String get profile => 'Profile';

  @override
  String get level => 'Level';

  @override
  String get totalXp => 'Total XP';

  @override
  String get streak => 'Streak';

  @override
  String get premium => 'Premium';

  @override
  String get premiumActive => 'Active';

  @override
  String get premiumNotActive => 'Not active';

  @override
  String get upgradeToPremium => 'Upgrade to Premium';

  @override
  String get signOut => 'Sign out';

  @override
  String get yourInfo => 'Your info';

  @override
  String get fullName => 'Full name';

  @override
  String get username => 'Username';

  @override
  String get age => 'Age';

  @override
  String get occupation => 'Occupation';

  @override
  String get focusCategory => 'Focus category';

  @override
  String get optional => 'Optional';

  @override
  String get none => 'None';

  @override
  String get saveProfile => 'Save profile';

  @override
  String get profileSaved => 'Profile saved';

  @override
  String get newGoal => 'New goal';

  @override
  String get createCustom => 'Create Custom';

  @override
  String get useTemplate => 'Use Template';

  @override
  String get title => 'Title';

  @override
  String get category => 'Category';

  @override
  String get difficulty => 'Difficulty';

  @override
  String get enterTitle => 'Enter a title';

  @override
  String get keepLonger => 'Keep it a bit longer';

  @override
  String get save => 'Save';

  @override
  String get all => 'All';

  @override
  String fromTemplate(String title) {
    return 'From template: $title';
  }

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get challenges => 'Challenges';

  @override
  String get challengesIntro =>
      'Build habits with structured challenges. Complete all goals to earn bonus XP.';

  @override
  String get challengesEmpty =>
      'No challenges right now. Create goals from the dashboard to get started.';

  @override
  String get challengesEmptyTitle => 'No challenges yet';

  @override
  String get challengesNoActiveTitle => 'No Active Challenges Yet';

  @override
  String get challengesNoActiveSubtitle =>
      'Start your first 7-day challenge to begin earning bonus XP.';

  @override
  String get challengesNoActiveSubtitleShort =>
      'Start your first 7-day challenge.';

  @override
  String get browseChallenges => 'Browse Challenges';

  @override
  String get activeChallengesSection => 'Active Challenges';

  @override
  String get myActiveChallengesSection => 'My Active Challenges';

  @override
  String get communityChallengesSection => 'Community Challenges';

  @override
  String get startNewChallengeSection => 'Start a New Challenge';

  @override
  String get scrollToTemplates => 'Scroll to templates';

  @override
  String participantsCount(int count) {
    return '$count participants';
  }

  @override
  String get joinChallenge => 'Join';

  @override
  String get joined => 'Joined';

  @override
  String get createChallenge => 'Create Challenge';

  @override
  String get challengeCreated => 'Challenge created.';

  @override
  String get quitChallenge => 'Quit routine';

  @override
  String get quitChallengeConfirm =>
      'Are you sure you want to quit this routine?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get challengeDescription => 'Description';

  @override
  String get challengeDescriptionHint => 'Short description of the challenge';

  @override
  String get enterDescription => 'Enter a description';

  @override
  String get durationDays => 'Duration (days)';

  @override
  String get rewardXp => 'Reward XP';

  @override
  String get dailyChallengeLimitReached =>
      'Daily challenge creation limit reached (2 per day).';

  @override
  String get dailyLimitTooltip => 'Daily limit reached. Come back tomorrow.';

  @override
  String get startChallengeButton => 'Start Challenge';

  @override
  String get challengesLoadError =>
      'Could not load challenges. Pull to try again.';

  @override
  String daysBonusXp(int days, int xp) {
    return '$days days · $xp bonus XP';
  }

  @override
  String get activeGoals => 'Active goals';

  @override
  String get todaysSuggestedGoals => 'Today\'s Suggested Goals';

  @override
  String get todaysAIPlan => 'Today\'s AI Plan';

  @override
  String get reminderBannerMessage =>
      'You haven\'t completed today\'s goals yet.';

  @override
  String get dailyReminders => 'Daily reminders';

  @override
  String get enableDailyReminder => 'Enable daily reminder';

  @override
  String get reminderTime => 'Reminder time';

  @override
  String get recommendedChallenges => 'Recommended challenges';

  @override
  String get recommendedGoals => 'Recommended goals';

  @override
  String get startChallenge => 'Start a Challenge';

  @override
  String dayProgress(int current, int total) {
    return 'Day $current / $total';
  }

  @override
  String bonusXp(int xp) {
    return 'Bonus: +$xp XP';
  }

  @override
  String daysLeft(int count) {
    return '$count days left';
  }

  @override
  String daysCompleted(int count) {
    return '$count days completed';
  }

  @override
  String get complete => 'Complete';

  @override
  String get done => 'Done';

  @override
  String get noActiveGoals =>
      'No active goals yet.\nTap + to create your first one.';

  @override
  String get noActiveGoalsTitle => 'No goals yet';

  @override
  String get noActiveGoalsDescription =>
      'Create your first goal to start earning XP and building streaks.';

  @override
  String get goalsCompleted => 'Goals completed';

  @override
  String get currentStreak => 'Current streak';

  @override
  String get completedToday => 'Completed today';

  @override
  String get daysSuffix => ' days';

  @override
  String get premiumFeature => 'Premium Feature';

  @override
  String get advancedStatsDesc =>
      'Weekly average, most productive category, 30-day trend';

  @override
  String get upgrade => 'Upgrade';

  @override
  String get premiumPageTitle => 'Premium';

  @override
  String get unlockPotential => 'Unlock your full potential';

  @override
  String get youHavePremium => 'You have Premium';

  @override
  String get premiumActivated => 'Premium activated';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get invalidEmailPassword => 'Invalid email or password.';

  @override
  String get confirmEmailFirst =>
      'Please confirm your email before signing in.';

  @override
  String get emailAlreadyRegistered => 'This email is already registered.';

  @override
  String get passwordMinLength => 'Password should be at least 6 characters.';

  @override
  String get passwordTooWeak =>
      'Password is too weak. Use at least 6 characters.';

  @override
  String get tooManyAttempts =>
      'Too many attempts. Please try again in a few minutes.';

  @override
  String get tryAgain => 'Something went wrong. Try again.';

  @override
  String get min6Chars => 'Min 6 characters';

  @override
  String levelLabel(int level) {
    return 'Level $level';
  }

  @override
  String get levelUpTitle => 'Level Up!';

  @override
  String levelUpMessage(int level) {
    return 'You reached level $level. Keep going!';
  }

  @override
  String dailyXpAvailable(int xp) {
    return 'Daily XP available: $xp';
  }

  @override
  String get completedTodayCount => 'Completed today';

  @override
  String get todayAlreadyCompleted => 'Already completed today.';

  @override
  String get goalNotFound => 'Goal not found.';

  @override
  String get fitness => 'Fitness';

  @override
  String get study => 'Study';

  @override
  String get work => 'Work';

  @override
  String get focus => 'Focus';

  @override
  String get mind => 'Mind';

  @override
  String get health => 'Health';

  @override
  String get finance => 'Finance';

  @override
  String get selfGrowth => 'Self Growth';

  @override
  String get general => 'General';

  @override
  String get digitalDetox => 'Digital Detox';

  @override
  String get social => 'Social';

  @override
  String get creativity => 'Creativity';

  @override
  String get discipline => 'Discipline';

  @override
  String get easy => 'Easy';

  @override
  String get medium => 'Medium';

  @override
  String get hard => 'Hard';

  @override
  String get easyXp => 'Easy (10 XP)';

  @override
  String get mediumXp => 'Medium (25 XP)';

  @override
  String get hardXp => 'Hard (50 XP)';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get turkish => 'Türkçe';

  @override
  String get systemDefault => 'System default';

  @override
  String xpEarned(int xp) {
    return '+$xp XP';
  }

  @override
  String xpEarnedLevelUp(int xp, int level) {
    return '+$xp XP — Level Up! (Lv $level)';
  }

  @override
  String get activeChallenge => 'Active challenge';

  @override
  String get challengesCompleted => 'Challenges completed';

  @override
  String get completionsByCategory => 'Completions by category';

  @override
  String get advancedStats => 'Advanced stats';

  @override
  String get weeklyXp => 'Weekly XP';

  @override
  String get mostProductiveCategory => 'Most productive category';

  @override
  String get last30Days => 'Last 30 days';

  @override
  String get challengeNotFound => 'Challenge not found';

  @override
  String get goalsInThisChallenge => 'Goals in this challenge';

  @override
  String get challengeCompleted => 'Challenge completed!';

  @override
  String bonusXpAddedWhenFinished(int xp) {
    return '+$xp XP was added when you finished.';
  }

  @override
  String get youAreDoingThisChallenge => 'You are doing this challenge';

  @override
  String get alreadyHaveActiveChallenge =>
      'You already have an active challenge.';

  @override
  String challengeStartedMessage(String title, int xp) {
    return '$title started! Complete 1 goal per day to earn $xp bonus XP.';
  }

  @override
  String challengeStartedMessageOffline(String title, int xp) {
    return '$title started! Complete goals to earn $xp bonus XP.';
  }

  @override
  String get claimBonus => 'Claim bonus';

  @override
  String claimBonusXp(int xp) {
    return 'Claim $xp bonus XP';
  }

  @override
  String bonusXpClaimed(int xp) {
    return '+$xp bonus XP claimed!';
  }

  @override
  String progressPercent(String percent) {
    return 'Progress: $percent%';
  }

  @override
  String daysCount(int count) {
    return '$count days';
  }

  @override
  String bonusXpLabel(int xp) {
    return '$xp bonus XP';
  }

  @override
  String get benefits => 'Benefits';

  @override
  String get unlimitedGoals => 'Unlimited Goals';

  @override
  String get streakProtection => 'Streak Protection';

  @override
  String get premiumPurchasesMobileOnly =>
      'Premium purchases available on mobile only.';

  @override
  String get devPremiumEnabled => 'Dev: Premium enabled';

  @override
  String get devEnablePremium => 'Dev: Enable Premium';

  @override
  String get restorePurchases => 'Restore purchases';

  @override
  String get restoreRequested => 'Restore requested';

  @override
  String get monthly => 'Monthly';

  @override
  String get yearly => 'Yearly';

  @override
  String get buy => 'Buy';

  @override
  String get unknownRoutingError => 'Unknown routing error';

  @override
  String get leaderboard => 'Leaderboard';

  @override
  String get challengeLeaderboard => 'Challenge Leaderboard';

  @override
  String get weeklyLeaderboard => 'Weekly Leaderboard';

  @override
  String get yourRank => 'Your rank';

  @override
  String get completedDaysLabel => 'Days';

  @override
  String get noLeaderboardYet => 'No entries yet';

  @override
  String get rankLabel => 'Rank';

  @override
  String xpCount(Object count) {
    return '$count XP';
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:xpire/core/services/analytics_service.dart';
import 'package:xpire/core/services/xp_service.dart';
import 'package:xpire/data/content/content_repository.dart';
import 'package:xpire/data/models/challenge.dart';
import 'package:xpire/data/models/challenge_progress.dart';
import 'package:xpire/data/models/goal.dart';
import 'package:xpire/data/models/goal_template.dart';
import 'package:xpire/data/repositories/supabase_challenge_progress_repository.dart';
import 'package:xpire/data/repositories/supabase_goal_repository.dart';
import 'package:xpire/data/repositories/supabase_profile_repository.dart';
import 'package:xpire/features/challenges/challenge_engine.dart';

class MockContentRepository extends Mock implements ContentRepository {}

class MockSupabaseGoalRepository extends Mock
    implements SupabaseGoalRepository {}

class MockSupabaseProfileRepository extends Mock
    implements SupabaseProfileRepository {}

class MockSupabaseChallengeProgressRepository extends Mock
    implements SupabaseChallengeProgressRepository {}

class MockXpService extends Mock implements XpService {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

class FakeGoal extends Fake implements Goal {}

class FakeChallengeProgress extends Fake implements ChallengeProgress {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeGoal());
    registerFallbackValue(FakeChallengeProgress());
  });

  late ChallengeEngine engine;
  late MockContentRepository mockContentRepo;
  late MockSupabaseGoalRepository mockGoalRepo;
  late MockSupabaseProfileRepository mockProfileRepo;
  late MockSupabaseChallengeProgressRepository mockProgressRepo;
  late MockXpService mockXpService;
  late MockAnalyticsService mockAnalyticsService;

  setUp(() {
    mockContentRepo = MockContentRepository();
    mockGoalRepo = MockSupabaseGoalRepository();
    mockProfileRepo = MockSupabaseProfileRepository();
    mockProgressRepo = MockSupabaseChallengeProgressRepository();
    mockXpService = MockXpService();
    mockAnalyticsService = MockAnalyticsService();

    engine = ChallengeEngine(
      contentRepository: mockContentRepo,
      goalRepository: mockGoalRepo,
      profileRepository: mockProfileRepo,
      progressRepository: mockProgressRepo,
      xpService: mockXpService,
      analytics: mockAnalyticsService,
    );
  });

  group('ChallengeEngine.startChallenge', () {
    test('returns null if there is already an active challenge', () async {
      when(() => mockProgressRepo.getActive('user1')).thenAnswer(
        (_) async => ChallengeProgress(
          id: '1',
          userId: 'user1',
          challengeId: 'c1',
          startedAt: DateTime.now(),
          currentDay: 1,
          completedDays: 0,
          isCompleted: false,
        ),
      );

      final challenge = Challenge(
        id: 'c1',
        title: '7-Day Jump',
        description: 'Desc',
        category: GoalCategory.health,
        templateGoalIds: ['t1'],
        durationDays: 7,
        bonusXp: 100,
      );

      final result = await engine.startChallenge(
        userId: 'user1',
        challenge: challenge,
      );
      expect(result, isNull);
    });

    test('creates goals and progress when starting a challenge', () async {
      // Setup
      when(
        () => mockProgressRepo.getActive('user1'),
      ).thenAnswer((_) async => null);

      when(() => mockContentRepo.getTemplateById('t1')).thenReturn(
        GoalTemplate(
          id: 't1',
          title: 'Task 1',
          description: 'Test task',
          category: GoalCategory.health,
          difficulty: GoalDifficulty.easy,
          baseXp: 10,
          frequency: TemplateFrequency.daily,
        ),
      );

      when(() => mockGoalRepo.upsert(any())).thenAnswer((_) async {});
      when(() => mockProgressRepo.upsert(any())).thenAnswer((_) async {});

      final challenge = Challenge(
        id: 'c1',
        title: '7-Day Jump',
        description: 'Desc',
        category: GoalCategory.health,
        templateGoalIds: ['t1'],
        durationDays: 7,
        bonusXp: 100,
      );

      // Execute
      final result = await engine.startChallenge(
        userId: 'user1',
        challenge: challenge,
      );

      // Verify
      expect(result, isNotNull);
      expect(result!.challengeId, 'c1');
      expect(result.currentDay, 1);
      expect(result.completedDays, 0);
      expect(result.goalIds?.length, 1);

      verify(() => mockGoalRepo.upsert(any())).called(1);
      verify(() => mockProgressRepo.upsert(any())).called(1);
    });
  });

  group('ChallengeEngine.checkDaySkipped', () {
    test('marks challenge failed if a day is skipped', () async {
      // Let's say we started 2 days ago, and completedDays is still 0
      // Current day expected is 1. Today is 2 days after start.
      final startDay = DateTime.now().subtract(const Duration(days: 2));

      when(() => mockProgressRepo.getActive('user1')).thenAnswer(
        (_) async => ChallengeProgress(
          id: '1',
          userId: 'user1',
          challengeId: 'c1',
          startedAt: startDay,
          currentDay: 1,
          completedDays: 0,
          isCompleted: false,
        ),
      );

      when(() => mockContentRepo.getChallengeById('c1')).thenReturn(
        Challenge(
          id: 'c1',
          title: '7-Day Jump',
          description: 'Desc',
          category: GoalCategory.health,
          templateGoalIds: ['t1'],
          durationDays: 7,
          bonusXp: 100,
        ),
      );

      when(() => mockProgressRepo.upsert(any())).thenAnswer((_) async {});
      when(() => mockAnalyticsService.track(any(), any())).thenReturn(null);

      await engine.checkDaySkipped('user1');

      // Upsert should be called with failedAt != null
      final captured = verify(
        () => mockProgressRepo.upsert(captureAny()),
      ).captured;
      final savedProgress = captured.first as ChallengeProgress;

      expect(savedProgress.failedAt, isNotNull);
    });
  });
}

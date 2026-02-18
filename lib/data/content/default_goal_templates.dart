import '../models/goal.dart';
import '../models/goal_template.dart';

/// 80+ goal templates grouped by category. All isPremium = false; frequency = daily.
/// Quality: specific, measurable, practical. XP: easy=10, medium=25, hard=50.

// ---------------------------------------------------------------------------
// Helpers: one template per call for readability and easy maintenance
// ---------------------------------------------------------------------------

GoalTemplate _t({
  required String id,
  required String title,
  required String description,
  required GoalCategory category,
  required GoalDifficulty difficulty,
  required int baseXp,
}) {
  return GoalTemplate(
    id: id,
    title: title,
    description: description,
    category: category,
    difficulty: difficulty,
    baseXp: baseXp,
    frequency: TemplateFrequency.daily,
    isPremium: false,
  );
}

// ---------------------------------------------------------------------------
// 1. Fitness (7)
// ---------------------------------------------------------------------------

List<GoalTemplate> _fitnessTemplates() => [
  _t(
    id: 'tpl_morning_walk',
    title: '20-Minute Morning Walk',
    description:
        'Start the day with a 20-minute walk outdoors or on a treadmill.',
    category: GoalCategory.fitness,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_10min_stretch',
    title: '10-Minute Stretch',
    description: 'Full-body stretching or mobility routine for 10 minutes.',
    category: GoalCategory.fitness,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_30min_workout',
    title: '30-Minute Strength Workout',
    description: 'Full-body or cardio workout for 30 minutes.',
    category: GoalCategory.fitness,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_50_pushups',
    title: '50 Push-Ups (Total)',
    description: 'Complete 50 push-ups in sets throughout the day.',
    category: GoalCategory.fitness,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_5km_run',
    title: '5km Run',
    description: 'Complete a 5 km run at your own pace.',
    category: GoalCategory.fitness,
    difficulty: GoalDifficulty.hard,
    baseXp: 50,
  ),
  _t(
    id: 'tpl_60min_strength',
    title: '60-Minute Strength Session',
    description: '45–60 minute dedicated strength training session.',
    category: GoalCategory.fitness,
    difficulty: GoalDifficulty.hard,
    baseXp: 50,
  ),
  _t(
    id: 'tpl_plank_3min',
    title: '3-Minute Plank Total',
    description: 'Hold plank for 3 minutes total (can be split into sets).',
    category: GoalCategory.fitness,
    difficulty: GoalDifficulty.hard,
    baseXp: 50,
  ),
];

// ---------------------------------------------------------------------------
// 2. Health (7)
// ---------------------------------------------------------------------------

List<GoalTemplate> _healthTemplates() => [
  _t(
    id: 'tpl_drink_8_glasses',
    title: 'Drink 8 Glasses of Water',
    description: 'Stay hydrated with 8 glasses (2 L) of water today.',
    category: GoalCategory.health,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_healthy_meal',
    title: 'One Home-Prepared Healthy Meal',
    description: 'Eat at least one balanced, home-prepared meal.',
    category: GoalCategory.health,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_8hr_sleep',
    title: '8 Hours of Sleep',
    description: 'Get at least 8 hours of sleep tonight.',
    category: GoalCategory.health,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_no_sugar_day',
    title: 'No Added Sugar Day',
    description: 'A full day without added sugar in food or drinks.',
    category: GoalCategory.health,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_10k_steps',
    title: '10,000 Steps',
    description: 'Hit 10,000 steps (or your daily step target).',
    category: GoalCategory.health,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_5_veg_servings',
    title: '5 Servings of Fruits & Vegetables',
    description: 'Eat at least 5 servings of fruits and vegetables today.',
    category: GoalCategory.health,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_no_screens_1hr_bed',
    title: 'No Screens 1 Hour Before Bed',
    description: 'No phone, tablet, or TV for the last hour before sleep.',
    category: GoalCategory.health,
    difficulty: GoalDifficulty.hard,
    baseXp: 50,
  ),
];

// ---------------------------------------------------------------------------
// 3. Mind (7)
// ---------------------------------------------------------------------------

List<GoalTemplate> _mindTemplates() => [
  _t(
    id: 'tpl_10min_meditation',
    title: '10-Minute Meditation',
    description: 'Guided or silent meditation for 10 minutes.',
    category: GoalCategory.mind,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_gratitude_3',
    title: 'Write 3 Things You\'re Grateful For',
    description: 'List three things you are grateful for today.',
    category: GoalCategory.mind,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_breathing_5min',
    title: '5-Minute Breathing Exercises',
    description: 'Box breathing or deep breathing for 5 minutes.',
    category: GoalCategory.mind,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_evening_reflect_5',
    title: '5-Minute Evening Reflection',
    description: 'Reflect: one win, one lesson, one intention for tomorrow.',
    category: GoalCategory.mind,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_digital_detox_1hr',
    title: '1 Hour Digital Detox',
    description: 'No phone or social media for one full hour.',
    category: GoalCategory.mind,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_journal_15min',
    title: '15-Minute Journaling',
    description: 'Write for 15 minutes about your day or feelings.',
    category: GoalCategory.mind,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_body_scan_10',
    title: '10-Minute Body Scan',
    description: 'Guided or self body scan meditation for 10 minutes.',
    category: GoalCategory.mind,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
];

// ---------------------------------------------------------------------------
// 4. Study (7)
// ---------------------------------------------------------------------------

List<GoalTemplate> _studyTemplates() => [
  _t(
    id: 'tpl_30min_reading',
    title: 'Read 30 Minutes',
    description: 'Read a book or article for at least 30 minutes.',
    category: GoalCategory.study,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_read_20_pages',
    title: 'Read 20 Pages',
    description: 'Read 20 pages of a book or textbook.',
    category: GoalCategory.study,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_flashcards_review',
    title: 'Review One Flashcard Deck',
    description: 'Review one full deck of flashcards.',
    category: GoalCategory.study,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_1hr_deep_work',
    title: '1 Hour Deep Work',
    description: 'One uninterrupted hour of focused study or work.',
    category: GoalCategory.study,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_solve_20_questions',
    title: 'Solve 20 Practice Questions',
    description: 'Complete 20 practice or exercise questions.',
    category: GoalCategory.study,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_2hr_study_block',
    title: '2-Hour Study Block',
    description: 'Two focused hours on one subject or project.',
    category: GoalCategory.study,
    difficulty: GoalDifficulty.hard,
    baseXp: 50,
  ),
  _t(
    id: 'tpl_summarize_chapter',
    title: 'Summarize One Chapter',
    description: 'Read and write a short summary of one chapter.',
    category: GoalCategory.study,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
];

// ---------------------------------------------------------------------------
// 5. Work (7)
// ---------------------------------------------------------------------------

List<GoalTemplate> _workTemplates() => [
  _t(
    id: 'tpl_plan_tomorrow',
    title: 'Plan Tomorrow: Top 3 Priorities',
    description: 'Write your top 3 priorities for tomorrow.',
    category: GoalCategory.work,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_inbox_zero',
    title: 'Inbox Zero',
    description: 'Clear your email inbox to zero (or to a defined threshold).',
    category: GoalCategory.work,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_complete_top_3',
    title: 'Complete Top 3 Tasks',
    description: 'Finish your top 3 priority tasks for the day.',
    category: GoalCategory.work,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_pomodoro_4',
    title: '4 Pomodoro Sessions',
    description: 'Four 25-minute focus sessions with 5-min breaks.',
    category: GoalCategory.work,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_no_meeting_deep_day',
    title: 'No-Meeting Deep Work Day',
    description: 'A full workday with no meetings, only deep work blocks.',
    category: GoalCategory.work,
    difficulty: GoalDifficulty.hard,
    baseXp: 50,
  ),
  _t(
    id: 'tpl_finish_one_project_milestone',
    title: 'Complete One Project Milestone',
    description: 'Finish one defined milestone on a current project.',
    category: GoalCategory.work,
    difficulty: GoalDifficulty.hard,
    baseXp: 50,
  ),
  _t(
    id: 'tpl_reply_all_pending',
    title: 'Reply to All Pending Messages',
    description: 'Reply to all pending emails or messages in your queue.',
    category: GoalCategory.work,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
];

// ---------------------------------------------------------------------------
// 6. Focus (7)
// ---------------------------------------------------------------------------

List<GoalTemplate> _focusTemplates() => [
  _t(
    id: 'tpl_no_phone_1hr',
    title: '1 Hour Phone-Free',
    description: 'No phone or notifications for one focused hour.',
    category: GoalCategory.focus,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_log_distractions',
    title: 'Log Distractions Once',
    description: 'Note down distractions when they happen and refocus.',
    category: GoalCategory.focus,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_single_task_45',
    title: '45-Minute Single-Task Block',
    description: 'Work on one task only for 45 minutes with no switching.',
    category: GoalCategory.focus,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_3_pomodoro',
    title: '3 Pomodoro Sessions',
    description: 'Three 25-minute focused blocks with short breaks.',
    category: GoalCategory.focus,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_90min_deep_work',
    title: '90-Minute Deep Work',
    description: 'One uninterrupted 90-minute deep work session.',
    category: GoalCategory.focus,
    difficulty: GoalDifficulty.hard,
    baseXp: 50,
  ),
  _t(
    id: 'tpl_no_social_media_day',
    title: 'No Social Media All Day',
    description: 'Zero social media use for the entire day.',
    category: GoalCategory.focus,
    difficulty: GoalDifficulty.hard,
    baseXp: 50,
  ),
  _t(
    id: 'tpl_first_hour_no_email',
    title: 'First Hour: No Email',
    description: 'Do not check email for the first hour of work.',
    category: GoalCategory.focus,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
];

// ---------------------------------------------------------------------------
// 7. Finance (7)
// ---------------------------------------------------------------------------

List<GoalTemplate> _financeTemplates() => [
  _t(
    id: 'tpl_track_expenses',
    title: 'Track All Expenses Today',
    description: 'Log every expense for the day in your tracker.',
    category: GoalCategory.finance,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_check_balance',
    title: 'Check Account Balance',
    description: 'Review your main account balance and pending items.',
    category: GoalCategory.finance,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_no_impulse_buy',
    title: 'No Impulse Purchase',
    description: 'Skip any unplanned purchase today.',
    category: GoalCategory.finance,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_review_budget',
    title: 'Review Monthly Budget',
    description: 'Review and adjust your budget for the month.',
    category: GoalCategory.finance,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_save_fixed_amount',
    title: 'Transfer Fixed Amount to Savings',
    description: 'Transfer a set amount to savings today.',
    category: GoalCategory.finance,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_cancel_one_subscription',
    title: 'Cancel One Unused Subscription',
    description: 'Cancel at least one subscription you no longer use.',
    category: GoalCategory.finance,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_plan_week_meals',
    title: 'Plan Weekly Meals (Budget)',
    description: 'Plan meals for the week with a budget in mind.',
    category: GoalCategory.finance,
    difficulty: GoalDifficulty.hard,
    baseXp: 50,
  ),
];

// ---------------------------------------------------------------------------
// 8. Self Growth (7)
// ---------------------------------------------------------------------------

List<GoalTemplate> _selfGrowthTemplates() => [
  _t(
    id: 'tpl_learn_one_thing',
    title: 'Learn One New Thing (15 min)',
    description: 'Read, watch, or practice something new for 15+ minutes.',
    category: GoalCategory.selfGrowth,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_journal_5min',
    title: '5-Minute Journaling',
    description: 'Write a short journal entry about your day or goals.',
    category: GoalCategory.selfGrowth,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_set_daily_intention',
    title: 'Set Daily Intention',
    description: 'Set one clear intention for the day in the morning.',
    category: GoalCategory.selfGrowth,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_skill_practice_20',
    title: '20-Minute Skill Practice',
    description: 'Practice a skill you want to improve for 20 minutes.',
    category: GoalCategory.selfGrowth,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_weekly_review',
    title: 'Weekly Review',
    description: 'Review the week: wins, learnings, next week priorities.',
    category: GoalCategory.selfGrowth,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_one_hard_conversation',
    title: 'One Difficult Conversation',
    description: 'Have one conversation you\'ve been avoiding (respectful).',
    category: GoalCategory.selfGrowth,
    difficulty: GoalDifficulty.hard,
    baseXp: 50,
  ),
  _t(
    id: 'tpl_feedback_request',
    title: 'Request Feedback From One Person',
    description:
        'Ask one person for specific feedback on your work or behavior.',
    category: GoalCategory.selfGrowth,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
];

// ---------------------------------------------------------------------------
// 9. Digital Detox (7)
// ---------------------------------------------------------------------------

List<GoalTemplate> _digitalDetoxTemplates() => [
  _t(
    id: 'tpl_no_phone_meal',
    title: 'No Phone During Meals',
    description: 'No phone at the table during any meal today.',
    category: GoalCategory.digitalDetox,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_notifications_off_2hr',
    title: 'Notifications Off for 2 Hours',
    description: 'Turn off non-essential notifications for 2 hours.',
    category: GoalCategory.digitalDetox,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_no_social_30min',
    title: 'No Social Media for 30 Minutes',
    description: 'No social media apps for 30 minutes (or more).',
    category: GoalCategory.digitalDetox,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_screen_free_evening_1hr',
    title: '1-Hour Screen-Free Evening',
    description: 'No screens for the last hour before bed.',
    category: GoalCategory.digitalDetox,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_phone_in_other_room',
    title: 'Phone in Another Room (2 hr)',
    description: 'Keep your phone in another room for 2 hours.',
    category: GoalCategory.digitalDetox,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_digital_sabbath_half_day',
    title: 'Half-Day Digital Sabbath',
    description:
        'No personal devices for half the day (e.g. morning or afternoon).',
    category: GoalCategory.digitalDetox,
    difficulty: GoalDifficulty.hard,
    baseXp: 50,
  ),
  _t(
    id: 'tpl_one_app_deleted',
    title: 'Delete One Time-Wasting App',
    description:
        'Remove one app that drains your attention (can reinstall later).',
    category: GoalCategory.digitalDetox,
    difficulty: GoalDifficulty.hard,
    baseXp: 50,
  ),
];

// ---------------------------------------------------------------------------
// 10. Social (7)
// ---------------------------------------------------------------------------

List<GoalTemplate> _socialTemplates() => [
  _t(
    id: 'tpl_one_genuine_compliment',
    title: 'Give One Genuine Compliment',
    description: 'Give one sincere compliment to someone today.',
    category: GoalCategory.social,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_reach_out_one_person',
    title: 'Reach Out to One Person',
    description:
        'Message or call one friend or family member you haven\'t talked to lately.',
    category: GoalCategory.social,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_ask_how_they_are',
    title: 'Ask "How Are You?" and Listen',
    description: 'Ask someone how they are and listen without rushing.',
    category: GoalCategory.social,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_one_face_to_face_meet',
    title: 'One Face-to-Face Meetup',
    description: 'Meet one person face-to-face (coffee, walk, or meal).',
    category: GoalCategory.social,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_say_no_one_request',
    title: 'Say No to One Request',
    description:
        'Politely decline one request that doesn\'t align with your priorities.',
    category: GoalCategory.social,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_host_small_gathering',
    title: 'Host a Small Gathering',
    description: 'Host 2–4 people for a simple get-together.',
    category: GoalCategory.social,
    difficulty: GoalDifficulty.hard,
    baseXp: 50,
  ),
  _t(
    id: 'tpl_thank_you_note',
    title: 'Send One Thank-You Note',
    description: 'Write and send a short thank-you note (text or card).',
    category: GoalCategory.social,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
];

// ---------------------------------------------------------------------------
// 11. Creativity (7)
// ---------------------------------------------------------------------------

List<GoalTemplate> _creativityTemplates() => [
  _t(
    id: 'tpl_doodle_10min',
    title: '10 Minutes of Doodling or Sketching',
    description: 'Spend 10 minutes drawing, doodling, or sketching freely.',
    category: GoalCategory.creativity,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_write_300_words',
    title: 'Write 300 Words',
    description: 'Write 300 words (journal, story, or idea).',
    category: GoalCategory.creativity,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_one_photo_project',
    title: 'Take 5 Intentional Photos',
    description: 'Take 5 photos with a specific theme or project in mind.',
    category: GoalCategory.creativity,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_30min_creative_session',
    title: '30-Minute Creative Session',
    description:
        '30 minutes on any creative project (music, writing, art, craft).',
    category: GoalCategory.creativity,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_finish_one_creative_piece',
    title: 'Finish One Small Creative Piece',
    description:
        'Complete one small creative work (e.g. one drawing, one short piece).',
    category: GoalCategory.creativity,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_learn_one_creative_skill',
    title: 'Practice One New Creative Skill (20 min)',
    description:
        'Spend 20 minutes learning or practicing a new creative skill.',
    category: GoalCategory.creativity,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_share_creation',
    title: 'Share One Creation',
    description: 'Share one thing you created with at least one person.',
    category: GoalCategory.creativity,
    difficulty: GoalDifficulty.hard,
    baseXp: 50,
  ),
];

// ---------------------------------------------------------------------------
// 12. Discipline (7)
// ---------------------------------------------------------------------------

List<GoalTemplate> _disciplineTemplates() => [
  _t(
    id: 'tpl_wake_no_snooze',
    title: 'Wake Up Without Snooze',
    description: 'Get up at your planned time without hitting snooze.',
    category: GoalCategory.discipline,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_make_bed',
    title: 'Make Your Bed',
    description: 'Make your bed first thing in the morning.',
    category: GoalCategory.discipline,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_one_thing_before_screen',
    title: 'One Task Before First Screen',
    description: 'Complete one meaningful task before opening any screen.',
    category: GoalCategory.discipline,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_stick_to_plan_meals',
    title: 'Stick to Planned Meals',
    description: 'Eat only what you planned (no unplanned snacks or orders).',
    category: GoalCategory.discipline,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_no_complaining_day',
    title: 'No Complaining Day',
    description: 'Go one day without complaining (reframe or stay silent).',
    category: GoalCategory.discipline,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_same_wake_time',
    title: 'Wake at Same Time',
    description: 'Wake up within 30 minutes of your target wake time.',
    category: GoalCategory.discipline,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_cold_shower_1min',
    title: '1-Minute Cold Shower',
    description: 'End your shower with 1 minute of cold water.',
    category: GoalCategory.discipline,
    difficulty: GoalDifficulty.hard,
    baseXp: 50,
  ),
];

// ---------------------------------------------------------------------------
// General (4) – catch-all, beginner-friendly
// ---------------------------------------------------------------------------

List<GoalTemplate> _generalTemplates() => [
  _t(
    id: 'tpl_one_small_win',
    title: 'One Small Win',
    description: 'Complete one small task you\'ve been putting off.',
    category: GoalCategory.general,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_clean_10min',
    title: '10-Minute Tidy',
    description: 'Tidy or clean one area for 10 minutes.',
    category: GoalCategory.general,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_todo_top_1',
    title: 'Complete Your #1 Todo',
    description: 'Finish the single most important item on your list.',
    category: GoalCategory.general,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_no_complaining',
    title: 'No Complaining (Reframe Once)',
    description: 'Catch yourself complaining and reframe it once positively.',
    category: GoalCategory.general,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
];

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

/// Returns all default goal templates (80+), grouped logically by category.
List<GoalTemplate> getDefaultGoalTemplates() {
  return [
    ..._fitnessTemplates(),
    ..._healthTemplates(),
    ..._mindTemplates(),
    ..._studyTemplates(),
    ..._workTemplates(),
    ..._focusTemplates(),
    ..._financeTemplates(),
    ..._selfGrowthTemplates(),
    ..._digitalDetoxTemplates(),
    ..._socialTemplates(),
    ..._creativityTemplates(),
    ..._disciplineTemplates(),
    ..._generalTemplates(),
  ];
}

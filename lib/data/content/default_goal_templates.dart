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
    title: '20 Dakika Sabah Yürüyüşü',
    description:
        'Güne açık havada veya koşu bandında 20 dakikalık bir yürüyüşle başla.',
    category: GoalCategory.fitness,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_10min_stretch',
    title: '10 Dakika Esneme',
    description: '10 dakikalık tüm vücut esneme veya mobilite rutini.',
    category: GoalCategory.fitness,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_30min_workout',
    title: '30 Dakika Kuvvet Antrenmanı',
    description: '30 dakikalık tüm vücut veya kardiyo antrenmanı.',
    category: GoalCategory.fitness,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_50_pushups',
    title: '50 Şınav (Toplam)',
    description: 'Gün içine yayarak toplam 50 şınav çek.',
    category: GoalCategory.fitness,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_5km_run',
    title: '5 km Koşu',
    description: 'Kendi hızında 5 km koş.',
    category: GoalCategory.fitness,
    difficulty: GoalDifficulty.hard,
    baseXp: 50,
  ),
  _t(
    id: 'tpl_60min_strength',
    title: '60 Dakika Kuvvet Antrenmanı',
    description: '45-60 dakikalık özel vücut geliştirme seansı.',
    category: GoalCategory.fitness,
    difficulty: GoalDifficulty.hard,
    baseXp: 50,
  ),
  _t(
    id: 'tpl_plank_3min',
    title: 'Toplam 3 Dakika Plank',
    description: 'Toplam 3 dakika plank duruşunda bekle (setlere bölebilirsin).',
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
    title: '8 Bardak Su İç',
    description: 'Bugün 8 bardak (2 Litre) su içerek susuz kalma.',
    category: GoalCategory.health,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_healthy_meal',
    title: 'Ev Yapımı Bir Sağlıklı Öğün',
    description: 'En az bir dengeli, evde hazırlanmış öğün ye.',
    category: GoalCategory.health,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_8hr_sleep',
    title: '8 Saat Uyku',
    description: 'Bu gece en az 8 saat uyu.',
    category: GoalCategory.health,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_no_sugar_day',
    title: 'İlave Şekersiz Gün',
    description: 'Yiyeceklerde veya içeceklerde ilave şeker olmadan tam bir gün geçir.',
    category: GoalCategory.health,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_10k_steps',
    title: '10.000 Adım',
    description: '10.000 adıma (veya günlük adım hedefine) ulaş.',
    category: GoalCategory.health,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_5_veg_servings',
    title: '5 Porsiyon Meyve ve Sebze',
    description: 'Bugün en az 5 porsiyon meyve ve sebze ye.',
    category: GoalCategory.health,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_no_screens_1hr_bed',
    title: 'Uyumadan 1 Saat Önce Ekran Yok',
    description: 'Uyumadan önceki son bir saat telefon, tablet veya televizyon yok.',
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
    title: '10 Dakika Meditasyon',
    description: '10 dakikalık rehberli veya sessiz meditasyon.',
    category: GoalCategory.mind,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_gratitude_3',
    title: 'Şükrettiğin 3 Şeyi Yaz',
    description: 'Bugün şükrettiğin üç şeyi liste haline getir.',
    category: GoalCategory.mind,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_breathing_5min',
    title: '5 Dakikalık Nefes Egzersizi',
    description: '5 dakika boyunca kutu/derin nefes egzersizi.',
    category: GoalCategory.mind,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_evening_reflect_5',
    title: '5 Dakikalık Akşam Değerlendirmesi',
    description: 'Düşün: Bir galibiyet, bir ders, yarın için bir niyet.',
    category: GoalCategory.mind,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_digital_detox_1hr',
    title: '1 Saat Dijital Detoks',
    description: 'Tam bir saat boyunca telefon veya sosyal medya yok.',
    category: GoalCategory.mind,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_journal_15min',
    title: '15 Dakika Günlük Yazma',
    description: 'Günün veya hislerin hakkında 15 dakika boyunca yazı yaz.',
    category: GoalCategory.mind,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_body_scan_10',
    title: '10 Dakikalık Vücut Taraması',
    description: '10 dakika boyunca vücudunu zihnen tara.',
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
    title: '30 Dakika Kitap Oku',
    description: 'En az 30 dakika boyunca bir kitap veya makale oku.',
    category: GoalCategory.study,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_read_20_pages',
    title: '20 Sayfa Oku',
    description: 'Bir kitabın veya ders kitabının 20 sayfasını oku.',
    category: GoalCategory.study,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_flashcards_review',
    title: 'Bir Çalışma Kartı Destesini Gözden Geçir',
    description: 'Bir tam çalışma kartı desteğini tekrar et.',
    category: GoalCategory.study,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_1hr_deep_work',
    title: '1 Saat Derin Çalışma',
    description: 'Kesintisiz, odaklanılmış bir saatlik çalışma.',
    category: GoalCategory.study,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_solve_20_questions',
    title: '20 Pratik Sorusu Çöz',
    description: '20 alıştırma veya pratik sorusunu tamamla.',
    category: GoalCategory.study,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_2hr_study_block',
    title: '2 Saatlik Çalışma Bloğu',
    description: 'Bir konuya veya projeye odaklanmış iki saat.',
    category: GoalCategory.study,
    difficulty: GoalDifficulty.hard,
    baseXp: 50,
  ),
  _t(
    id: 'tpl_summarize_chapter',
    title: 'Bir Bölümü Özetle',
    description: 'Bir bölümü oku ve kısa bir özetini çıkar.',
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
    title: 'Yarını Planla: İlk 3 Öncelik',
    description: 'Yarın için en önemli 3 önceliğini yaz.',
    category: GoalCategory.work,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_inbox_zero',
    title: 'Gelen Kutusunu Sıfırla',
    description: 'E-posta gelen kutunu sıfırla (veya belirlenen bir sınıra indir).',
    category: GoalCategory.work,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_complete_top_3',
    title: 'En Önemli 3 Görevi Tamamla',
    description: 'Günün en yüksek öncelikli 3 görevini bitir.',
    category: GoalCategory.work,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_pomodoro_4',
    title: '4 Pomodoro Seansı',
    description: '5 dakikalık molalarla dört adet 25 dakikalık odaklanma seansı.',
    category: GoalCategory.work,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_no_meeting_deep_day',
    title: 'Toplantısız Derin Çalışma Günü',
    description: 'Hiç toplantı olmadan sadece odaklanmış çalışmayla geçen gün.',
    category: GoalCategory.work,
    difficulty: GoalDifficulty.hard,
    baseXp: 50,
  ),
  _t(
    id: 'tpl_finish_one_project_milestone',
    title: 'Bir Proje Aşamasını Tamamla',
    description: 'Mevcut projende belirlenmiş bir dönüm noktasını tamamla.',
    category: GoalCategory.work,
    difficulty: GoalDifficulty.hard,
    baseXp: 50,
  ),
  _t(
    id: 'tpl_reply_all_pending',
    title: 'Tüm Bekleyen Mesajlara Yanıt Ver',
    description: 'Tüm bekleyen e-postalara veya mesajlara yanıt ver.',
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
    title: '1 Saat Telefonsuz',
    description: 'Bir odaklanmış saat boyunca telefon veya bildirim yok.',
    category: GoalCategory.focus,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_log_distractions',
    title: 'Dikkat Dağıtıcıları Not Et',
    description: 'Dikkatini dağıtan şeyleri oldukları anda not al ve tekrar odaklan.',
    category: GoalCategory.focus,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_single_task_45',
    title: '45 Dakikalık Tek Görev Bloğu',
    description: 'Başka hiçbir şeye geçmeden 45 dakika boyunca tek bir görevde çalış.',
    category: GoalCategory.focus,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_3_pomodoro',
    title: '3 Pomodoro Seansı',
    description: 'Kısa molalarla üç adet 25 dakikalık odaklanma seansı.',
    category: GoalCategory.focus,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_90min_deep_work',
    title: '90 Dakikalık Derin Çalışma',
    description: 'Kesintisiz 90 dakikalık derin çalışma seansı.',
    category: GoalCategory.focus,
    difficulty: GoalDifficulty.hard,
    baseXp: 50,
  ),
  _t(
    id: 'tpl_no_social_media_day',
    title: 'Bütün Gün Sosyal Medya Yok',
    description: 'Bütün gün sosyal medya uygulamasını sıfır kullanım.',
    category: GoalCategory.focus,
    difficulty: GoalDifficulty.hard,
    baseXp: 50,
  ),
  _t(
    id: 'tpl_first_hour_no_email',
    title: 'İlk Saat: E-posta Yok',
    description: 'İşin ilk saatinde e-postalarını kontrol etme.',
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
    title: 'Bugün Tüm Harcamaları Takip Et',
    description: 'Gün içindeki her harcamayı gelir/gider listene kaydet.',
    category: GoalCategory.finance,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_check_balance',
    title: 'Hesap Bakiyesini Kontrol Et',
    description: 'Ana hesap bakiyeni ve bekleyen işlemleri gözden geçir.',
    category: GoalCategory.finance,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_no_impulse_buy',
    title: 'Dürtüsel Alışveriş Yok',
    description: 'Bugün planlanmamış herhangi bir satın alma yapmaktan kaçın.',
    category: GoalCategory.finance,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_review_budget',
    title: 'Aylık Bütçeyi Gözden Geçir',
    description: 'Bu ayın bütçesini incele ve gerekli ayarlamaları yap.',
    category: GoalCategory.finance,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_save_fixed_amount',
    title: 'Tasarrufa Sabit Miktar Aktar',
    description: 'Bugün tasarruf hesabına belirli bir miktar para aktar.',
    category: GoalCategory.finance,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_cancel_one_subscription',
    title: 'Bir Gereksiz Aboneliği İptal Et',
    description: 'Artık kullanmadığın en az bir aboneliği iptal et.',
    category: GoalCategory.finance,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_plan_week_meals',
    title: 'Haftalık Yemekleri Planla',
    description: 'Haftanın yemeklerini belirli bir bütçeyi göz önünde bulundurarak planla.',
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
    title: 'Yeni Bir Şey Öğren (15 dk)',
    description: 'En az 15 dakika yeni bir şey oku, izle veya pratik yap.',
    category: GoalCategory.selfGrowth,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_journal_5min',
    title: '5 Dakika Günlük Tutma',
    description: 'Günün veya hedeflerin hakkında kısa bir günlük yazısı yaz.',
    category: GoalCategory.selfGrowth,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_set_daily_intention',
    title: 'Günlük Niyet Belirle',
    description: 'Sabahleyin gün için net bir niyet veya odak belirle.',
    category: GoalCategory.selfGrowth,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_skill_practice_20',
    title: '20 Dakikalık Yetenek Pratiği',
    description: 'Geliştirmek istediğin bir yetenek üzerine 20 dakika çalış.',
    category: GoalCategory.selfGrowth,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_weekly_review',
    title: 'Haftalık Değerlendirme',
    description: 'Haftayı gözden geçir: galibiyetler, öğrenilenler, yeni öncelikler.',
    category: GoalCategory.selfGrowth,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_one_hard_conversation',
    title: 'Zor Bir Konuşma Yap',
    description: 'Kaçındığın o konuşmayı saygı çerçevesinde yap.',
    category: GoalCategory.selfGrowth,
    difficulty: GoalDifficulty.hard,
    baseXp: 50,
  ),
  _t(
    id: 'tpl_feedback_request',
    title: 'Bir Kişiden Geri Bildirim İste',
    description:
        'Bir kişiden işin veya davranışların hakkında spesifik geri bildirim iste.',
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
    title: 'Yemekte Telefon Yok',
    description: 'Bugün hiçbir öğün sırasında masada telefon olmasın.',
    category: GoalCategory.digitalDetox,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_notifications_off_2hr',
    title: 'Bildirimler 2 Saat Kapalı',
    description: 'Önemsiz bildirimleri 2 saatliğine kapat.',
    category: GoalCategory.digitalDetox,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_no_social_30min',
    title: '30 Dakika Sosyal Medya Yok',
    description: 'En az 30 dakika sosyal medya uygulamalarından uzak dur.',
    category: GoalCategory.digitalDetox,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_screen_free_evening_1hr',
    title: 'Akşam 1 Saat Ekransız',
    description: 'Uyumadan önceki son 1 saat hiçbir ekrana bakma.',
    category: GoalCategory.digitalDetox,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_phone_in_other_room',
    title: 'Telefon Başka Odada (2 saat)',
    description: 'Telefonunu 2 saat boyunca başka bir odada tut.',
    category: GoalCategory.digitalDetox,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_digital_sabbath_half_day',
    title: 'Yarım Gün Dijital Diyet',
    description:
        'Günün yarısında (örn. sabah/öğleden sonra) kişisel cihaz kullanma.',
    category: GoalCategory.digitalDetox,
    difficulty: GoalDifficulty.hard,
    baseXp: 50,
  ),
  _t(
    id: 'tpl_one_app_deleted',
    title: 'Zaman Çalan Bir Uygulamayı Sil',
    description:
        'Dikkatini çalan o uygulamayı tamamen sil (sonradan geri yükleyebilirsin).',
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
    title: 'Samimi Bir İltifat Et',
    description: 'Bugün tanıdığın birine içten bir iltifatta bulun.',
    category: GoalCategory.social,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_reach_out_one_person',
    title: 'Birisiyle İletişime Geç',
    description:
        'Message or call one friend or family member you haven\'t talked to lately.',
    category: GoalCategory.social,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_ask_how_they_are',
    title: 'Nasılsın Diye Sor ve Dinle',
    description: 'Birine nasıl olduğunu sor ve acele etmeden dinle.',
    category: GoalCategory.social,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_one_face_to_face_meet',
    title: 'Yüz Yüze Bir Buluşma',
    description: 'Bir kişiyle yüz yüze buluş (kahve, yürüyüş veya yemek).',
    category: GoalCategory.social,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_say_no_one_request',
    title: 'Bir İsteğe Hayır De',
    description:
        'Politely decline one request that doesn\'t align with your priorities.',
    category: GoalCategory.social,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_host_small_gathering',
    title: 'Küçük Bir Buluşma Düzenle',
    description: 'Basit bir buluşma için kendi yerine 2-4 kişiyi davet et.',
    category: GoalCategory.social,
    difficulty: GoalDifficulty.hard,
    baseXp: 50,
  ),
  _t(
    id: 'tpl_thank_you_note',
    title: 'Bir Teşekkür Notu Gönder',
    description: 'Kısa bir teşekkür notu veya mesajı yazıp gönder.',
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
    title: '10 Dakika Karalama',
    description: '10 dakika boyunca özgürce çizim, karalama ya da eskiz yap.',
    category: GoalCategory.creativity,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_write_300_words',
    title: '300 Kelime Yaz',
    description: 'Herhangi bir konuda (günlük, hikaye veya fikir) 300 kelime yaz.',
    category: GoalCategory.creativity,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_one_photo_project',
    title: 'Niyetle 5 Fotoğraf Çek',
    description: 'Spesifik bir tema veya proje aklında olacak şekilde 5 planlı fotoğraf çek.',
    category: GoalCategory.creativity,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_30min_creative_session',
    title: '30 Dakikalık Yaratıcı Seans',
    description:
        'Herhangi bir yaratıcı projeye (müzik, yazı, sanat, el işi) 30 dakika ayır.',
    category: GoalCategory.creativity,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_finish_one_creative_piece',
    title: 'Küçük Bir Yaratıcı Eseri Bitir',
    description:
        'Küçük bir yaratıcı işi tamamla (örn. bir çizim, bir şiir veya yazı).',
    category: GoalCategory.creativity,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_learn_one_creative_skill',
    title: 'Yeni Bir Yaratıcı Yetenek Çalış (20 dk)',
    description:
        '20 dakikanı yeni bir beceri öğrenmeye veya pratiğine ayır.',
    category: GoalCategory.creativity,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_share_creation',
    title: 'Bir Eserini Paylaş',
    description: 'Ürettiğin bir şeyi en az bir kişiyle paylaş.',
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
    title: 'Ertelemeden Uyan',
    description: 'Planladığın saatte alarma ertele tuşuna basmadan kalk.',
    category: GoalCategory.discipline,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_make_bed',
    title: 'Yatağını Topla',
    description: 'Sabah ilk olarak yatağını düzenle.',
    category: GoalCategory.discipline,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_one_thing_before_screen',
    title: 'Ekrana Bakmadan Önce Bir Görev',
    description: 'Telefona ya da ekrana bakmadan önce anlamlı bir görevi bitir.',
    category: GoalCategory.discipline,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_stick_to_plan_meals',
    title: 'Planlanmış Öğünlere Sadık Kal',
    description: 'Yalnızca planladığın şeyleri ye (plansız atıştırmalıklar veya siparişler yok).',
    category: GoalCategory.discipline,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_no_complaining_day',
    title: 'Şikayet Etmeme Günü',
    description: 'Şikayet etmeden tam bir gün geçir (olumluya çevir veya sessiz kal).',
    category: GoalCategory.discipline,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_same_wake_time',
    title: 'Aynı Saatte Kalk',
    description: 'Hedeflediğin uyanma saatinden itibaren en fazla 30 dakika saparak uyan.',
    category: GoalCategory.discipline,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_cold_shower_1min',
    title: '1 Dakika Soğuk Duş',
    description: 'Duşunu 1 dakika boyunca soğuk suyla bitir.',
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
    title: 'Küçük Bir Galibiyet',
    description: 'Sürekli ertelediğin küçük bir işi bitir.',
    category: GoalCategory.general,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_clean_10min',
    title: '10 Dakika Toparlama',
    description: 'Sadece 10 dakika boyunca çevreni veya bir odayı toparla.',
    category: GoalCategory.general,
    difficulty: GoalDifficulty.easy,
    baseXp: 10,
  ),
  _t(
    id: 'tpl_todo_top_1',
    title: '1 Numaralı Görevini Tamamla',
    description: 'Listendeki en önemli tek bir işi bitir.',
    category: GoalCategory.general,
    difficulty: GoalDifficulty.medium,
    baseXp: 25,
  ),
  _t(
    id: 'tpl_no_complaining',
    title: 'Şikayet Etmek Yok (Olumluya Çevir)',
    description: 'Kendini şikayet ederken yakala ve cümleni olumlu bir şekilde yeniden kur.',
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

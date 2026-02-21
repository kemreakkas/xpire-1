import 'dart:io';

void main() {
  final file = File('lib/data/content/default_goal_templates.dart');
  var content = file.readAsStringSync();

  final Map<String, String> replacements = {
    // Fitness
    "'20-Minute Morning Walk'": "'20 Dakika Sabah Yürüyüşü'",
    "'Start the day with a 20-minute walk outdoors or on a treadmill.'":
        "'Güne açık havada veya koşu bandında 20 dakikalık bir yürüyüşle başla.'",
    "'10-Minute Stretch'": "'10 Dakika Esneme'",
    "'Full-body stretching or mobility routine for 10 minutes.'":
        "'10 dakikalık tüm vücut esneme veya mobilite rutini.'",
    "'30-Minute Strength Workout'": "'30 Dakika Kuvvet Antrenmanı'",
    "'Full-body or cardio workout for 30 minutes.'":
        "'30 dakikalık tüm vücut veya kardiyo antrenmanı.'",
    "'50 Push-Ups (Total)'": "'50 Şınav (Toplam)'",
    "'Complete 50 push-ups in sets throughout the day.'":
        "'Gün içine yayarak toplam 50 şınav çek.'",
    "'5km Run'": "'5 km Koşu'",
    "'Complete a 5 km run at your own pace.'": "'Kendi hızında 5 km koş.'",
    "'60-Minute Strength Session'": "'60 Dakika Kuvvet Antrenmanı'",
    "'45–60 minute dedicated strength training session.'":
        "'45-60 dakikalık özel vücut geliştirme seansı.'",
    "'3-Minute Plank Total'": "'Toplam 3 Dakika Plank'",
    "'Hold plank for 3 minutes total (can be split into sets).'":
        "'Toplam 3 dakika plank duruşunda bekle (setlere bölebilirsin).'",

    // Health
    "'Drink 8 Glasses of Water'": "'8 Bardak Su İç'",
    "'Stay hydrated with 8 glasses (2 L) of water today.'":
        "'Bugün 8 bardak (2 Litre) su içerek susuz kalma.'",
    "'One Home-Prepared Healthy Meal'": "'Ev Yapımı Bir Sağlıklı Öğün'",
    "'Eat at least one balanced, home-prepared meal.'":
        "'En az bir dengeli, evde hazırlanmış öğün ye.'",
    "'8 Hours of Sleep'": "'8 Saat Uyku'",
    "'Get at least 8 hours of sleep tonight.'": "'Bu gece en az 8 saat uyu.'",
    "'No Added Sugar Day'": "'İlave Şekersiz Gün'",
    "'A full day without added sugar in food or drinks.'":
        "'Yiyeceklerde veya içeceklerde ilave şeker olmadan tam bir gün geçir.'",
    "'10,000 Steps'": "'10.000 Adım'",
    "'Hit 10,000 steps (or your daily step target).'":
        "'10.000 adıma (veya günlük adım hedefine) ulaş.'",
    "'5 Servings of Fruits & Vegetables'": "'5 Porsiyon Meyve ve Sebze'",
    "'Eat at least 5 servings of fruits and vegetables today.'":
        "'Bugün en az 5 porsiyon meyve ve sebze ye.'",
    "'No Screens 1 Hour Before Bed'": "'Uyumadan 1 Saat Önce Ekran Yok'",
    "'No phone, tablet, or TV for the last hour before sleep.'":
        "'Uyumadan önceki son bir saat telefon, tablet veya televizyon yok.'",

    // Mind
    "'10-Minute Meditation'": "'10 Dakika Meditasyon'",
    "'Guided or silent meditation for 10 minutes.'":
        "'10 dakikalık rehberli veya sessiz meditasyon.'",
    "'Write 3 Things You\\'re Grateful For'": "'Şükrettiğin 3 Şeyi Yaz'",
    "'List three things you are grateful for today.'":
        "'Bugün şükrettiğin üç şeyi liste haline getir.'",
    "'5-Minute Breathing Exercises'": "'5 Dakikalık Nefes Egzersizi'",
    "'Box breathing or deep breathing for 5 minutes.'":
        "'5 dakika boyunca kutu/derin nefes egzersizi.'",
    "'5-Minute Evening Reflection'": "'5 Dakikalık Akşam Değerlendirmesi'",
    "'Reflect: one win, one lesson, one intention for tomorrow.'":
        "'Düşün: Bir galibiyet, bir ders, yarın için bir niyet.'",
    "'1 Hour Digital Detox'": "'1 Saat Dijital Detoks'",
    "'No phone or social media for one full hour.'":
        "'Tam bir saat boyunca telefon veya sosyal medya yok.'",
    "'15-Minute Journaling'": "'15 Dakika Günlük Yazma'",
    "'Write for 15 minutes about your day or feelings.'":
        "'Günün veya hislerin hakkında 15 dakika boyunca yazı yaz.'",
    "'10-Minute Body Scan'": "'10 Dakikalık Vücut Taraması'",
    "'Guided or self body scan meditation for 10 minutes.'":
        "'10 dakika boyunca vücudunu zihnen tara.'",

    // Study
    "'Read 30 Minutes'": "'30 Dakika Kitap Oku'",
    "'Read a book or article for at least 30 minutes.'":
        "'En az 30 dakika boyunca bir kitap veya makale oku.'",
    "'Read 20 Pages'": "'20 Sayfa Oku'",
    "'Read 20 pages of a book or textbook.'":
        "'Bir kitabın veya ders kitabının 20 sayfasını oku.'",
    "'Review One Flashcard Deck'": "'Bir Çalışma Kartı Destesini Gözden Geçir'",
    "'Review one full deck of flashcards.'":
        "'Bir tam çalışma kartı desteğini tekrar et.'",
    "'1 Hour Deep Work'": "'1 Saat Derin Çalışma'",
    "'One uninterrupted hour of focused study or work.'":
        "'Kesintisiz, odaklanılmış bir saatlik çalışma.'",
    "'Solve 20 Practice Questions'": "'20 Pratik Sorusu Çöz'",
    "'Complete 20 practice or exercise questions.'":
        "'20 alıştırma veya pratik sorusunu tamamla.'",
    "'2-Hour Study Block'": "'2 Saatlik Çalışma Bloğu'",
    "'Two focused hours on one subject or project.'":
        "'Bir konuya veya projeye odaklanmış iki saat.'",
    "'Summarize One Chapter'": "'Bir Bölümü Özetle'",
    "'Read and write a short summary of one chapter.'":
        "'Bir bölümü oku ve kısa bir özetini çıkar.'",

    // Work
    "'Plan Tomorrow: Top 3 Priorities'": "'Yarını Planla: İlk 3 Öncelik'",
    "'Write your top 3 priorities for tomorrow.'":
        "'Yarın için en önemli 3 önceliğini yaz.'",
    "'Inbox Zero'": "'Gelen Kutusunu Sıfırla'",
    "'Clear your email inbox to zero (or to a defined threshold).'":
        "'E-posta gelen kutunu sıfırla (veya belirlenen bir sınıra indir).'",
    "'Complete Top 3 Tasks'": "'En Önemli 3 Görevi Tamamla'",
    "'Finish your top 3 priority tasks for the day.'":
        "'Günün en yüksek öncelikli 3 görevini bitir.'",
    "'4 Pomodoro Sessions'": "'4 Pomodoro Seansı'",
    "'Four 25-minute focus sessions with 5-min breaks.'":
        "'5 dakikalık molalarla dört adet 25 dakikalık odaklanma seansı.'",
    "'No-Meeting Deep Work Day'": "'Toplantısız Derin Çalışma Günü'",
    "'A full workday with no meetings, only deep work blocks.'":
        "'Hiç toplantı olmadan sadece odaklanmış çalışmayla geçen gün.'",
    "'Complete One Project Milestone'": "'Bir Proje Aşamasını Tamamla'",
    "'Finish one defined milestone on a current project.'":
        "'Mevcut projende belirlenmiş bir dönüm noktasını tamamla.'",
    "'Reply to All Pending Messages'": "'Tüm Bekleyen Mesajlara Yanıt Ver'",
    "'Reply to all pending emails or messages in your queue.'":
        "'Tüm bekleyen e-postalara veya mesajlara yanıt ver.'",

    // Focus
    "'1 Hour Phone-Free'": "'1 Saat Telefonsuz'",
    "'No phone or notifications for one focused hour.'":
        "'Bir odaklanmış saat boyunca telefon veya bildirim yok.'",
    "'Log Distractions Once'": "'Dikkat Dağıtıcıları Not Et'",
    "'Note down distractions when they happen and refocus.'":
        "'Dikkatini dağıtan şeyleri oldukları anda not al ve tekrar odaklan.'",
    "'45-Minute Single-Task Block'": "'45 Dakikalık Tek Görev Bloğu'",
    "'Work on one task only for 45 minutes with no switching.'":
        "'Başka hiçbir şeye geçmeden 45 dakika boyunca tek bir görevde çalış.'",
    "'3 Pomodoro Sessions'": "'3 Pomodoro Seansı'",
    "'Three 25-minute focused blocks with short breaks.'":
        "'Kısa molalarla üç adet 25 dakikalık odaklanma seansı.'",
    "'90-Minute Deep Work'": "'90 Dakikalık Derin Çalışma'",
    "'One uninterrupted 90-minute deep work session.'":
        "'Kesintisiz 90 dakikalık derin çalışma seansı.'",
    "'No Social Media All Day'": "'Bütün Gün Sosyal Medya Yok'",
    "'Zero social media use for the entire day.'":
        "'Bütün gün sosyal medya uygulamasını sıfır kullanım.'",
    "'First Hour: No Email'": "'İlk Saat: E-posta Yok'",
    "'Do not check email for the first hour of work.'":
        "'İşin ilk saatinde e-postalarını kontrol etme.'",

    // Finance
    "'Track All Expenses Today'": "'Bugün Tüm Harcamaları Takip Et'",
    "'Log every expense for the day in your tracker.'":
        "'Gün içindeki her harcamayı gelir/gider listene kaydet.'",
    "'Check Account Balance'": "'Hesap Bakiyesini Kontrol Et'",
    "'Review your main account balance and pending items.'":
        "'Ana hesap bakiyeni ve bekleyen işlemleri gözden geçir.'",
    "'No Impulse Purchase'": "'Dürtüsel Alışveriş Yok'",
    "'Skip any unplanned purchase today.'":
        "'Bugün planlanmamış herhangi bir satın alma yapmaktan kaçın.'",
    "'Review Monthly Budget'": "'Aylık Bütçeyi Gözden Geçir'",
    "'Review and adjust your budget for the month.'":
        "'Bu ayın bütçesini incele ve gerekli ayarlamaları yap.'",
    "'Transfer Fixed Amount to Savings'": "'Tasarrufa Sabit Miktar Aktar'",
    "'Transfer a set amount to savings today.'":
        "'Bugün tasarruf hesabına belirli bir miktar para aktar.'",
    "'Cancel One Unused Subscription'": "'Bir Gereksiz Aboneliği İptal Et'",
    "'Cancel at least one subscription you no longer use.'":
        "'Artık kullanmadığın en az bir aboneliği iptal et.'",
    "'Plan Weekly Meals (Budget)'": "'Haftalık Yemekleri Planla'",
    "'Plan meals for the week with a budget in mind.'":
        "'Haftanın yemeklerini belirli bir bütçeyi göz önünde bulundurarak planla.'",

    // Self Growth
    "'Learn One New Thing (15 min)'": "'Yeni Bir Şey Öğren (15 dk)'",
    "'Read, watch, or practice something new for 15+ minutes.'":
        "'En az 15 dakika yeni bir şey oku, izle veya pratik yap.'",
    "'5-Minute Journaling'": "'5 Dakika Günlük Tutma'",
    "'Write a short journal entry about your day or goals.'":
        "'Günün veya hedeflerin hakkında kısa bir günlük yazısı yaz.'",
    "'Set Daily Intention'": "'Günlük Niyet Belirle'",
    "'Set one clear intention for the day in the morning.'":
        "'Sabahleyin gün için net bir niyet veya odak belirle.'",
    "'20-Minute Skill Practice'": "'20 Dakikalık Yetenek Pratiği'",
    "'Practice a skill you want to improve for 20 minutes.'":
        "'Geliştirmek istediğin bir yetenek üzerine 20 dakika çalış.'",
    "'Weekly Review'": "'Haftalık Değerlendirme'",
    "'Review the week: wins, learnings, next week priorities.'":
        "'Haftayı gözden geçir: galibiyetler, öğrenilenler, yeni öncelikler.'",
    "'One Difficult Conversation'": "'Zor Bir Konuşma Yap'",
    "'Have one conversation you\\'ve been avoiding (respectful).'":
        "'Kaçındığın o konuşmayı saygı çerçevesinde yap.'",
    "'Request Feedback From One Person'": "'Bir Kişiden Geri Bildirim İste'",
    "'Ask one person for specific feedback on your work or behavior.'":
        "'Bir kişiden işin veya davranışların hakkında spesifik geri bildirim iste.'",

    // Digital Detox
    "'No Phone During Meals'": "'Yemekte Telefon Yok'",
    "'No phone at the table during any meal today.'":
        "'Bugün hiçbir öğün sırasında masada telefon olmasın.'",
    "'Notifications Off for 2 Hours'": "'Bildirimler 2 Saat Kapalı'",
    "'Turn off non-essential notifications for 2 hours.'":
        "'Önemsiz bildirimleri 2 saatliğine kapat.'",
    "'No Social Media for 30 Minutes'": "'30 Dakika Sosyal Medya Yok'",
    "'No social media apps for 30 minutes (or more).'":
        "'En az 30 dakika sosyal medya uygulamalarından uzak dur.'",
    "'1-Hour Screen-Free Evening'": "'Akşam 1 Saat Ekransız'",
    "'No screens for the last hour before bed.'":
        "'Uyumadan önceki son 1 saat hiçbir ekrana bakma.'",
    "'Phone in Another Room (2 hr)'": "'Telefon Başka Odada (2 saat)'",
    "'Keep your phone in another room for 2 hours.'":
        "'Telefonunu 2 saat boyunca başka bir odada tut.'",
    "'Half-Day Digital Sabbath'": "'Yarım Gün Dijital Diyet'",
    "'No personal devices for half the day (e.g. morning or afternoon).'":
        "'Günün yarısında (örn. sabah/öğleden sonra) kişisel cihaz kullanma.'",
    "'Delete One Time-Wasting App'": "'Zaman Çalan Bir Uygulamayı Sil'",
    "'Remove one app that drains your attention (can reinstall later).'":
        "'Dikkatini çalan o uygulamayı tamamen sil (sonradan geri yükleyebilirsin).'",

    // Social
    "'Give One Genuine Compliment'": "'Samimi Bir İltifat Et'",
    "'Give one sincere compliment to someone today.'":
        "'Bugün tanıdığın birine içten bir iltifatta bulun.'",
    "'Reach Out to One Person'": "'Birisiyle İletişime Geç'",
    "\"Message or call one friend or family member you haven't talked to lately.\"":
        "'Uzun zamandır konuşmadığın bir yakınına veya ailene yaz veya ara.'",
    "'Ask \"How Are You?\" and Listen'": "'Nasılsın Diye Sor ve Dinle'",
    "'Ask someone how they are and listen without rushing.'":
        "'Birine nasıl olduğunu sor ve acele etmeden dinle.'",
    "'One Face-to-Face Meetup'": "'Yüz Yüze Bir Buluşma'",
    "'Meet one person face-to-face (coffee, walk, or meal).'":
        "'Bir kişiyle yüz yüze buluş (kahve, yürüyüş veya yemek).'",
    "'Say No to One Request'": "'Bir İsteğe Hayır De'",
    "\"Politely decline one request that doesn't align with your priorities.\"":
        "'Önceliklerinle uyuşmayan bir isteği kibarca reddet.'",
    "'Host a Small Gathering'": "'Küçük Bir Buluşma Düzenle'",
    "'Host 2–4 people for a simple get-together.'":
        "'Basit bir buluşma için kendi yerine 2-4 kişiyi davet et.'",
    "'Send One Thank-You Note'": "'Bir Teşekkür Notu Gönder'",
    "'Write and send a short thank-you note (text or card).'":
        "'Kısa bir teşekkür notu veya mesajı yazıp gönder.'",

    // Creativity
    "'10 Minutes of Doodling or Sketching'": "'10 Dakika Karalama'",
    "'Spend 10 minutes drawing, doodling, or sketching freely.'":
        "'10 dakika boyunca özgürce çizim, karalama ya da eskiz yap.'",
    "'Write 300 Words'": "'300 Kelime Yaz'",
    "'Write 300 words (journal, story, or idea).'":
        "'Herhangi bir konuda (günlük, hikaye veya fikir) 300 kelime yaz.'",
    "'Take 5 Intentional Photos'": "'Niyetle 5 Fotoğraf Çek'",
    "'Take 5 photos with a specific theme or project in mind.'":
        "'Spesifik bir tema veya proje aklında olacak şekilde 5 planlı fotoğraf çek.'",
    "'30-Minute Creative Session'": "'30 Dakikalık Yaratıcı Seans'",
    "'30 minutes on any creative project (music, writing, art, craft).'":
        "'Herhangi bir yaratıcı projeye (müzik, yazı, sanat, el işi) 30 dakika ayır.'",
    "'Finish One Small Creative Piece'": "'Küçük Bir Yaratıcı Eseri Bitir'",
    "'Complete one small creative work (e.g. one drawing, one short piece).'":
        "'Küçük bir yaratıcı işi tamamla (örn. bir çizim, bir şiir veya yazı).'",
    "'Practice One New Creative Skill (20 min)'":
        "'Yeni Bir Yaratıcı Yetenek Çalış (20 dk)'",
    "'Spend 20 minutes learning or practicing a new creative skill.'":
        "'20 dakikanı yeni bir beceri öğrenmeye veya pratiğine ayır.'",
    "'Share One Creation'": "'Bir Eserini Paylaş'",
    "'Share one thing you created with at least one person.'":
        "'Ürettiğin bir şeyi en az bir kişiyle paylaş.'",

    // Discipline
    "'Wake Up Without Snooze'": "'Ertelemeden Uyan'",
    "'Get up at your planned time without hitting snooze.'":
        "'Planladığın saatte alarma ertele tuşuna basmadan kalk.'",
    "'Make Your Bed'": "'Yatağını Topla'",
    "'Make your bed first thing in the morning.'":
        "'Sabah ilk olarak yatağını düzenle.'",
    "'One Task Before First Screen'": "'Ekrana Bakmadan Önce Bir Görev'",
    "'Complete one meaningful task before opening any screen.'":
        "'Telefona ya da ekrana bakmadan önce anlamlı bir görevi bitir.'",
    "'Stick to Planned Meals'": "'Planlanmış Öğünlere Sadık Kal'",
    "'Eat only what you planned (no unplanned snacks or orders).'":
        "'Yalnızca planladığın şeyleri ye (plansız atıştırmalıklar veya siparişler yok).'",
    "'No Complaining Day'": "'Şikayet Etmeme Günü'",
    "'Go one day without complaining (reframe or stay silent).'":
        "'Şikayet etmeden tam bir gün geçir (olumluya çevir veya sessiz kal).'",
    "'Wake at Same Time'": "'Aynı Saatte Kalk'",
    "'Wake up within 30 minutes of your target wake time.'":
        "'Hedeflediğin uyanma saatinden itibaren en fazla 30 dakika saparak uyan.'",
    "'1-Minute Cold Shower'": "'1 Dakika Soğuk Duş'",
    "'End your shower with 1 minute of cold water.'":
        "'Duşunu 1 dakika boyunca soğuk suyla bitir.'",

    // General
    "'One Small Win'": "'Küçük Bir Galibiyet'",
    "'Complete one small task you\\'ve been putting off.'":
        "'Sürekli ertelediğin küçük bir işi bitir.'",
    "'10-Minute Tidy'": "'10 Dakika Toparlama'",
    "'Tidy or clean one area for 10 minutes.'":
        "'Sadece 10 dakika boyunca çevreni veya bir odayı toparla.'",
    "'Complete Your #1 Todo'": "'1 Numaralı Görevini Tamamla'",
    "'Finish the single most important item on your list.'":
        "'Listendeki en önemli tek bir işi bitir.'",
    "'No Complaining (Reframe Once)'": "'Şikayet Etmek Yok (Olumluya Çevir)'",
    "'Catch yourself complaining and reframe it once positively.'":
        "'Kendini şikayet ederken yakala ve cümleni olumlu bir şekilde yeniden kur.'",
  };

  for (final entry in replacements.entries) {
    content = content.replaceAll(entry.key, entry.value);
  }

  file.writeAsStringSync(content);
}

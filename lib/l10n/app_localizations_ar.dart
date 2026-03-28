// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'فرز الأحلام';

  @override
  String get play => 'العب';

  @override
  String get levels => 'المستويات';

  @override
  String get room => 'الغرفة';

  @override
  String get multiplayer => 'لاعبين';

  @override
  String get dailyChallenge => 'تحدي اليوم';

  @override
  String get muteSound => 'كتم الصوت';

  @override
  String get unmuteSound => 'تشغيل الصوت';

  @override
  String get decorShop => 'متجر الديكور';

  @override
  String get howToPlay => 'كيف تلعب';

  @override
  String get quitGame => 'الخروج';

  @override
  String get quitGameDesc =>
      'سيتم فقدان تقدمك. هل أنت متأكد أنك تريد المغادرة؟';

  @override
  String get quitGameAction => 'خروج';

  @override
  String get keepPlaying => 'متابعة اللعب';

  @override
  String get selectLevel => 'اختر المستوى';

  @override
  String get level => 'المستوى';

  @override
  String get renovateRoom => 'تجديد الغرفة';

  @override
  String notEnoughCoins(int cost) {
    return 'عملات غير كافية! تحتاج $cost.';
  }

  @override
  String get owned => 'مملوك';

  @override
  String get equipped => 'مجهز';

  @override
  String get gameOver => 'انتهت اللعبة';

  @override
  String wins(String player) {
    return '$player فاز!';
  }

  @override
  String time(String time) {
    return 'الوقت: $time';
  }

  @override
  String get backToMenu => 'العودة للقائمة';

  @override
  String get rematch => 'إعادة';

  @override
  String get vsBattle => 'معركة 1 ضد 1';

  @override
  String sentPenalty(String player) {
    return '$player أرسل عقوبة!';
  }

  @override
  String frozeOpponent(String attacker, String victim) {
    return '$attacker جمد $victim!';
  }

  @override
  String get freezeOpponent => 'تجميد الخصم';

  @override
  String levelComplete(String time) {
    return 'اكتمل المستوى في $time';
  }

  @override
  String get nextLevel => 'المستوى التالي';

  @override
  String get dreamSorted => 'تم الفرز!';

  @override
  String get notifDailyTitle => '🎁 مكافأتك اليومية جاهزة!';

  @override
  String get notifDailyBody => 'مكافأتك اليومية بانتظارك. تعال واستلمها!';

  @override
  String get rewardBase => 'أساسي';

  @override
  String get rewardUndoBonus => 'مكافأة التراجع';

  @override
  String get rewardTimeBonus => 'مكافأة الوقت';

  @override
  String get rewardComboBonus => 'مكافأة التسلسل';

  @override
  String levelTitle(int level) {
    return 'المستوى $level';
  }

  @override
  String get menu => 'القائمة';

  @override
  String get tapToPick => 'اضغط على الأنبوب لالتقاط الكرة.';

  @override
  String get tapToDrop => 'اضغط على أنبوب آخر لإسقاطها.';

  @override
  String get sameColorStack => 'يمكنك فقط وضع كرات من نفس اللون.';

  @override
  String get sortToWin => 'رتب جميع الكرات المتشابهة في أنبوب واحد للفوز!';

  @override
  String get gotIt => 'فهمت!';

  @override
  String get subtitle => 'لعبة ألغاز مريحة';

  @override
  String get multiplayerMode => 'وضع اللاعبين';

  @override
  String get challengeFriends => 'تحدى أصدقاءك!';

  @override
  String get createRoom => 'إنشاء غرفة';

  @override
  String get joinRoom => 'انضم إلى غرفة';

  @override
  String get localVs => 'محلي (شاشة مقسمة)';

  @override
  String get comingSoon => 'الخلفية قادمة قريبا!';

  @override
  String get settings => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get changeLanguage => 'تغيير اللغة';

  @override
  String get sound => 'الصوت';

  @override
  String get music => 'الموسيقى';

  @override
  String get sfx => 'المؤثرات الصوتية';

  @override
  String get resetProgress => 'إعادة تعيين التقدم';

  @override
  String get about => 'حول';

  @override
  String get credits => 'الاعتمادات';

  @override
  String get resetConfirmTitle => 'إعادة تعيين التقدم بالكامل؟';

  @override
  String get resetConfirmMessage =>
      'سيؤدي هذا إلى حذف جميع عملاتك وعناصرك وتقدم المستوى. لا يمكن التراجع عن هذا.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get reset => 'إعادة تعيين';

  @override
  String get progressReset => 'تمت إعادة تعيين التقدم.';

  @override
  String get chooseDifficulty => 'اختر الصعوبة للعب المحلي';

  @override
  String get enterNameAndLevel => 'أدخل اسمك واختر المستوى';

  @override
  String get playerName => 'اسم اللاعب';

  @override
  String get enterRoomDetails => 'أدخل تفاصيل الغرفة للانضمام';

  @override
  String get yourName => 'اسمك';

  @override
  String get roomCodeHint => 'رمز الغرفة (مثال: ABCD)';

  @override
  String get create => 'إنشاء';

  @override
  String get join => 'انضمام';

  @override
  String get accessibility => 'سهولة الاستخدام';

  @override
  String get colorBlindMode => 'رموز عمى الألوان';

  @override
  String get perfect => 'ممتاز!';

  @override
  String get resetLevelTitle => 'إعادة تشغيل المستوى؟';

  @override
  String get resetLevelDesc => 'سيتم فقدان تقدمك وستُعاد ضبط التراجعات.';

  @override
  String get resetLevelAction => 'إعادة التشغيل';

  @override
  String get outOfUndosTitle => 'نفدت التراجعات!';

  @override
  String outOfUndosDesc(int count) {
    return 'اشترِ $count تراجعات إضافية للمتابعة.';
  }

  @override
  String buyUndos(int count, int cost) {
    return 'شراء $count تراجعات ($cost عملة)';
  }

  @override
  String watchAdFreeUndos(int count) {
    return 'شاهد إعلانًا — $count تراجعات مجانًا';
  }

  @override
  String get needHelp => 'هل تحتاج مساعدة؟';

  @override
  String get addTubeDesc => 'أضف أنبوباً فارغاً إضافياً لتسهيل حل هذا اللغز!';

  @override
  String get addTube => 'إضافة أنبوب';

  @override
  String get shuffleTitle => 'تغيير الترتيب؟';

  @override
  String get shuffleDesc =>
      'أعد ترتيب الكرات للعثور على حركات جديدة!\n(الأنابيب المكتملة تظل آمنة)';

  @override
  String shuffleAction(int cost) {
    return 'إعادة الترتيب ($cost)';
  }

  @override
  String get watchVideo => 'شاهد الفيديو';

  @override
  String get watchAd => 'شاهد الإعلان';

  @override
  String get notEnoughCoinsWatchAd =>
      'ليس لديك عملات كافية! شاهد إعلاناً بدلاً من ذلك.';

  @override
  String get watchAdPlus50Coins => 'شاهد إعلان +25 عملة';

  @override
  String get earnFreeCoins => 'شاهد فيديو قصير لتربح فوراً\n+25 عملة مجانية!';

  @override
  String get noThanks => 'لا، شكراً';

  @override
  String get needMoreCoins => 'هل تحتاج لعملات أكثر؟';

  @override
  String get needHint => 'هل تحتاج تلميحاً؟';

  @override
  String hintDesc(int cost) {
    return 'عالق؟ دع الذكاء الاصطناعي يجد لك أفضل حركة!\nالتكلفة: $cost عملة.';
  }

  @override
  String getHint(int cost) {
    return 'الحصول على التلميح ($cost)';
  }

  @override
  String get undoText => 'تراجع';

  @override
  String earnedCoins(Object amount) {
    return 'لقد حصلت على $amount ';
  }

  @override
  String get dailyRewardTitle => 'المكافأة اليومية';

  @override
  String dailyStreak(int streak) {
    return 'سلسلة $streak أيام';
  }

  @override
  String get claim => 'استلام';

  @override
  String comeBackTomorrowForCoins(int amount) {
    return 'عد غداً لتحصل على $amount عملة!';
  }

  @override
  String get decorTypeTube => 'أنابيب';

  @override
  String get decorTypeBall => 'كرات';

  @override
  String get decorTypeWall => 'جدران';

  @override
  String get decorTypeFloor => 'أرضيات';

  @override
  String get decorTypePlant => 'نباتات';

  @override
  String get decorTypeLamp => 'مصابيح';

  @override
  String get decorTypeRug => 'سجاد';

  @override
  String get decorTypePainting => 'لوحات';

  @override
  String get item_tube_default => 'قوارير زجاجية';

  @override
  String get item_tube_bamboo => 'خيزران زين';

  @override
  String get item_tube_metal => 'سبيكة سايبر';

  @override
  String get item_tube_gold_rim => 'ذهبي ملكي';

  @override
  String get item_tube_crystal => 'كريستال جليدي';

  @override
  String get item_tube_magma => 'صهر الصهارة';

  @override
  String get item_ball_default => 'كرات ناعمة';

  @override
  String get item_ball_neon => 'أجرام نيون';

  @override
  String get item_ball_emoji => 'وجوه تعبيرية';

  @override
  String get item_ball_jewel => 'جواهر ثمينة';

  @override
  String get item_ball_planets => 'كواكب المجرة';

  @override
  String get item_ball_sports => 'حزمة الرياضة';

  @override
  String get item_wall_default => 'سماء منتصف الليل';

  @override
  String get item_wall_purple => 'سديم أرجواني';

  @override
  String get item_wall_teal => 'الهاوية العميقة';

  @override
  String get item_wall_red => 'مخمل قرمزي';

  @override
  String get item_wall_grey => 'صخر داكن';

  @override
  String get item_wall_black => 'فراغ أسود';

  @override
  String get item_wall_sunset => 'غروب دافئ';

  @override
  String get item_wall_matrix => 'أخضر رقمي';

  @override
  String get item_floor_default => 'بلوط مصقول';

  @override
  String get item_floor_marble => 'رخام جليدي';

  @override
  String get item_floor_stone => 'صخر بركاني';

  @override
  String get item_floor_carpet => 'مخمل فاخر';

  @override
  String get item_floor_gold => 'أرضية مذهبة';

  @override
  String get item_floor_grass => 'متضخم';

  @override
  String get item_plant_none => 'بدون ديكور';

  @override
  String get item_plant_fern => 'سرخس الغابة';

  @override
  String get item_plant_bamboo => 'سيقان زين';

  @override
  String get item_plant_tree => 'بونساي قديم';

  @override
  String get item_plant_lotus => 'لوتس مقدس';

  @override
  String get item_plant_cactus => 'شوكة الصحراء';

  @override
  String get item_lamp_none => 'ضوء طبيعي';

  @override
  String get item_lamp_classic => 'ظل محيط';

  @override
  String get item_lamp_modern => 'لمبة بلازما';

  @override
  String get item_lamp_sun => 'وهج شمسي';

  @override
  String get item_lamp_torch => 'نار السرداب';

  @override
  String get item_lamp_neon => 'أضواء النيون';

  @override
  String get item_rug_none => 'أرضية فارغة';

  @override
  String get item_rug_shag => 'سجاد مريح';

  @override
  String get item_rug_round => 'دائرة غامضة';

  @override
  String get item_rug_geometric => 'سجادة هندسية';

  @override
  String get item_rug_royal => 'نسيج ملكي';

  @override
  String get item_rug_persian => 'فارسي عظيم';

  @override
  String get item_paint_none => 'جدار فارغ';

  @override
  String get item_paint_abstract => 'فوضى حديثة';

  @override
  String get item_paint_surreal => 'حلم سريالي';

  @override
  String get item_paint_portrait => 'سلف نبيل';

  @override
  String get item_paint_landscape => 'قمة الجبل';

  @override
  String get item_paint_starry => 'كون عميق';

  @override
  String get shareApp => 'مشاركة التطبيق';

  @override
  String get removeAds => 'إزالة الإعلانات';

  @override
  String get removeAdsPurchased => 'تمت إزالة الإعلانات ✓';

  @override
  String get restorePurchases => 'استعادة المشتريات';

  @override
  String get supportDeveloper => 'ادعم المطوّر';

  @override
  String get tipSmall => 'تبرع صغير  \$0.99';

  @override
  String get tipMedium => 'تبرع متوسط  \$2.99';

  @override
  String get tipLarge => 'تبرع كبير  \$4.99';

  @override
  String get purchaseSuccess => 'تمت عملية الشراء بنجاح! شكراً جزيلاً 🙏';

  @override
  String get purchaseFailed => 'فشلت عملية الشراء. يرجى المحاولة مجدداً.';

  @override
  String get purchasePending => 'جارٍ معالجة الشراء…';

  @override
  String get premium => 'بريميوم';

  @override
  String get support => 'الدعم';

  @override
  String get rateApp => 'قيّم التطبيق';

  @override
  String get rateNow => 'قيّم الآن';

  @override
  String get rateAppDesc =>
      'هل تستمتع باللعبة؟ قيّمنا لتساعد الآخرين على اكتشافها!';

  @override
  String get removeAdsDesc => 'استمتع باللعب بدون إعلانات';

  @override
  String get restorePurchasesDesc => 'استرجع مشترياتك السابقة';

  @override
  String get supportDeveloperDesc => 'دعمك يساعدنا نطوّر اللعبة';
}

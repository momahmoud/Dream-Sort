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
  String get selectLevel => 'اختر المستوى';

  @override
  String get level => 'المستوى';

  @override
  String get renovateRoom => 'تجديد الغرفة';

  @override
  String notEnoughStars(int cost) {
    return 'نجوم غير كافية! تحتاج $cost.';
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
      'سيؤدي هذا إلى حذف جميع نجومك وعناصرك وتقدم المستوى. لا يمكن التراجع عن هذا.';

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
}

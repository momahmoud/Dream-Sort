// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'ड्रीम सॉर्ट';

  @override
  String get play => 'खेलें';

  @override
  String get levels => 'स्तर';

  @override
  String get room => 'कमरा';

  @override
  String get multiplayer => 'मल्टीप्लेयर';

  @override
  String get dailyChallenge => 'दैनिक चुनौती';

  @override
  String get muteSound => 'आवाज़ बंद करें';

  @override
  String get unmuteSound => 'आवाज़ चालू करें';

  @override
  String get decorShop => 'दुकान';

  @override
  String get howToPlay => 'कैसे खेलें';

  @override
  String get quitGame => 'गेम छोड़ें';

  @override
  String get quitGameDesc =>
      'आपकी प्रगति खो जाएगी। क्या आप वाकई छोड़ना चाहते हैं?';

  @override
  String get quitGameAction => 'छोड़ें';

  @override
  String get keepPlaying => 'खेलते रहें';

  @override
  String get selectLevel => 'स्तर चुनें';

  @override
  String get level => 'स्तर';

  @override
  String get renovateRoom => 'कमरे का नवीनीकरण';

  @override
  String notEnoughCoins(int cost) {
    return 'पर्याप्त सिक्के नहीं! आपको $cost चाहिए।';
  }

  @override
  String get owned => 'स्वामित्व';

  @override
  String get equipped => 'सुसज्जित';

  @override
  String get gameOver => 'गेम ओवर';

  @override
  String wins(String player) {
    return '$player जीता!';
  }

  @override
  String time(String time) {
    return 'समय: $time';
  }

  @override
  String get backToMenu => 'मेनू पर वापस';

  @override
  String get rematch => 'दोबारा खेलें';

  @override
  String get vsBattle => '1 बनाम 1 लड़ाई';

  @override
  String sentPenalty(String player) {
    return '$player ने जुर्माना भेजा!';
  }

  @override
  String frozeOpponent(String attacker, String victim) {
    return '$attacker ने $victim को freez किया!';
  }

  @override
  String get freezeOpponent => 'प्रतिद्वंद्वी को फ्रीज करें';

  @override
  String levelComplete(String time) {
    return 'स्तर $time में पूरा हुआ';
  }

  @override
  String get nextLevel => 'अगला स्तर';

  @override
  String get dreamSorted => 'सपना छांटा गया!';

  @override
  String get notifDailyTitle => '🎁 आपका दैनिक बोनस तैयार है!';

  @override
  String get notifDailyBody =>
      'आपका दैनिक इनाम इंतज़ार कर रहा है। आकर ले जाएं!';

  @override
  String get rewardBase => 'आधार';

  @override
  String get rewardUndoBonus => 'अनडू बोनस';

  @override
  String get rewardTimeBonus => 'समय बोनस';

  @override
  String get rewardComboBonus => 'कॉम्बो बोनस';

  @override
  String levelTitle(int level) {
    return 'स्तर $level';
  }

  @override
  String get menu => 'मेनू';

  @override
  String get tapToPick => 'शीर्ष गेंद लेने के लिए ट्यूब पर टैप करें।';

  @override
  String get tapToDrop => 'इसे गिराने के लिए दूसरी ट्यूब पर टैप करें।';

  @override
  String get sameColorStack => 'आप केवल एक ही रंग की गेंदें स्टैक कर सकते हैं।';

  @override
  String get sortToWin =>
      'जीतने के लिए सभी समान रंग की गेंदों को एक ट्यूब में सॉर्ट करें!';

  @override
  String get gotIt => 'समझ गया!';

  @override
  String get subtitle => 'एक आरामदायक पहेली गेम';

  @override
  String get multiplayerMode => 'मल्टीप्लेयर मोड';

  @override
  String get challengeFriends => 'अपने दोस्तों को चुनौती दें!';

  @override
  String get createRoom => 'कमरा बनाएँ';

  @override
  String get joinRoom => 'कमरे में शामिल हों';

  @override
  String get localVs => 'स्थानीय बनाम (स्प्लिट स्क्रीन)';

  @override
  String get comingSoon => 'मल्टीप्लेयर बैकएंड जल्द ही आ रहा है!';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get language => 'भाषा';

  @override
  String get changeLanguage => 'भाषा बदलें';

  @override
  String get sound => 'आवाज़';

  @override
  String get music => 'संगीत';

  @override
  String get sfx => 'ध्वनि प्रभाव';

  @override
  String get resetProgress => 'प्रगति रीसेट करें';

  @override
  String get about => 'के बारे में';

  @override
  String get credits => 'क्रेडिट';

  @override
  String get resetConfirmTitle => 'सभी प्रगति रीसेट करें?';

  @override
  String get resetConfirmMessage =>
      'यह आपके सभी सिक्के, आइटम और स्तर प्रगति हटा देगा। इसे पूर्ववत नहीं किया जा सकता।';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get reset => 'रीसेट करें';

  @override
  String get progressReset => 'प्रगति रीसेट हो गई है।';

  @override
  String get chooseDifficulty => 'स्थानीय बनाम के लिए कठिनाई चुनें';

  @override
  String get enterNameAndLevel => 'अपना नाम दर्ज करें और स्तर चुनें';

  @override
  String get playerName => 'खिलाड़ी का नाम';

  @override
  String get enterRoomDetails => 'शामिल होने के लिए कमरे का विवरण दर्ज करें';

  @override
  String get yourName => 'आपका नाम';

  @override
  String get roomCodeHint => 'कमरा कोड (उदा. ABCD)';

  @override
  String get create => 'बनाएँ';

  @override
  String get join => 'शामिल हों';

  @override
  String get accessibility => 'सरल उपयोग';

  @override
  String get colorBlindMode => 'कलर-ब्लाइंड प्रतीक';

  @override
  String get perfect => 'उत्तम!';

  @override
  String get resetLevelTitle => 'स्तर फिर से शुरू करें?';

  @override
  String get resetLevelDesc => 'आपकी प्रगति खो जाएगी और अनडू रीसेट हो जाएंगे।';

  @override
  String get resetLevelAction => 'फिर से शुरू करें';

  @override
  String get outOfUndosTitle => 'अनडू समाप्त!';

  @override
  String outOfUndosDesc(int count) {
    return 'जारी रखने के लिए $count और अनडू खरीदें।';
  }

  @override
  String buyUndos(int count, int cost) {
    return '$count अनडू खरीदें ($cost सिक्के)';
  }

  @override
  String watchAdFreeUndos(int count) {
    return 'विज्ञापन देखें — $count मुफ्त अनडू';
  }

  @override
  String get needHelp => 'मदद चाहिए?';

  @override
  String get addTubeDesc =>
      'इस पहेली को आसान बनाने के लिए\nएक अतिरिक्त खाली ट्यूब जोड़ें!';

  @override
  String get addTube => 'ट्यूब जोड़ें';

  @override
  String get shuffleTitle => 'फेरबदल?';

  @override
  String get shuffleDesc =>
      'नई चाल खोजने के लिए गेंदों को फिर से व्यवस्थित करें!\n(पूरी हुई ट्यूब सुरक्षित रहती हैं)';

  @override
  String shuffleAction(int cost) {
    return 'फेरबदल ($cost)';
  }

  @override
  String get watchVideo => 'वीडियो देखें';

  @override
  String get watchAd => 'विज्ञापन देखें';

  @override
  String get notEnoughCoinsWatchAd =>
      'पर्याप्त सिक्के नहीं! इसके बजाय विज्ञापन देखें।';

  @override
  String get watchAdPlus50Coins => 'वीडियो देखें +25 सिक्के';

  @override
  String get earnFreeCoins =>
      'तुरंत जीतने के लिए एक छोटा वीडियो देखें\n+25 मुफ्त सिक्के!';

  @override
  String get noThanks => 'नहीं, धन्यवाद';

  @override
  String get needMoreCoins => 'और सिक्के चाहिए?';

  @override
  String get needHint => 'कुछ संकेत चाहिए?';

  @override
  String hintDesc(int cost) {
    return 'फंस गए? AI को आपके लिए सबसे अच्छी चाल खोजने दें!\nलागत: $cost सिक्के।';
  }

  @override
  String getHint(int cost) {
    return 'संकेत प्राप्त ($cost)';
  }

  @override
  String get undoText => 'पूर्ववत';

  @override
  String earnedCoins(Object amount) {
    return 'आपने अर्जित किया $amount ';
  }

  @override
  String get dailyRewardTitle => 'दैनिक इनाम';

  @override
  String dailyStreak(int streak) {
    return 'दिन $streak लकीर';
  }

  @override
  String get claim => 'प्राप्त करें';

  @override
  String comeBackTomorrowForCoins(int amount) {
    return 'कल $amount सिक्के पाने के लिए वापस आएं!';
  }

  @override
  String get decorTypeTube => 'ट्यूब';

  @override
  String get decorTypeBall => 'गेंद';

  @override
  String get decorTypeWall => 'दीवारें';

  @override
  String get decorTypeFloor => 'फर्श';

  @override
  String get decorTypePlant => 'पौधे';

  @override
  String get decorTypeLamp => 'लैंप';

  @override
  String get decorTypeRug => 'कालीन';

  @override
  String get decorTypePainting => 'कला';

  @override
  String get item_tube_default => 'कांच की शीशियां';

  @override
  String get item_tube_bamboo => 'जेन बांस';

  @override
  String get item_tube_metal => 'साइबर मिश्र धातु';

  @override
  String get item_tube_gold_rim => 'शाही सोना';

  @override
  String get item_tube_crystal => 'बर्फ का क्रिस्टल';

  @override
  String get item_tube_magma => 'मैग्मा फोर्ज';

  @override
  String get item_ball_default => 'चिकने गोले';

  @override
  String get item_ball_neon => 'नियॉन ऑर्ब्स';

  @override
  String get item_ball_emoji => 'इमोजी चेहरे';

  @override
  String get item_ball_jewel => 'कीमती गहने';

  @override
  String get item_ball_planets => 'गैलेक्सी ग्रह';

  @override
  String get item_ball_sports => 'स्पोर्ट्स';

  @override
  String get item_wall_default => 'आधी रात का आकाश';

  @override
  String get item_wall_purple => 'नेबुला पर्पल';

  @override
  String get item_wall_teal => 'गहरी खाई';

  @override
  String get item_wall_red => 'क्रिमसन मखमली';

  @override
  String get item_wall_grey => 'डार्क स्लेट';

  @override
  String get item_wall_black => 'शून्य काला';

  @override
  String get item_wall_sunset => 'गर्म सूर्यास्त';

  @override
  String get item_wall_matrix => 'बाइनरी ग्रीन';

  @override
  String get item_floor_default => 'पॉलिश ओक';

  @override
  String get item_floor_marble => 'आइस मार्बल';

  @override
  String get item_floor_stone => 'ज्वालामुखी की चट्टान';

  @override
  String get item_floor_carpet => 'आलीशान मखमली';

  @override
  String get item_floor_gold => 'सोने का फर्श';

  @override
  String get item_floor_grass => 'अतिवृद्धि';

  @override
  String get item_plant_none => 'कोई सजावट नहीं';

  @override
  String get item_plant_fern => 'वन फर्न';

  @override
  String get item_plant_bamboo => 'जेन स्टॉक्स';

  @override
  String get item_plant_tree => 'प्राचीन बोन्साई';

  @override
  String get item_plant_lotus => 'पवित्र कमल';

  @override
  String get item_plant_cactus => 'रेगिस्तान की कील';

  @override
  String get item_lamp_none => 'प्राकृतिक प्रकाश';

  @override
  String get item_lamp_classic => 'परिवेश छाया';

  @override
  String get item_lamp_modern => 'प्लाज्मा बल्ब';

  @override
  String get item_lamp_sun => 'सौर ज्वाला';

  @override
  String get item_lamp_torch => 'डंगऑन आग';

  @override
  String get item_lamp_neon => 'नियॉन वाइब्स';

  @override
  String get item_rug_none => 'नंगे फर्श';

  @override
  String get item_rug_shag => 'आरामदायक गलीचा';

  @override
  String get item_rug_round => 'रहस्यवादी सर्कल';

  @override
  String get item_rug_geometric => 'ज्यामितीय चटाई';

  @override
  String get item_rug_royal => 'रॉयल टेपेस्ट्री';

  @override
  String get item_rug_persian => 'ग्रैंड फारसी';

  @override
  String get item_paint_none => 'खाली दीवार';

  @override
  String get item_paint_abstract => 'आधुनिक अराजकता';

  @override
  String get item_paint_surreal => 'अवास्तविक सपना';

  @override
  String get item_paint_portrait => 'महान पूर्वज';

  @override
  String get item_paint_landscape => 'पर्वत शिखर';

  @override
  String get item_paint_starry => 'गहरा ब्रह्मांड';

  @override
  String get shareApp => 'ऐप शेयर करें';

  @override
  String get removeAds => 'विज्ञापन हटाएं';

  @override
  String get removeAdsPurchased => 'विज्ञापन हटा दिए ✓';

  @override
  String get restorePurchases => 'खरीदारी पुनर्स्थापित करें';

  @override
  String get supportDeveloper => 'डेवलपर को सपोर्ट करें';

  @override
  String get tipSmall => 'छोटी टिप  \$0.99';

  @override
  String get tipMedium => 'मध्यम टिप  \$2.99';

  @override
  String get tipLarge => 'बड़ी टिप  \$4.99';

  @override
  String get purchaseSuccess => 'खरीदारी सफल! धन्यवाद 🙏';

  @override
  String get purchaseFailed => 'खरीदारी विफल। कृपया पुनः प्रयास करें।';

  @override
  String get purchasePending => 'खरीदारी लंबित…';

  @override
  String get premium => 'प्रीमियम';

  @override
  String get support => 'समर्थन';

  @override
  String get rateApp => 'ऐप रेट करें';

  @override
  String get rateNow => 'अभी रेट करें';

  @override
  String get rateAppDesc => 'गेम पसंद आया? दूसरों की मदद के लिए रेट करें!';

  @override
  String get removeAdsDesc => 'बिना विज्ञापन के खेलें';

  @override
  String get restorePurchasesDesc => 'अपनी पिछली खरीदारी वापस लाएं';

  @override
  String get supportDeveloperDesc =>
      'आपका समर्थन हमें गेम बेहतर बनाने में मदद करता है';
}

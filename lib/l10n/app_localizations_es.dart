// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Clasificar Sueños';

  @override
  String get play => 'JUGAR';

  @override
  String get levels => 'NIVELES';

  @override
  String get room => 'HABITACIÓN';

  @override
  String get multiplayer => 'MULTIJUGADOR';

  @override
  String get dailyChallenge => 'RETO DIARIO';

  @override
  String get muteSound => 'Silenciar Sonido';

  @override
  String get unmuteSound => 'Activar Sonido';

  @override
  String get decorShop => 'Tienda';

  @override
  String get howToPlay => 'Cómo Jugar';

  @override
  String get quitGame => 'Salir';

  @override
  String get quitGameDesc =>
      'Se perderá tu progreso. ¿Seguro que quieres salir?';

  @override
  String get quitGameAction => 'Salir';

  @override
  String get keepPlaying => 'Seguir Jugando';

  @override
  String get selectLevel => 'Elegir Nivel';

  @override
  String get level => 'Nivel';

  @override
  String get renovateRoom => 'Renovar Habitación';

  @override
  String notEnoughCoins(int cost) {
    return '¡No hay suficientes monedas! Necesitas $cost.';
  }

  @override
  String get owned => 'EN PROPIEDAD';

  @override
  String get equipped => 'EQUIPADO';

  @override
  String get gameOver => 'FIN DEL JUEGO';

  @override
  String wins(String player) {
    return '¡$player GANA!';
  }

  @override
  String time(String time) {
    return 'Tiempo: $time';
  }

  @override
  String get backToMenu => 'Volver al Menú';

  @override
  String get rematch => 'Revancha';

  @override
  String get vsBattle => 'Batalla 1 vs 1';

  @override
  String sentPenalty(String player) {
    return '¡$player envió penalización!';
  }

  @override
  String frozeOpponent(String attacker, String victim) {
    return '¡$attacker congeló a $victim!';
  }

  @override
  String get freezeOpponent => 'Congelar Oponente';

  @override
  String levelComplete(String time) {
    return 'Nivel Completo en $time';
  }

  @override
  String get nextLevel => 'Siguiente Nivel';

  @override
  String get dreamSorted => '¡SUEÑO CLASIFICADO!';

  @override
  String get notifDailyTitle => '🎁 ¡Tu bono diario está listo!';

  @override
  String get notifDailyBody =>
      'Tu recompensa diaria te espera. ¡Ven a recogerla!';

  @override
  String get rewardBase => 'Base';

  @override
  String get rewardUndoBonus => 'Bono Deshacer';

  @override
  String get rewardTimeBonus => 'Bono Tiempo';

  @override
  String get rewardComboBonus => 'Bono Combo';

  @override
  String levelTitle(int level) {
    return 'Nivel $level';
  }

  @override
  String get menu => 'Menú';

  @override
  String get tapToPick => 'Toca un tubo para recoger la bola superior.';

  @override
  String get tapToDrop => 'Toca otro tubo para soltarla.';

  @override
  String get sameColorStack => 'Solo puedes apilar bolas del MISMO color.';

  @override
  String get sortToWin =>
      '¡Clasifica todas las bolas del mismo color en un tubo para ganar!';

  @override
  String get gotIt => '¡Entendido!';

  @override
  String get subtitle => 'Un Juego de Rompecabezas Relajante';

  @override
  String get multiplayerMode => 'Modo Multijugador';

  @override
  String get challengeFriends => '¡Desafía a tus amigos!';

  @override
  String get createRoom => 'Crear Sala';

  @override
  String get joinRoom => 'Unirse a Sala';

  @override
  String get localVs => 'VS Local (Pantalla Dividida)';

  @override
  String get comingSoon => '¡Backend multijugador próximamente!';

  @override
  String get settings => 'Ajustes';

  @override
  String get language => 'Idioma';

  @override
  String get changeLanguage => 'Cambiar Idioma';

  @override
  String get sound => 'Sonido';

  @override
  String get music => 'Música';

  @override
  String get sfx => 'Efectos';

  @override
  String get resetProgress => 'Reiniciar Progreso';

  @override
  String get about => 'Acerca de';

  @override
  String get credits => 'Créditos';

  @override
  String get resetConfirmTitle => '¿Reiniciar Todo el Progreso?';

  @override
  String get resetConfirmMessage =>
      'Esto eliminará todas tus monedas, artículos y progreso. Esto no se puede deshacer.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get reset => 'Reiniciar';

  @override
  String get progressReset => 'Se ha reiniciado el progreso.';

  @override
  String get chooseDifficulty => 'Elige la dificultad';

  @override
  String get enterNameAndLevel => 'Ingresa tu nombre y elige nivel';

  @override
  String get playerName => 'Nombre del Jugador';

  @override
  String get enterRoomDetails => 'Ingresa los detalles para unirte';

  @override
  String get yourName => 'Tu Nombre';

  @override
  String get roomCodeHint => 'Código (ej. ABCD)';

  @override
  String get create => 'Crear';

  @override
  String get join => 'Unirse';

  @override
  String get accessibility => 'Accesibilidad';

  @override
  String get colorBlindMode => 'Símbolos para Daltónicos';

  @override
  String get perfect => '¡PERFECTO!';

  @override
  String get resetLevelTitle => '¿Reiniciar nivel?';

  @override
  String get resetLevelDesc =>
      'Se perderá tu progreso y se restablecerán los deshaceres.';

  @override
  String get resetLevelAction => 'Reiniciar';

  @override
  String get outOfUndosTitle => '¡Sin deshacer!';

  @override
  String outOfUndosDesc(int count) {
    return 'Compra $count deshaceres más para continuar.';
  }

  @override
  String buyUndos(int count, int cost) {
    return 'Comprar $count deshacer ($cost monedas)';
  }

  @override
  String watchAdFreeUndos(int count) {
    return 'Ver anuncio — $count deshacer gratis';
  }

  @override
  String get needHelp => '¿Necesitas Ayuda?';

  @override
  String get addTubeDesc =>
      '¡Agrega un tubo vacío adicional\npara facilitar este rompecabezas!';

  @override
  String get addTube => 'Agregar Tubo';

  @override
  String get shuffleTitle => '¿Mezclar?';

  @override
  String get shuffleDesc =>
      '¡Reorganiza las bolas para encontrar nuevos movimientos!\n(Los tubos completados se mantienen)';

  @override
  String shuffleAction(int cost) {
    return 'Mezclar ($cost)';
  }

  @override
  String get watchVideo => 'Ver Video';

  @override
  String get watchAd => 'Ver Anuncio';

  @override
  String get notEnoughCoinsWatchAd =>
      '¡No hay suficientes monedas! Mira un anuncio.';

  @override
  String get watchAdPlus50Coins => 'Ver Anuncio +25';

  @override
  String get earnFreeCoins =>
      '¡Mira un video corto para ganar\n+25 Monedas Gratis al instante!';

  @override
  String get noThanks => 'No, gracias';

  @override
  String get needMoreCoins => '¿Necesitas Más Monedas?';

  @override
  String get needHint => '¿Necesita una Pista?';

  @override
  String hintDesc(int cost) {
    return '¿Atascado? ¡Deja que la IA encuentre el mejor movimiento!\nCosto: $cost Monedas.';
  }

  @override
  String getHint(int cost) {
    return 'Pista ($cost)';
  }

  @override
  String get undoText => 'Deshacer';

  @override
  String earnedCoins(Object amount) {
    return 'Ganaste $amount ';
  }

  @override
  String get dailyRewardTitle => 'Recompensa Diaria';

  @override
  String dailyStreak(int streak) {
    return 'Racha de $streak Días';
  }

  @override
  String get claim => 'RECLAMAR';

  @override
  String comeBackTomorrowForCoins(int amount) {
    return '¡Vuelve mañana por $amount monedas!';
  }

  @override
  String get decorTypeTube => 'Tubos';

  @override
  String get decorTypeBall => 'Bolas';

  @override
  String get decorTypeWall => 'Paredes';

  @override
  String get decorTypeFloor => 'Pisos';

  @override
  String get decorTypePlant => 'Plantas';

  @override
  String get decorTypeLamp => 'Lámparas';

  @override
  String get decorTypeRug => 'Alfombras';

  @override
  String get decorTypePainting => 'Pinturas';

  @override
  String get item_tube_default => 'Viales de Vidrio';

  @override
  String get item_tube_bamboo => 'Bambú Zen';

  @override
  String get item_tube_metal => 'Aleación Cyber';

  @override
  String get item_tube_gold_rim => 'Oro Real';

  @override
  String get item_tube_crystal => 'Cristal de Hielo';

  @override
  String get item_tube_magma => 'Forja de Magma';

  @override
  String get item_ball_default => 'Esferas';

  @override
  String get item_ball_neon => 'Orbes de Neón';

  @override
  String get item_ball_emoji => 'Emojis';

  @override
  String get item_ball_jewel => 'Joyas';

  @override
  String get item_ball_planets => 'Planetas';

  @override
  String get item_ball_sports => 'Deportes';

  @override
  String get item_wall_default => 'Cielo de Medianoche';

  @override
  String get item_wall_purple => 'Nebulosa';

  @override
  String get item_wall_teal => 'Abismo';

  @override
  String get item_wall_red => 'Terciopelo';

  @override
  String get item_wall_grey => 'Pizarra';

  @override
  String get item_wall_black => 'Vacío Negro';

  @override
  String get item_wall_sunset => 'Atardecer';

  @override
  String get item_wall_matrix => 'Matrix Verde';

  @override
  String get item_floor_default => 'Roble Pulido';

  @override
  String get item_floor_marble => 'Mármol';

  @override
  String get item_floor_stone => 'Roca Volcánica';

  @override
  String get item_floor_carpet => 'Alfombra';

  @override
  String get item_floor_gold => 'Piso Dorado';

  @override
  String get item_floor_grass => 'Pasto';

  @override
  String get item_plant_none => 'Sin Decoración';

  @override
  String get item_plant_fern => 'Helecho';

  @override
  String get item_plant_bamboo => 'Bambú';

  @override
  String get item_plant_tree => 'Bonsái';

  @override
  String get item_plant_lotus => 'Loto Sagrado';

  @override
  String get item_plant_cactus => 'Cactus';

  @override
  String get item_lamp_none => 'Luz Natural';

  @override
  String get item_lamp_classic => 'Clásica';

  @override
  String get item_lamp_modern => 'Plasma';

  @override
  String get item_lamp_sun => 'Solar';

  @override
  String get item_lamp_torch => 'Antorcha';

  @override
  String get item_lamp_neon => 'Neón';

  @override
  String get item_rug_none => 'Piso Desnudo';

  @override
  String get item_rug_shag => 'Cómoda';

  @override
  String get item_rug_round => 'Círculo Místico';

  @override
  String get item_rug_geometric => 'Geométrica';

  @override
  String get item_rug_royal => 'Real';

  @override
  String get item_rug_persian => 'Persa';

  @override
  String get item_paint_none => 'Pared Vacía';

  @override
  String get item_paint_abstract => 'Caos Moderno';

  @override
  String get item_paint_surreal => 'Sueño Surrealista';

  @override
  String get item_paint_portrait => 'Ancestro Noble';

  @override
  String get item_paint_landscape => 'Pico de Montaña';

  @override
  String get item_paint_starry => 'Cosmos Profundo';

  @override
  String get shareApp => 'Compartir app';

  @override
  String get removeAds => 'Eliminar anuncios';

  @override
  String get removeAdsPurchased => 'Anuncios eliminados ✓';

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String get supportDeveloper => 'Apoya al desarrollador';

  @override
  String get tipSmall => 'Propina pequeña  \$0.99';

  @override
  String get tipMedium => 'Propina mediana  \$2.99';

  @override
  String get tipLarge => 'Propina grande  \$4.99';

  @override
  String get purchaseSuccess => '¡Compra exitosa! Muchas gracias 🙏';

  @override
  String get purchaseFailed => 'Error en la compra. Inténtalo de nuevo.';

  @override
  String get purchasePending => 'Compra en proceso…';
}

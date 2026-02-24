// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Tri de Rêve';

  @override
  String get play => 'JOUER';

  @override
  String get levels => 'NIVEAUX';

  @override
  String get room => 'CHAMBRE';

  @override
  String get multiplayer => 'MULTIJOUEUR';

  @override
  String get dailyChallenge => 'DÉFI QUOTIDIEN';

  @override
  String get muteSound => 'Couper le Son';

  @override
  String get unmuteSound => 'Remettre le Son';

  @override
  String get decorShop => 'Boutique';

  @override
  String get howToPlay => 'Comment Jouer';

  @override
  String get quitGame => 'Quitter';

  @override
  String get quitGameDesc =>
      'Votre progression sera perdue. Voulez-vous vraiment quitter ?';

  @override
  String get quitGameAction => 'Quitter';

  @override
  String get keepPlaying => 'Continuer à Jouer';

  @override
  String get selectLevel => 'Choisir le Niveau';

  @override
  String get level => 'Niveau';

  @override
  String get renovateRoom => 'Rénover la Chambre';

  @override
  String notEnoughCoins(int cost) {
    return 'Pas assez de pièces ! Vous avez besoin de $cost.';
  }

  @override
  String get owned => 'POSSÉDÉ';

  @override
  String get equipped => 'ÉQUIPÉ';

  @override
  String get gameOver => 'FIN DU JEU';

  @override
  String wins(String player) {
    return '$player GAGNE !';
  }

  @override
  String time(String time) {
    return 'Temps : $time';
  }

  @override
  String get backToMenu => 'Retour au Menu';

  @override
  String get rematch => 'Revanche';

  @override
  String get vsBattle => 'Bataille 1 vs 1';

  @override
  String sentPenalty(String player) {
    return '$player a envoyé une pénalité !';
  }

  @override
  String frozeOpponent(String attacker, String victim) {
    return '$attacker a gelé $victim !';
  }

  @override
  String get freezeOpponent => 'Geler l\'Adversaire';

  @override
  String levelComplete(String time) {
    return 'Niveau Terminé en $time';
  }

  @override
  String get nextLevel => 'Niveau Suivant';

  @override
  String get dreamSorted => 'RÊVE TRIÉ !';

  @override
  String get rewardBase => 'Base';

  @override
  String get rewardUndoBonus => 'Bonus Annulation';

  @override
  String get rewardTimeBonus => 'Bonus Temps';

  @override
  String get rewardComboBonus => 'Bonus Combo';

  @override
  String levelTitle(int level) {
    return 'Niveau $level';
  }

  @override
  String get menu => 'Menu';

  @override
  String get tapToPick => 'Touchez un tube pour ramasser la balle supérieure.';

  @override
  String get tapToDrop => 'Touchez un autre tube pour la déposer.';

  @override
  String get sameColorStack =>
      'Vous ne pouvez empiler que des balles de MÊME couleur.';

  @override
  String get sortToWin =>
      'Triez toutes les balles de même couleur dans un tube pour gagner !';

  @override
  String get gotIt => 'Compris !';

  @override
  String get subtitle => 'Un Jeu de Puzzle Relaxant';

  @override
  String get multiplayerMode => 'Mode Multijoueur';

  @override
  String get challengeFriends => 'Défiez vos amis !';

  @override
  String get createRoom => 'Créer un Salon';

  @override
  String get joinRoom => 'Rejoindre un Salon';

  @override
  String get localVs => 'VS Local (Écran Divisé)';

  @override
  String get comingSoon => 'Backend multijoueur bientôt !';

  @override
  String get settings => 'Paramètres';

  @override
  String get language => 'Langue';

  @override
  String get changeLanguage => 'Changer de Langue';

  @override
  String get sound => 'Son';

  @override
  String get music => 'Musique';

  @override
  String get sfx => 'Effets Sonores';

  @override
  String get resetProgress => 'Réinitialiser la Progression';

  @override
  String get about => 'À Propos';

  @override
  String get credits => 'Crédits';

  @override
  String get resetConfirmTitle => 'Réinitialiser toute la progression ?';

  @override
  String get resetConfirmMessage =>
      'Cela supprimera toutes vos pièces, objets et détails de progression. Cette action est irréversible.';

  @override
  String get cancel => 'Annuler';

  @override
  String get reset => 'Réinitialiser';

  @override
  String get progressReset => 'La progression a été réinitialisée.';

  @override
  String get chooseDifficulty => 'Choisissez la difficulté';

  @override
  String get enterNameAndLevel => 'Entrez votre nom et choisissez le niveau';

  @override
  String get playerName => 'Nom du Joueur';

  @override
  String get enterRoomDetails => 'Détails du salon pour rejoindre';

  @override
  String get yourName => 'Votre Nom';

  @override
  String get roomCodeHint => 'Code du Salon (ex : ABCD)';

  @override
  String get create => 'Créer';

  @override
  String get join => 'Rejoindre';

  @override
  String get accessibility => 'Accessibilité';

  @override
  String get colorBlindMode => 'Mode Daltonien';

  @override
  String get perfect => 'PARFAIT !';

  @override
  String get resetLevelTitle => 'Recommencer le niveau ?';

  @override
  String get resetLevelDesc =>
      'Votre progression sera perdue et les annulations réinitialisées.';

  @override
  String get resetLevelAction => 'Recommencer';

  @override
  String get outOfUndosTitle => 'Plus d\'annulations !';

  @override
  String outOfUndosDesc(int count) {
    return 'Achetez $count annulations supplémentaires pour continuer.';
  }

  @override
  String buyUndos(int count, int cost) {
    return 'Acheter $count annulations ($cost pièces)';
  }

  @override
  String watchAdFreeUndos(int count) {
    return 'Regarder une pub — $count annulations gratuites';
  }

  @override
  String get needHelp => 'Besoin d\'aide ?';

  @override
  String get addTubeDesc =>
      'Ajoutez un tube vide supplémentaire pour\nfaciliter la résolution de ce puzzle !';

  @override
  String get addTube => 'Ajouter un Tube';

  @override
  String get shuffleTitle => 'Mélanger ?';

  @override
  String get shuffleDesc =>
      'Réorganisez les balles pour trouver de nouveaux mouvements !\n(Les tubes terminés restent en sécurité)';

  @override
  String shuffleAction(int cost) {
    return 'Mélanger ($cost)';
  }

  @override
  String get watchVideo => 'Voir la Vidéo';

  @override
  String get watchAd => 'Regarder l\'Annonce';

  @override
  String get notEnoughCoinsWatchAd =>
      'Pas assez de pièces ! Regardez une annonce.';

  @override
  String get watchAdPlus50Coins => 'Annonce +25 Pièces';

  @override
  String get earnFreeCoins =>
      'Regardez une courte vidéo pour gagner\ninstantanément +25 Pièces Gratuites !';

  @override
  String get noThanks => 'Non, merci';

  @override
  String get needMoreCoins => 'Besoin de Plus de Pièces ?';

  @override
  String get needHint => 'Besoin d\'un Indice ?';

  @override
  String hintDesc(int cost) {
    return 'Bloqué ? Laissez l\'IA trouver le meilleur mouvement !\nCoût : $cost Pièces.';
  }

  @override
  String getHint(int cost) {
    return 'Indice ($cost)';
  }

  @override
  String get undoText => 'Annuler';

  @override
  String earnedCoins(Object amount) {
    return 'Vous avez gagné $amount ';
  }

  @override
  String get dailyRewardTitle => 'Récompense Quotidienne';

  @override
  String dailyStreak(int streak) {
    return 'Série de $streak Jours';
  }

  @override
  String get claim => 'RÉCLAMER';

  @override
  String comeBackTomorrowForCoins(int amount) {
    return 'Revenez demain pour $amount pièces !';
  }

  @override
  String get decorTypeTube => 'Tubes';

  @override
  String get decorTypeBall => 'Balles';

  @override
  String get decorTypeWall => 'Murs';

  @override
  String get decorTypeFloor => 'Sols';

  @override
  String get decorTypePlant => 'Plantes';

  @override
  String get decorTypeLamp => 'Lampes';

  @override
  String get decorTypeRug => 'Tapis';

  @override
  String get decorTypePainting => 'Tableaux';

  @override
  String get item_tube_default => 'Fioles de Verre';

  @override
  String get item_tube_bamboo => 'Bambou Zen';

  @override
  String get item_tube_metal => 'Alliage Cyber';

  @override
  String get item_tube_gold_rim => 'Or Royal';

  @override
  String get item_tube_crystal => 'Cristal de Glace';

  @override
  String get item_tube_magma => 'Forge de Magma';

  @override
  String get item_ball_default => 'Sphères Lisses';

  @override
  String get item_ball_neon => 'Orbes Néon';

  @override
  String get item_ball_emoji => 'Visages Emoji';

  @override
  String get item_ball_jewel => 'Joyaux Précieux';

  @override
  String get item_ball_planets => 'Galaxie Planètes';

  @override
  String get item_ball_sports => 'Pack Sports';

  @override
  String get item_wall_default => 'Ciel de Minuit';

  @override
  String get item_wall_purple => 'Nébuleuse Violette';

  @override
  String get item_wall_teal => 'Abysse Profond';

  @override
  String get item_wall_red => 'Velours Cramoisi';

  @override
  String get item_wall_grey => 'Ardoise Foncée';

  @override
  String get item_wall_black => 'Vide Noir';

  @override
  String get item_wall_sunset => 'Coucher de Soleil Chaud';

  @override
  String get item_wall_matrix => 'Vert Binaire';

  @override
  String get item_floor_default => 'Chêne Poli';

  @override
  String get item_floor_marble => 'Marbre de Glace';

  @override
  String get item_floor_stone => 'Roche Volcanique';

  @override
  String get item_floor_carpet => 'Tapis en Peluche';

  @override
  String get item_floor_gold => 'Sol Doré';

  @override
  String get item_floor_grass => 'Envahi';

  @override
  String get item_plant_none => 'Aucune Décoration';

  @override
  String get item_plant_fern => 'Fougère de Forêt';

  @override
  String get item_plant_bamboo => 'Tiges Zen';

  @override
  String get item_plant_tree => 'Vieux Bonsaï';

  @override
  String get item_plant_lotus => 'Lotus Sacré';

  @override
  String get item_plant_cactus => 'Pointe du Désert';

  @override
  String get item_lamp_none => 'Lumière Naturelle';

  @override
  String get item_lamp_classic => 'Abat-jour';

  @override
  String get item_lamp_modern => 'Ampoule Plasma';

  @override
  String get item_lamp_sun => 'Éruption Solaire';

  @override
  String get item_lamp_torch => 'Feu de Donjon';

  @override
  String get item_lamp_neon => 'Vibes Néon';

  @override
  String get item_rug_none => 'Sol Nu';

  @override
  String get item_rug_shag => 'Confortable';

  @override
  String get item_rug_round => 'Cercle Mystique';

  @override
  String get item_rug_geometric => 'Matrice Géométrique';

  @override
  String get item_rug_royal => 'Tapisserie Royale';

  @override
  String get item_rug_persian => 'Grand Persan';

  @override
  String get item_paint_none => 'Mur Vide';

  @override
  String get item_paint_abstract => 'Chaos Moderne';

  @override
  String get item_paint_surreal => 'Rêve Surréaliste';

  @override
  String get item_paint_portrait => 'Noble Ancêtre';

  @override
  String get item_paint_landscape => 'Sommet de Montagne';

  @override
  String get item_paint_starry => 'Cosmos Profond';
}

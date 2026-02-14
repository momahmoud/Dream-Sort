import 'dart:io';

import 'package:dream_sort/app/app.dart';
import 'package:dream_sort/core/audio/audio_controller.dart';
import 'package:dream_sort/core/locale/locale_cubit.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dream_sort/features/game/repo/game_repository.dart';
import 'package:dream_sort/core/services/ads_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase already initialized or error: $e');
  }

  // Initialize Hive with a no-backup directory to prevent iCloud/Google backup
  // This ensures game progress is reset when the app is uninstalled and reinstalled
  if (Platform.isIOS) {
    // On iOS, use Library/Caches which is not backed up to iCloud
    final cacheDir = await getLibraryDirectory();
    final noBackupDir = Directory('${cacheDir.path}/NoBackup');
    if (!noBackupDir.existsSync()) {
      noBackupDir.createSync(recursive: true);
    }
    Hive.init(noBackupDir.path);
  } else {
    // On Android, allowBackup=false in manifest handles this
    await Hive.initFlutter();
  }
  await dotenv.load(fileName: ".env");
  await AdsService.init();

  final gameRepo = GameRepository();
  await gameRepo.init();

  final audioCtrl = AudioController(gameRepo);
  await audioCtrl.init();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: gameRepo),
        RepositoryProvider.value(value: audioCtrl),
      ],
      child: BlocProvider(
        create: (_) => LocaleCubit(),
        child: const DreamSortApp(),
      ),
    ),
  );
}

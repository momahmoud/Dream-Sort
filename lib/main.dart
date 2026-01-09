import 'package:dream_sort/app/app.dart';
import 'package:dream_sort/core/audio/audio_controller.dart';
import 'package:dream_sort/core/locale/locale_cubit.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dream_sort/features/game/repo/game_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

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

  await Hive.initFlutter();
  await dotenv.load(fileName: ".env");

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

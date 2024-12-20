import 'package:algorhymns/data/models/auth/shared_prefs.dart';
import 'package:algorhymns/firebase_options.dart';
import 'package:algorhymns/presentation/choose_mode/bloc/theme_cubit.dart';
import 'package:algorhymns/presentation/home/pages/home.dart';
import 'package:algorhymns/presentation/splash/pages/splash.dart';
import 'package:algorhymns/service_locator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'; 
import 'package:flutter/material.dart';
import 'package:algorhymns/core/configs/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorage.webStorageDirectory
        : await getApplicationCacheDirectory(),
  );
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDependencies();
  final user = await SharedPrefs.getUserData();
  runApp(MyApp(isUserLoggedIn: user != null));
}


class MyApp extends StatelessWidget {
  final bool isUserLoggedIn;
  const MyApp({super.key, required this.isUserLoggedIn});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, mode) => MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode,
          debugShowCheckedModeBanner: false,
          home: isUserLoggedIn ? const HomePage() : const SplashPage(),
        ),
      ),
    );
  }
}


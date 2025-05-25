import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // file yang digenerate

// Tambahkan ValueNotifier untuk ThemeMode
final globalThemeMode = ValueNotifier<ThemeMode>(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: globalThemeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'OctaKlinik',
          theme: ThemeData(
            colorScheme:
                ColorScheme.fromSeed(seedColor: const Color(0xFF8BA07E)),
            useMaterial3: true,
            fontFamily: 'Poppins',
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.dark(
              primary: Colors.lightBlue,
              secondary: Colors.lightBlueAccent,
              surface: Colors.blueGrey[900]!,
            ),
            scaffoldBackgroundColor: Colors.black,
            fontFamily: 'Poppins',
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            cardColor: Colors.blueGrey[900],
            dialogTheme: DialogTheme(backgroundColor: Colors.blueGrey[900]),
            inputDecorationTheme: const InputDecorationTheme(
              fillColor: Colors.black,
              filled: true,
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Colors.lightBlue,
              foregroundColor: Colors.white,
            ),
          ),
          themeMode: mode,
          home: const SplashScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

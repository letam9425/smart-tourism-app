// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:smart_tourism_app/core/theme.dart';
import 'package:smart_tourism_app/screens/home_screen.dart';
import 'package:smart_tourism_app/screens/image_recognition_screen.dart';
import 'package:smart_tourism_app/screens/map_screen.dart';
import 'package:smart_tourism_app/screens/place_detail_screen.dart';
import 'package:smart_tourism_app/screens/translate_screen.dart';
import 'package:smart_tourism_app/services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ApiService.init(); // Setup Dio
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Tourism VN',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Localization setup - sử dụng Global...Delegate đúng cách
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const <Locale>[
        Locale('vi', ''), // Tiếng Việt
        Locale('en', ''), // Tiếng Anh
      ],
      locale: const Locale('vi', ''),

      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/recognition': (context) => const ImageRecognitionScreen(),
        '/map': (context) => const MapScreen(),
        '/detail': (context) => const PlaceDetailScreen(),
        '/translate': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as String?;
          return TranslateScreen(originalText: args ?? '');
        },
      },
    );
  }
}
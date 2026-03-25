import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const TinyImgApp());
}

class TinyImgApp extends StatelessWidget {
  const TinyImgApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TinyImg',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: const HomeScreen(),
    );
  }
}

class AppTheme {
  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        secondary: AppColors.accent2,
        surface: AppColors.surface,
        background: AppColors.bg,
      ),
      fontFamily: 'SF Pro Display',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: AppColors.text,
          letterSpacing: -1,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.text,
          letterSpacing: -0.3,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.muted,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.muted,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class AppColors {
  static const bg = Color(0xFF0A0A0F);
  static const surface = Color(0xFF13131A);
  static const surface2 = Color(0xFF1C1C27);
  static const border = Color(0xFF2A2A3D);
  static const accent = Color(0xFF7C5CFC);
  static const accent2 = Color(0xFFE05AFF);
  static const green = Color(0xFF2AFFA3);
  static const red = Color(0xFFFF5A7E);
  static const text = Color(0xFFE8E8F0);
  static const muted = Color(0xFF6B6B8A);
}

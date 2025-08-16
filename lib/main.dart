import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'constants/design_system.dart';
import 'screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화 (중복 초기화 방지)
  try {
    // 이미 초기화된 Firebase 앱이 있는지 확인
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('Firebase 초기화 성공!');
    } else {
      print('Firebase가 이미 초기화되어 있습니다.');
    }
  } catch (e) {
    print('Firebase 초기화 오류: $e');
    // 오류가 발생해도 앱은 계속 실행
  }

  runApp(const MoimMoneyApp());
}

/// 머니투게더 메인 앱 클래스
class MoimMoneyApp extends StatelessWidget {
  const MoimMoneyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '머니투게더',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // 앱 테마 설정
        colorScheme: ColorScheme.fromSeed(
          seedColor: DesignSystem.primary,
          brightness: Brightness.light,
        ),

        // 앱바 테마
        appBarTheme: AppBarTheme(
          backgroundColor: DesignSystem.surface,
          foregroundColor: DesignSystem.textPrimary,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: DesignSystem.headline3.copyWith(
            color: DesignSystem.textPrimary,
          ),
        ),

        // 플로팅 액션 버튼 테마
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: DesignSystem.primary,
          foregroundColor: Colors.white,
        ),

        // 카드 테마
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
          ),
        ),

        // 입력 필드 테마
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
            borderSide: const BorderSide(color: DesignSystem.primary, width: 2),
          ),
        ),

        // 버튼 테마
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: DesignSystem.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: DesignSystem.spacing24,
              vertical: DesignSystem.spacing12,
            ),
          ),
        ),

        // 텍스트 테마
        textTheme: TextTheme(
          headlineLarge: DesignSystem.headline1,
          headlineMedium: DesignSystem.headline2,
          headlineSmall: DesignSystem.headline3,
          bodyLarge: DesignSystem.body1,
          bodyMedium: DesignSystem.body2,
          bodySmall: DesignSystem.caption,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

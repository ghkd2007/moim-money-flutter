import 'package:flutter/material.dart';

/// 머니투게더 디자인 시스템
/// UI/UX 가이드라인에 따른 일관된 디자인을 제공합니다.
class DesignSystem {
  // Private constructor to prevent instantiation
  DesignSystem._();

  // ===== 색상 시스템 =====

  /// 🟢 수입 관련 색상 (긍정적)
  static const Color income = Color(0xFF4CAF50);
  static const Color incomeLight = Color(0xFF66BB6A);

  /// 🔴 지출 관련 색상 (부정적)
  static const Color expense = Color(0xFFF44336);
  static const Color expenseLight = Color(0xFFEF5350);

  /// 🔵 앱 브랜드 컬러
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryLight = Color(0xFF42A5F5);
  static const Color primaryDark = Color(0xFF1976D2);

  /// ⚫ 중성 컬러
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color divider = Color(0xFFE0E0E0);

  /// 🎨 상태 색상 (현대적)
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color info = Color(0xFF06B6D4);
  static const Color infoLight = Color(0xFF22D3EE);

  /// 🌈 그라데이션
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [success, successLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [warning, warningLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient errorGradient = LinearGradient(
    colors: [error, errorLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient incomeGradient = LinearGradient(
    colors: [income, incomeLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient expenseGradient = LinearGradient(
    colors: [expense, expenseLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ===== 타이포그래피 =====

  /// 제목 (큰 제목) - 32sp
  static const TextStyle headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    height: 1.2,
  );

  /// 제목 (중간 제목) - 24sp
  static const TextStyle headline2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.3,
  );

  /// 제목 (작은 제목) - 20sp
  static const TextStyle headline3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.4,
  );

  /// 본문 (큰 텍스트) - 16sp
  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textPrimary,
    height: 1.5,
  );

  /// 본문 (작은 텍스트) - 14sp
  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textSecondary,
    height: 1.4,
  );

  /// 캡션 - 12sp
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textSecondary,
    height: 1.3,
  );

  /// 현대적 제목 (토스 스타일)
  static const TextStyle displayLarge = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w800,
    color: textPrimary,
    height: 1.1,
    letterSpacing: -0.5,
  );

  /// 현대적 부제목
  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    height: 1.2,
    letterSpacing: -0.3,
  );

  /// 강조 텍스트
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.4,
    letterSpacing: 0.1,
  );

  // ===== 간격 및 크기 =====

  /// 기본 간격
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing48 = 48.0;

  /// 터치 영역
  static const double minTouchTarget = 48.0;
  static const double touchTargetSpacing = 8.0;

  /// 둥근 모서리 (현대적)
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  static const double radiusCircular = 28.0;
  static const double radiusUltra = 32.0;

  // ===== 그림자 =====

  /// 기본 그림자
  static const List<BoxShadow> shadowSmall = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];

  /// 중간 그림자
  static const List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  /// 큰 그림자
  static const List<BoxShadow> shadowLarge = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  /// 현대적 그림자 (Glassmorphism 효과)
  static const List<BoxShadow> shadowModern = [
    BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 8),
      blurRadius: 24,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  /// 부드러운 그림자
  static const List<BoxShadow> shadowSoft = [
    BoxShadow(
      color: Color(0x08000000),
      offset: Offset(0, 2),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];

  /// 내부 그림자 (Pressed 효과)
  static const List<BoxShadow> shadowInner = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];

  // ===== 애니메이션 =====

  /// 애니메이션 지속 시간
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  /// 애니메이션 커브
  static const Curve curveEaseInOut = Curves.easeInOut;
  static const Curve curveEaseOut = Curves.easeOut;
  static const Curve curveEaseIn = Curves.easeIn;
  static const Curve curveFastOutSlowIn = Curves.fastOutSlowIn;

  // ===== 반응형 브레이크포인트 =====

  /// 모바일 최대 너비
  static const double mobileBreakpoint = 600.0;

  /// 태블릿 최대 너비
  static const double tabletBreakpoint = 1200.0;

  /// 반응형 여백
  static EdgeInsets getScreenPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) {
      return const EdgeInsets.all(spacing16);
    } else if (width < tabletBreakpoint) {
      return const EdgeInsets.all(spacing24);
    } else {
      return const EdgeInsets.all(spacing32);
    }
  }

  /// 반응형 그리드 열 수
  static int getGridCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) {
      return 1;
    } else if (width < tabletBreakpoint) {
      return 2;
    } else {
      return 3;
    }
  }
}

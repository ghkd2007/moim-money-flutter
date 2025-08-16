import 'package:flutter/material.dart';

/// 앱 기본 상수들
class AppConstants {
  // 앱 정보
  static const String appName = '머니투게더';
  static const String appVersion = '1.0.0';
  static const String appDescription = '함께하는 투명한 금융 관리';

  // 색상 테마
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFF1976D2);
  static const Color accentColor = Color(0xFF64B5F6);

  // 수입/지출 색상
  static const Color incomeColor = Color(0xFF4CAF50);
  static const Color expenseColor = Color(0xFFF44336);
  
  // 상태 색상
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color successColor = Color(0xFF388E3C);
  static const Color warningColor = Color(0xFFF57C00);

  // 배경 및 텍스트 색상
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);
  static const Color dividerColor = Color(0xFFE0E0E0);

  // 기본 카테고리 정보
  static const List<Map<String, dynamic>> defaultCategories = [
    {'name': '식비', 'icon': '🍽️', 'color': '#FF5722', 'type': 'expense'},
    {'name': '교통비', 'icon': '🚗', 'color': '#2196F3', 'type': 'expense'},
    {'name': '쇼핑', 'icon': '🛍️', 'color': '#9C27B0', 'type': 'expense'},
    {'name': '문화생활', 'icon': '🎬', 'color': '#FF9800', 'type': 'expense'},
    {'name': '의료비', 'icon': '🏥', 'color': '#E91E63', 'type': 'expense'},
    {'name': '교육비', 'icon': '📚', 'color': '#607D8B', 'type': 'expense'},
    {'name': '급여', 'icon': '💰', 'color': '#4CAF50', 'type': 'income'},
    {'name': '용돈', 'icon': '💵', 'color': '#8BC34A', 'type': 'income'},
    {'name': '기타수입', 'icon': '💎', 'color': '#00BCD4', 'type': 'income'},
  ];

  // 앱 설정
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxDescriptionLength = 200;
  static const int maxCategoryNameLength = 20;
  static const int maxGroupNameLength = 30;
  static const int maxGroupDescriptionLength = 100;

  // 날짜 포맷
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm';

  // 통화 포맷
  static const String currencySymbol = '원';
  static const int decimalPlaces = 0;

  // 페이지네이션
  static const int pageSize = 20;
  static const int maxLoadCount = 100;

  // 애니메이션
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // 터치 영역
  static const double minTouchTargetSize = 48.0;
  static const double touchTargetSpacing = 8.0;

  // 그림자
  static const List<BoxShadow> defaultShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];
}

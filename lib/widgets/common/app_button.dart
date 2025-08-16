import 'package:flutter/material.dart';
import '../../constants/design_system.dart';

/// 앱 공통 버튼 컴포넌트
/// 디자인 시스템에 따른 일관된 버튼 디자인을 제공합니다.
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final AppButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final Widget? trailingIcon;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _getButtonStyle();
    final buttonSize = _getButtonSize();

    Widget buttonChild = _buildButtonChild();

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        height: buttonSize.height,
        child: _buildButton(buttonStyle, buttonSize, buttonChild),
      );
    }

    return SizedBox(
      width: buttonSize.width,
      height: buttonSize.height,
      child: _buildButton(buttonStyle, buttonSize, buttonChild),
    );
  }

  Widget _buildButton(
    ButtonStyle buttonStyle,
    _ButtonSize buttonSize,
    Widget child,
  ) {
    switch (type) {
      case AppButtonType.primary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: child,
        );
      case AppButtonType.secondary:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: child,
        );
      case AppButtonType.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: child,
        );
    }
  }

  Widget _buildButtonChild() {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(_getTextColor()),
        ),
      );
    }

    final children = <Widget>[];

    if (icon != null) {
      children.addAll([
        Icon(icon, size: _getIconSize()),
        SizedBox(width: DesignSystem.spacing8),
      ]);
    }

    children.add(Text(text, style: _getTextStyle()));

    if (trailingIcon != null) {
      children.addAll([SizedBox(width: DesignSystem.spacing8), trailingIcon!]);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  ButtonStyle _getButtonStyle() {
    final buttonSize = _getButtonSize();

    switch (type) {
      case AppButtonType.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: DesignSystem.primary,
          foregroundColor: Colors.white,
          padding: buttonSize.padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
          ),
          elevation: 2,
          shadowColor: DesignSystem.primary.withOpacity(0.3),
        );
      case AppButtonType.secondary:
        return OutlinedButton.styleFrom(
          foregroundColor: DesignSystem.primary,
          side: const BorderSide(color: DesignSystem.primary, width: 2),
          padding: buttonSize.padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
          ),
        );
      case AppButtonType.text:
        return TextButton.styleFrom(
          foregroundColor: DesignSystem.primary,
          padding: buttonSize.padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
          ),
        );
    }
  }

  _ButtonSize _getButtonSize() {
    switch (size) {
      case AppButtonSize.small:
        return _ButtonSize(
          height: 36,
          padding: const EdgeInsets.symmetric(
            horizontal: DesignSystem.spacing16,
            vertical: DesignSystem.spacing8,
          ),
        );
      case AppButtonSize.medium:
        return _ButtonSize(
          height: 48,
          padding: const EdgeInsets.symmetric(
            horizontal: DesignSystem.spacing24,
            vertical: DesignSystem.spacing12,
          ),
        );
      case AppButtonSize.large:
        return _ButtonSize(
          height: 56,
          padding: const EdgeInsets.symmetric(
            horizontal: DesignSystem.spacing32,
            vertical: DesignSystem.spacing16,
          ),
        );
    }
  }

  double _getIconSize() {
    switch (size) {
      case AppButtonSize.small:
        return 16;
      case AppButtonSize.medium:
        return 20;
      case AppButtonSize.large:
        return 24;
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case AppButtonSize.small:
        return DesignSystem.body2.copyWith(fontWeight: FontWeight.w600);
      case AppButtonSize.medium:
        return DesignSystem.body1.copyWith(fontWeight: FontWeight.w600);
      case AppButtonSize.large:
        return DesignSystem.headline3.copyWith(fontWeight: FontWeight.w600);
    }
  }

  Color _getTextColor() {
    switch (type) {
      case AppButtonType.primary:
        return Colors.white;
      case AppButtonType.secondary:
      case AppButtonType.text:
        return DesignSystem.primary;
    }
  }
}

/// 버튼 타입
enum AppButtonType {
  primary, // 주요 액션
  secondary, // 보조 액션
  text, // 텍스트 버튼
}

/// 버튼 크기
enum AppButtonSize {
  small, // 36dp 높이
  medium, // 48dp 높이
  large, // 56dp 높이
}

/// 내부 버튼 크기 클래스
class _ButtonSize {
  final double height;
  final double? width;
  final EdgeInsetsGeometry padding;

  const _ButtonSize({required this.height, this.width, required this.padding});
}

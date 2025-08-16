import 'package:flutter/material.dart';
import '../../constants/design_system.dart';

/// 앱 공통 텍스트 입력 필드 컴포넌트
/// 디자인 시스템에 따른 일관된 입력 필드 디자인을 제공합니다.
class AppTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool isRequired;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final String? Function(String?)? validator;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool readOnly;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.isRequired = false,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.textInputAction,
    this.focusNode,
    this.autofocus = false,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Row(
            children: [
              Text(
                label!,
                style: DesignSystem.body1.copyWith(
                  fontWeight: FontWeight.w500,
                  color: enabled
                      ? DesignSystem.textPrimary
                      : DesignSystem.textSecondary,
                ),
              ),
              if (isRequired) ...[
                const SizedBox(width: DesignSystem.spacing4),
                Text(
                  '*',
                  style: TextStyle(
                    color: DesignSystem.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: DesignSystem.spacing8),
        ],
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          onTap: onTap,
          enabled: enabled,
          maxLines: maxLines,
          maxLength: maxLength,
          textInputAction: textInputAction,
          focusNode: focusNode,
          autofocus: autofocus,
          readOnly: readOnly,
          style: DesignSystem.body1.copyWith(
            color: enabled
                ? DesignSystem.textPrimary
                : DesignSystem.textSecondary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
              borderSide: const BorderSide(color: DesignSystem.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
              borderSide: const BorderSide(color: DesignSystem.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
              borderSide: const BorderSide(
                color: DesignSystem.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
              borderSide: const BorderSide(color: DesignSystem.error, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
              borderSide: const BorderSide(color: DesignSystem.error, width: 2),
            ),
            filled: true,
            fillColor: enabled ? DesignSystem.surface : DesignSystem.background,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: DesignSystem.spacing16,
              vertical: DesignSystem.spacing12,
            ),
            labelStyle: TextStyle(
              color: enabled
                  ? DesignSystem.textSecondary
                  : DesignSystem.textSecondary.withOpacity(0.6),
            ),
            hintStyle: TextStyle(
              color: DesignSystem.textSecondary.withOpacity(0.6),
            ),
            errorStyle: TextStyle(color: DesignSystem.error, fontSize: 12),
            counterStyle: DesignSystem.caption.copyWith(
              color: DesignSystem.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

/// 금액 입력 전용 필드
class AppAmountField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? errorText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool enabled;
  final bool isRequired;

  const AppAmountField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.errorText,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.isRequired = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label ?? '금액',
      hint: hint ?? '0',
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      isRequired: isRequired,
      errorText: errorText,
      validator: validator ?? _defaultAmountValidator,
      onChanged: onChanged,
      enabled: enabled,
      prefixIcon: const Icon(
        Icons.attach_money,
        color: DesignSystem.textSecondary,
      ),
      maxLength: 12,
    );
  }

  String? _defaultAmountValidator(String? value) {
    if (value == null || value.isEmpty) {
      return '금액을 입력해주세요.';
    }

    final amount = double.tryParse(value.replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      return '올바른 금액을 입력해주세요.';
    }

    if (amount > 999999999) {
      return '금액이 너무 큽니다.';
    }

    return null;
  }
}

/// 이메일 입력 전용 필드
class AppEmailField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? errorText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool enabled;
  final bool isRequired;

  const AppEmailField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.errorText,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.isRequired = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label ?? '이메일',
      hint: hint ?? 'example@email.com',
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      isRequired: isRequired,
      errorText: errorText,
      validator: validator ?? _defaultEmailValidator,
      onChanged: onChanged,
      enabled: enabled,
      prefixIcon: const Icon(
        Icons.email_outlined,
        color: DesignSystem.textSecondary,
      ),
      textInputAction: TextInputAction.next,
    );
  }

  String? _defaultEmailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return '이메일을 입력해주세요.';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return '올바른 이메일 형식을 입력해주세요.';
    }

    return null;
  }
}

/// 비밀번호 입력 전용 필드
class AppPasswordField extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? errorText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool enabled;
  final bool isRequired;
  final bool showToggleVisibility;

  const AppPasswordField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.errorText,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.isRequired = true,
    this.showToggleVisibility = true,
  });

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: widget.label ?? '비밀번호',
      hint: widget.hint ?? '비밀번호를 입력하세요',
      controller: widget.controller,
      obscureText: _obscureText,
      isRequired: widget.isRequired,
      errorText: widget.errorText,
      validator: widget.validator ?? _defaultPasswordValidator,
      onChanged: widget.onChanged,
      enabled: widget.enabled,
      prefixIcon: const Icon(
        Icons.lock_outlined,
        color: DesignSystem.textSecondary,
      ),
      suffixIcon: widget.showToggleVisibility
          ? IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility : Icons.visibility_off,
                color: DesignSystem.textSecondary,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            )
          : null,
      textInputAction: TextInputAction.done,
    );
  }

  String? _defaultPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해주세요.';
    }

    if (value.length < 6) {
      return '비밀번호는 6자 이상이어야 합니다.';
    }

    return null;
  }
}

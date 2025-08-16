import 'package:flutter/material.dart';
import '../../../constants/design_system.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_text_field.dart';

/// 모임 참여 화면
/// 참여 코드를 입력하여 기존 모임에 입장할 수 있는 화면입니다.
class JoinGroupScreen extends StatefulWidget {
  const JoinGroupScreen({super.key});

  @override
  State<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends State<JoinGroupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: DesignSystem.animationNormal,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: DesignSystem.curveEaseOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: DesignSystem.curveEaseOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        title: Text(
          '모임 참여하기',
          style: DesignSystem.headline3.copyWith(
            color: DesignSystem.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: DesignSystem.textPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: DesignSystem.getScreenPadding(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: DesignSystem.spacing32),

                    // 헤더 섹션
                    _buildHeaderSection(),

                    const SizedBox(height: DesignSystem.spacing32),

                    // 참여 코드 입력 폼
                    _buildCodeInputForm(),

                    const SizedBox(height: DesignSystem.spacing32),

                    // 참여 버튼
                    _buildJoinButton(),

                    const SizedBox(height: DesignSystem.spacing24),

                    // 도움말
                    _buildHelpSection(),

                    const SizedBox(height: DesignSystem.spacing32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 헤더 섹션
  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 아이콘
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: DesignSystem.info.withOpacity(0.1),
            borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
          ),
          child: Icon(
            Icons.group_add,
            size: 40,
            color: DesignSystem.info,
          ),
        ),

        const SizedBox(height: DesignSystem.spacing24),

        // 제목
        Text(
          '참여 코드로 모임 입장',
          style: DesignSystem.headline2.copyWith(
            color: DesignSystem.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: DesignSystem.spacing12),

        // 설명
        Text(
          '친구가 보내준 참여 코드를 입력하여\n기존 모임에 참여할 수 있습니다.',
          style: DesignSystem.body1.copyWith(
            color: DesignSystem.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  /// 참여 코드 입력 폼
  Widget _buildCodeInputForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '참여 코드',
          style: DesignSystem.labelLarge.copyWith(
            color: DesignSystem.textPrimary,
          ),
        ),
        const SizedBox(height: DesignSystem.spacing8),
        AppTextField(
          controller: _codeController,
          hint: '예: ABC123',
          isRequired: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '참여 코드를 입력해주세요';
            }
            if (value.length < 6) {
              return '참여 코드는 6자 이상이어야 합니다';
            }
            return null;
          },
        ),
        const SizedBox(height: DesignSystem.spacing8),
        Text(
          '참여 코드는 모임장이 생성한 6자리 이상의 고유 코드입니다.',
          style: DesignSystem.caption.copyWith(
            color: DesignSystem.textSecondary,
          ),
        ),
      ],
    );
  }

  /// 참여 버튼
  Widget _buildJoinButton() {
    return AppButton(
      onPressed: _isLoading ? null : _joinGroup,
      text: _isLoading ? '참여 중...' : '모임 참여하기',
      isLoading: _isLoading,
      isFullWidth: true,
      size: AppButtonSize.large,
      icon: Icons.group_add,
    );
  }

  /// 도움말 섹션
  Widget _buildHelpSection() {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.spacing20),
      decoration: BoxDecoration(
        color: DesignSystem.surface,
        borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
        border: Border.all(
          color: DesignSystem.divider,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.help_outline,
                color: DesignSystem.info,
                size: 20,
              ),
              const SizedBox(width: DesignSystem.spacing8),
              Text(
                '참여 코드가 없나요?',
                style: DesignSystem.body2.copyWith(
                  fontWeight: FontWeight.w600,
                  color: DesignSystem.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignSystem.spacing12),
          Text(
            '• 모임장에게 참여 코드를 요청하세요\n'
            '• 참여 코드는 모임 설정에서 확인할 수 있습니다\n'
            '• 새로운 모임을 만들고 싶다면 "모임 만들기"를 선택하세요',
            style: DesignSystem.caption.copyWith(
              color: DesignSystem.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  /// 모임 참여 처리
  Future<void> _joinGroup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // TODO: Firebase에서 참여 코드 검증 및 모임 참여
      await Future.delayed(const Duration(seconds: 2)); // 임시 딜레이

      if (mounted) {
        // 성공 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('모임 참여가 완료되었습니다!'),
            backgroundColor: DesignSystem.success,
          ),
        );

        // 이전 화면으로 이동
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('모임 참여 중 오류가 발생했습니다: $e'),
            backgroundColor: DesignSystem.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

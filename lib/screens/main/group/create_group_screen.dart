import 'package:flutter/material.dart';
import '../../../constants/design_system.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_text_field.dart';

/// 모임 생성 화면
/// 새로운 모임을 만들고 초기 설정을 할 수 있는 화면입니다.
class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  bool _hasInitialBudget = false;
  final List<String> _invitedEmails = [];

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

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: DesignSystem.curveEaseOut,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        title: Text(
          '새 모임 만들기',
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
                    const SizedBox(height: DesignSystem.spacing24),

                    // 환영 메시지
                    _buildWelcomeMessage(),

                    const SizedBox(height: DesignSystem.spacing32),

                    // 모임 이름
                    _buildNameSection(),

                    const SizedBox(height: DesignSystem.spacing24),

                    // 모임 설명
                    _buildDescriptionSection(),

                    const SizedBox(height: DesignSystem.spacing24),

                    // 초기 예산
                    _buildBudgetSection(),

                    const SizedBox(height: DesignSystem.spacing24),

                    // 멤버 초대
                    _buildInviteSection(),

                    const SizedBox(height: DesignSystem.spacing32),

                    // 모임 생성 버튼
                    _buildCreateButton(),

                    const SizedBox(height: DesignSystem.spacing24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 환영 메시지
  Widget _buildWelcomeMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '새로운 모임을 만들어보세요!',
          style: DesignSystem.headline2.copyWith(
            fontWeight: FontWeight.bold,
            color: DesignSystem.textPrimary,
          ),
        ),
        const SizedBox(height: DesignSystem.spacing8),
        Text(
          '함께하는 투명한 금융 관리를 시작할 수 있습니다.',
          style: DesignSystem.body1.copyWith(color: DesignSystem.textSecondary),
        ),
      ],
    );
  }

  /// 모임 이름 섹션
  Widget _buildNameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '모임 이름',
          style: DesignSystem.headline3.copyWith(
            color: DesignSystem.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: DesignSystem.spacing8),
        AppTextField(
          label: '모임 이름',
          hint: '예: 가족 모임, 친구 여행, 동호회 활동',
          controller: _nameController,
          isRequired: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '모임 이름을 입력해주세요.';
            }
            if (value.length < 2) {
              return '모임 이름은 2자 이상이어야 합니다.';
            }
            if (value.length > 20) {
              return '모임 이름은 20자 이하여야 합니다.';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// 모임 설명 섹션
  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '모임 설명 (선택사항)',
          style: DesignSystem.headline3.copyWith(
            color: DesignSystem.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: DesignSystem.spacing8),
        AppTextField(
          label: '모임 설명',
          hint: '모임의 목적이나 특징을 간단히 설명해주세요',
          controller: _descriptionController,
          isRequired: false,
          maxLines: 3,
        ),
      ],
    );
  }

  /// 초기 예산 섹션
  Widget _buildBudgetSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '초기 예산 (선택사항)',
              style: DesignSystem.headline3.copyWith(
                color: DesignSystem.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Switch(
              value: _hasInitialBudget,
              onChanged: (value) {
                setState(() {
                  _hasInitialBudget = value;
                  if (!value) {
                    _budgetController.clear();
                  }
                });
              },
              activeColor: DesignSystem.primary,
            ),
          ],
        ),
        const SizedBox(height: DesignSystem.spacing8),
        if (_hasInitialBudget)
          AppTextField(
            label: '초기 예산',
            hint: '0',
            controller: _budgetController,
            isRequired: false,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (_hasInitialBudget && (value == null || value.isEmpty)) {
                return '예산을 입력해주세요.';
              }
              if (_hasInitialBudget && value != null) {
                final amount = int.tryParse(value.replaceAll(',', ''));
                if (amount == null || amount < 0) {
                  return '올바른 금액을 입력해주세요.';
                }
              }
              return null;
            },
          ),
      ],
    );
  }

  /// 멤버 초대 섹션
  Widget _buildInviteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '멤버 초대 (선택사항)',
          style: DesignSystem.headline3.copyWith(
            color: DesignSystem.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: DesignSystem.spacing8),
        Text(
          '모임에 함께할 멤버들의 이메일을 입력하세요.',
          style: DesignSystem.body2.copyWith(color: DesignSystem.textSecondary),
        ),
        const SizedBox(height: DesignSystem.spacing16),

        // 이메일 입력 필드
        Row(
          children: [
            Expanded(
              child: AppEmailField(
                controller: _emailController,
                isRequired: false,
                hint: '이메일 주소',
              ),
            ),
            const SizedBox(width: DesignSystem.spacing12),
            AppButton(
              text: '추가',
              onPressed: _addInvitedEmail,
              size: AppButtonSize.medium,
            ),
          ],
        ),

        const SizedBox(height: DesignSystem.spacing16),

        // 초대된 이메일 목록
        if (_invitedEmails.isNotEmpty) ...[
          Text(
            '초대할 멤버들',
            style: DesignSystem.body2.copyWith(
              color: DesignSystem.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DesignSystem.spacing8),
          ..._invitedEmails
              .map((email) => _buildInvitedEmailItem(email))
              .toList(),
        ],
      ],
    );
  }

  /// 초대된 이메일 아이템
  Widget _buildInvitedEmailItem(String email) {
    return Container(
      margin: const EdgeInsets.only(bottom: DesignSystem.spacing8),
      padding: const EdgeInsets.symmetric(
        horizontal: DesignSystem.spacing12,
        vertical: DesignSystem.spacing8,
      ),
      decoration: BoxDecoration(
        color: DesignSystem.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
        border: Border.all(color: DesignSystem.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.email, color: DesignSystem.primary, size: 16),
          const SizedBox(width: DesignSystem.spacing8),
          Expanded(
            child: Text(
              email,
              style: DesignSystem.body2.copyWith(
                color: DesignSystem.textPrimary,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle, size: 20),
            color: DesignSystem.error,
            onPressed: () => _removeInvitedEmail(email),
          ),
        ],
      ),
    );
  }

  /// 초대 이메일 추가
  void _addInvitedEmail() {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('올바른 이메일 형식을 입력해주세요.'),
          backgroundColor: DesignSystem.error,
        ),
      );
      return;
    }

    if (_invitedEmails.contains(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('이미 추가된 이메일입니다.'),
          backgroundColor: DesignSystem.warning,
        ),
      );
      return;
    }

    setState(() {
      _invitedEmails.add(email);
      _emailController.clear();
    });
  }

  /// 초대 이메일 제거
  void _removeInvitedEmail(String email) {
    setState(() {
      _invitedEmails.remove(email);
    });
  }

  /// 이메일 유효성 검사
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// 모임 생성 버튼
  Widget _buildCreateButton() {
    return AppButton(
      onPressed: _isLoading ? null : _createGroup,
      text: _isLoading ? '모임 생성 중...' : '모임 만들기',
      isLoading: _isLoading,
      isFullWidth: true,
      size: AppButtonSize.large,
    );
  }

  /// 모임 생성 처리
  Future<void> _createGroup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 모임 생성 로직 (추후 Firebase 연동)
      await Future.delayed(const Duration(seconds: 2)); // 임시 딜레이

      if (mounted) {
        // 성공 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_nameController.text} 모임이 생성되었습니다!'),
            backgroundColor: DesignSystem.success,
          ),
        );

        // 메인 화면으로 이동
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('모임 생성 중 오류가 발생했습니다.'),
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

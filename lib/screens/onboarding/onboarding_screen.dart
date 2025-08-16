import 'package:flutter/material.dart';
import '../../constants/design_system.dart';
import '../../widgets/common/app_button.dart';
import '../main/main_screen.dart';
import '../main/group/create_group_screen.dart';
import '../main/group/join_group_screen.dart';

/// 온보딩 화면
/// 신규 사용자를 위한 모임 생성 또는 참여 코드로 입장을 선택할 수 있는 화면입니다.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
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
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: DesignSystem.getScreenPadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: DesignSystem.spacing48),

                  // 환영 메시지
                  _buildWelcomeSection(),

                  const SizedBox(height: DesignSystem.spacing48),

                  // 모임 소개
                  _buildGroupIntroduction(),

                  const SizedBox(height: DesignSystem.spacing48),

                  // 액션 버튼들
                  _buildActionButtons(),

                  const SizedBox(height: DesignSystem.spacing32),

                  // 건너뛰기
                  _buildSkipButton(),

                  const SizedBox(height: DesignSystem.spacing48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 환영 메시지 섹션
  Widget _buildWelcomeSection() {
    return Column(
      children: [
        // 앱 로고/아이콘
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: DesignSystem.primary,
            borderRadius: BorderRadius.circular(DesignSystem.radiusUltra),
            boxShadow: [DesignSystem.shadowModern[0]],
          ),
          child: const Icon(
            Icons.account_balance_wallet,
            size: 60,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: DesignSystem.spacing32),

        // 환영 제목
        Text(
          '머니투게더에 오신 것을\n환영합니다! 🎉',
          style: DesignSystem.displayLarge.copyWith(
            color: DesignSystem.textPrimary,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: DesignSystem.spacing16),

        // 환영 부제목
        Text(
          '친구들과 함께 지출을 관리하고\n예산을 계획해보세요',
          style: DesignSystem.body1.copyWith(
            color: DesignSystem.textSecondary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// 모임 소개 섹션
  Widget _buildGroupIntroduction() {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.spacing24),
      decoration: BoxDecoration(
        color: DesignSystem.surface,
        borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
        boxShadow: [DesignSystem.shadowSmall[0]],
        border: Border.all(color: DesignSystem.divider, width: 1),
      ),
      child: Column(
        children: [
          // 모임이란? 제목
          Row(
            children: [
              Icon(Icons.lightbulb, color: DesignSystem.warning, size: 24),
              const SizedBox(width: DesignSystem.spacing12),
              Text(
                '모임이란?',
                style: DesignSystem.headline3.copyWith(
                  color: DesignSystem.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: DesignSystem.spacing16),

          // 모임 설명
          Text(
            '모임은 친구들과 함께 지출을 관리하고 예산을 계획할 수 있는 공간입니다.\n\n'
            '• 함께 지출 내역 공유\n'
            '• 예산 설정 및 관리\n'
            '• 지출 통계 및 분석\n'
            '• 투명한 금융 관리',
            style: DesignSystem.body1.copyWith(
              color: DesignSystem.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }

  /// 액션 버튼들
  Widget _buildActionButtons() {
    return Column(
      children: [
        // 모임 만들기 버튼 (주요 액션)
        AppButton(
          onPressed: () => _createNewGroup(),
          text: '모임 만들기',
          isFullWidth: true,
          size: AppButtonSize.large,
          icon: Icons.add,
        ),

        const SizedBox(height: DesignSystem.spacing16),

        // 참여 코드로 입장 버튼 (보조 액션)
        AppButton(
          onPressed: () => _joinExistingGroup(),
          text: '참여 코드로 입장',
          type: AppButtonType.secondary,
          isFullWidth: true,
          size: AppButtonSize.large,
          icon: Icons.group_add,
        ),
      ],
    );
  }

  /// 건너뛰기 버튼
  Widget _buildSkipButton() {
    return TextButton(
      onPressed: () => _skipOnboarding(),
      child: Text(
        '나중에 하기',
        style: DesignSystem.body1.copyWith(color: DesignSystem.textSecondary),
      ),
    );
  }

  /// 새 모임 생성
  void _createNewGroup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateGroupScreen()),
    ).then((_) {
      // 모임 생성 완료 후 메인 화면으로 이동
      _navigateToMainScreen();
    });
  }

  /// 기존 모임 참여
  void _joinExistingGroup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const JoinGroupScreen()),
    ).then((_) {
      // 모임 참여 완료 후 메인 화면으로 이동
      _navigateToMainScreen();
    });
  }

  /// 온보딩 건너뛰기
  void _skipOnboarding() {
    _navigateToMainScreen();
  }

  /// 메인 화면으로 이동
  void _navigateToMainScreen() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MainScreen()),
      (route) => false,
    );
  }
}

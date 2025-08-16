import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants/design_system.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../main/main_screen.dart';
import '../onboarding/onboarding_screen.dart';
import 'register_screen.dart';

/// 로그인 화면
/// 사용자가 이메일과 비밀번호로 로그인할 수 있습니다.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

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
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// 로그인 처리
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Firebase Auth를 통한 로그인
      final userCredential = await auth.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final user = userCredential.user;
      if (user != null) {
        // 사용자의 모임 참여 상태 확인
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          final groupIds = List<String>.from(userData['groupIds'] ?? []);
          
          // 로그인 성공 시 모임 참여 상태에 따라 화면 이동
          if (mounted) {
            if (groupIds.isEmpty) {
              // 모임에 참여하지 않은 경우 온보딩 화면으로 이동
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const OnboardingScreen(),
                ),
              );
            } else {
              // 모임에 참여한 경우 메인 화면으로 이동
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const MainScreen(),
                ),
              );
            }
          }
        } else {
          // 사용자 문서가 없는 경우 온보딩 화면으로 이동
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const OnboardingScreen(),
              ),
            );
          }
        }
      }
    } on auth.FirebaseAuthException catch (e) {
      // 에러 메시지 표시
      String message = '로그인에 실패했습니다.';

      switch (e.code) {
        case 'user-not-found':
          message = '등록되지 않은 이메일입니다.';
          break;
        case 'wrong-password':
          message = '비밀번호가 올바르지 않습니다.';
          break;
        case 'invalid-email':
          message = '올바르지 않은 이메일 형식입니다.';
          break;
        case 'user-disabled':
          message = '비활성화된 계정입니다.';
          break;
        case 'too-many-requests':
          message = '너무 많은 로그인 시도가 있었습니다. 잠시 후 다시 시도해주세요.';
          break;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: DesignSystem.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('로그인 중 오류가 발생했습니다.'),
            backgroundColor: DesignSystem.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: DesignSystem.getScreenPadding(context),
            child: Form(
              key: _formKey,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 앱 로고 및 제목
                      _buildAppLogo(),

                      const SizedBox(height: DesignSystem.spacing32),

                      // 앱 이름
                      Text(
                        '머니투게더',
                        style: DesignSystem.headline1.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: DesignSystem.spacing8),

                      // 앱 설명
                      Text(
                        '함께하는 투명한 금융 관리',
                        style: DesignSystem.body1.copyWith(
                          color: DesignSystem.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: DesignSystem.spacing48),

                      // 이메일 입력 필드
                      AppEmailField(
                        controller: _emailController,
                        isRequired: true,
                      ),

                      const SizedBox(height: DesignSystem.spacing16),

                      // 비밀번호 입력 필드
                      AppPasswordField(
                        controller: _passwordController,
                        isRequired: true,
                      ),

                      const SizedBox(height: DesignSystem.spacing24),

                      // 로그인 버튼
                      AppButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        text: _isLoading ? '로그인 중...' : '로그인',
                        isLoading: _isLoading,
                        isFullWidth: true,
                        size: AppButtonSize.large,
                      ),

                      const SizedBox(height: DesignSystem.spacing16),

                      // 회원가입 링크
                      _buildSignupLink(),

                      const SizedBox(height: DesignSystem.spacing32),

                      // 소셜 로그인 옵션
                      _buildSocialLoginOptions(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppLogo() {
    return Center(
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: DesignSystem.primary,
          borderRadius: BorderRadius.circular(DesignSystem.radiusXLarge),
          boxShadow: DesignSystem.shadowLarge,
        ),
        child: const Icon(
          Icons.account_balance_wallet,
          size: 60,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSignupLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '계정이 없으신가요? ',
          style: DesignSystem.body2.copyWith(color: DesignSystem.textSecondary),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RegisterScreen()),
            );
          },
          child: Text(
            '회원가입',
            style: DesignSystem.body1.copyWith(
              color: DesignSystem.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLoginOptions() {
    return Column(
      children: [
        Text(
          '또는',
          style: DesignSystem.body2.copyWith(color: DesignSystem.textSecondary),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: DesignSystem.spacing16),

        // 구글 로그인 버튼 (향후 구현)
        AppButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('구글 로그인은 준비 중입니다.'),
                backgroundColor: DesignSystem.info,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    DesignSystem.radiusMedium,
                  ),
                ),
              ),
            );
          },
          text: 'Google로 로그인',
          type: AppButtonType.secondary,
          icon: Icons.g_mobiledata,
          isFullWidth: true,
        ),
      ],
    );
  }
}

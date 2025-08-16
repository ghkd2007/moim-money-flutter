import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants/design_system.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../models/models.dart' as models;
import '../../screens/onboarding/onboarding_screen.dart';

/// 회원가입 화면
/// 사용자가 새로운 계정을 생성할 수 있습니다.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// 회원가입 처리
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Firebase Auth로 계정 생성
            final userCredential = await auth.FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final user = userCredential.user;
      if (user != null) {
        // Firestore에 사용자 정보 저장
        final userModel = models.UserModel(
          id: user.uid,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: '', // 선택사항
          profileImageUrl: null,
          groupIds: [],
          settings: {},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(userModel.toMap());

        // 회원가입 성공 시 온보딩 화면으로 이동
        if (mounted) {
          // 성공 메시지 표시
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_nameController.text}님, 회원가입이 완료되었습니다!'),
              backgroundColor: DesignSystem.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
              ),
            ),
          );
          
          // 잠시 후 온보딩 화면으로 이동
          await Future.delayed(const Duration(seconds: 1));
          
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
      String message = '회원가입에 실패했습니다.';

      switch (e.code) {
        case 'weak-password':
          message = '비밀번호가 너무 약합니다.';
          break;
        case 'email-already-in-use':
          message = '이미 사용 중인 이메일입니다.';
          break;
        case 'invalid-email':
          message = '올바르지 않은 이메일 형식입니다.';
          break;
        case 'operation-not-allowed':
          message = '이메일/비밀번호 로그인이 비활성화되어 있습니다.';
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
            content: const Text('회원가입 중 오류가 발생했습니다.'),
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
      appBar: AppBar(
        title: Text(
          '회원가입',
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
                      // 환영 메시지
                      _buildWelcomeMessage(),

                      const SizedBox(height: DesignSystem.spacing48),

                      // 이름 입력 필드
                      AppTextField(
                        label: '이름',
                        hint: '실명을 입력하세요',
                        controller: _nameController,
                        isRequired: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '이름을 입력해주세요.';
                          }
                          if (value.length < 2) {
                            return '이름은 2자 이상이어야 합니다.';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: DesignSystem.spacing16),

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

                      const SizedBox(height: DesignSystem.spacing16),

                      // 비밀번호 확인 입력 필드
                      AppPasswordField(
                        label: '비밀번호 확인',
                        hint: '비밀번호를 다시 입력하세요',
                        controller: _confirmPasswordController,
                        isRequired: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '비밀번호 확인을 입력해주세요.';
                          }
                          if (value != _passwordController.text) {
                            return '비밀번호가 일치하지 않습니다.';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: DesignSystem.spacing32),

                      // 회원가입 버튼
                      AppButton(
                        onPressed: _isLoading ? null : _handleRegister,
                        text: _isLoading ? '회원가입 중...' : '회원가입',
                        isLoading: _isLoading,
                        isFullWidth: true,
                        size: AppButtonSize.large,
                      ),

                      const SizedBox(height: DesignSystem.spacing16),

                      // 로그인 링크
                      _buildLoginLink(),

                      const SizedBox(height: DesignSystem.spacing32),

                      // 이용약관 동의 (향후 구현)
                      _buildTermsAgreement(),
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

  Widget _buildWelcomeMessage() {
    return Column(
      children: [
        Text(
          '머니투게더에\n오신 것을 환영합니다!',
          style: DesignSystem.headline2.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: DesignSystem.spacing8),

        Text(
          '함께하는 투명한 금융 관리를 시작해보세요',
          style: DesignSystem.body1.copyWith(color: DesignSystem.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '이미 계정이 있으신가요? ',
          style: DesignSystem.body2.copyWith(color: DesignSystem.textSecondary),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            '로그인',
            style: DesignSystem.body1.copyWith(
              color: DesignSystem.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsAgreement() {
    return Text(
      '회원가입 시 이용약관과 개인정보처리방침에 동의하는 것으로 간주됩니다.',
      style: DesignSystem.caption.copyWith(color: DesignSystem.textSecondary),
      textAlign: TextAlign.center,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../constants/design_system.dart';
import '../../../widgets/common/app_button.dart';
import '../../../screens/auth/login_screen.dart';

/// 설정 화면
/// 사용자 정보, 앱 설정, 로그아웃 등을 관리하는 화면입니다.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Firebase Auth 사용자 정보
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  /// 현재 사용자 정보 로드
  void _loadCurrentUser() {
    _currentUser = FirebaseAuth.instance.currentUser;
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _currentUser == null
                ? _buildNoUserState()
                : _buildSettingsContent(),
      ),
    );
  }

  /// 사용자가 로그인하지 않은 상태
  Widget _buildNoUserState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off,
            size: 80,
            color: DesignSystem.textSecondary,
          ),
          const SizedBox(height: DesignSystem.spacing24),
          Text(
            '로그인이 필요합니다',
            style: DesignSystem.headline3.copyWith(
              color: DesignSystem.textPrimary,
            ),
          ),
          const SizedBox(height: DesignSystem.spacing16),
          AppButton(
            text: '로그인 화면으로 이동',
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
                (route) => false,
              );
            },
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  /// 설정 콘텐츠
  Widget _buildSettingsContent() {
    return CustomScrollView(
      slivers: [
        // 메인 콘텐츠
        SliverToBoxAdapter(
          child: Padding(
            padding: DesignSystem.getScreenPadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: DesignSystem.spacing24),

                // 사용자 프로필 카드
                _buildProfileCard(),

                const SizedBox(height: DesignSystem.spacing24),

                // 설정 메뉴들
                _buildSettingsSection('계정', [
                  _buildSettingItem(
                    icon: Icons.person_outline,
                    title: '프로필 편집',
                    subtitle: '이름, 프로필 사진 변경',
                    onTap: () {
                      // 프로필 편집 화면으로 이동
                    },
                  ),
                  _buildSettingItem(
                    icon: Icons.email_outlined,
                    title: '이메일 변경',
                    subtitle: '계정 이메일 주소 변경',
                    onTap: () {
                      // 이메일 변경 화면으로 이동
                    },
                  ),
                  _buildSettingItem(
                    icon: Icons.lock_outline,
                    title: '비밀번호 변경',
                    subtitle: '계정 비밀번호 변경',
                    onTap: () {
                      // 비밀번호 변경 화면으로 이동
                    },
                  ),
                ]),

                const SizedBox(height: DesignSystem.spacing24),

                _buildSettingsSection('앱 설정', [
                  _buildSettingItem(
                    icon: Icons.notifications_outlined,
                    title: '알림 설정',
                    subtitle: '푸시 알림, 이메일 알림 설정',
                    onTap: () {
                      // 알림 설정 화면으로 이동
                    },
                  ),
                  _buildSettingItem(
                    icon: Icons.language_outlined,
                    title: '언어 설정',
                    subtitle: '한국어',
                    onTap: () {
                      // 언어 설정 화면으로 이동
                    },
                  ),
                  _buildSettingItem(
                    icon: Icons.dark_mode_outlined,
                    title: '다크 모드',
                    subtitle: '자동',
                    trailing: Switch(
                      value: false,
                      onChanged: (value) {
                        // 다크 모드 토글
                      },
                    ),
                  ),
                ]),

                const SizedBox(height: DesignSystem.spacing24),

                _buildSettingsSection('지원', [
                  _buildSettingItem(
                    icon: Icons.help_outline,
                    title: '도움말',
                    subtitle: '앱 사용법 및 FAQ',
                    onTap: () {
                      // 도움말 화면으로 이동
                    },
                  ),
                  _buildSettingItem(
                    icon: Icons.feedback_outlined,
                    title: '피드백 보내기',
                    subtitle: '의견 및 버그 리포트',
                    onTap: () {
                      // 피드백 화면으로 이동
                    },
                  ),
                  _buildSettingItem(
                    icon: Icons.info_outline,
                    title: '앱 정보',
                    subtitle: '버전 1.0.0',
                    onTap: () {
                      // 앱 정보 화면으로 이동
                    },
                  ),
                ]),

                const SizedBox(height: DesignSystem.spacing32),

                // 로그아웃 버튼
                AppButton(
                  text: '로그아웃',
                  onPressed: () {
                    _showLogoutDialog(context);
                  },
                  type: AppButtonType.secondary,
                  isFullWidth: true,
                ),

                const SizedBox(height: DesignSystem.spacing32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 프로필 카드
  Widget _buildProfileCard() {
    return Card(
      elevation: DesignSystem.shadowSmall[0].blurRadius,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spacing20),
        child: Row(
          children: [
            // 프로필 이미지
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: DesignSystem.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(
                  DesignSystem.radiusCircular,
                ),
              ),
              child: _currentUser != null && _currentUser!.photoURL != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(
                        DesignSystem.radiusCircular,
                      ),
                      child: Image.network(
                        _currentUser!.photoURL!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(Icons.person, size: 40, color: DesignSystem.primary),
            ),

            const SizedBox(width: DesignSystem.spacing20),

            // 사용자 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentUser != null ? _currentUser!.displayName ?? '사용자' : '로딩 중...',
                    style: DesignSystem.headline3.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: DesignSystem.spacing4),
                  Text(
                    _currentUser != null ? _currentUser!.email ?? '이메일 없음' : '로딩 중...',
                    style: DesignSystem.body2.copyWith(
                      color: DesignSystem.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // 편집 버튼
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                // 프로필 편집 화면으로 이동
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 설정 섹션
  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: DesignSystem.headline3.copyWith(
            color: DesignSystem.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: DesignSystem.spacing16),
        Card(
          elevation: DesignSystem.shadowSmall[0].blurRadius,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  /// 설정 아이템
  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spacing20),
        child: Row(
          children: [
            Icon(icon, color: DesignSystem.textSecondary, size: 24),
            const SizedBox(width: DesignSystem.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: DesignSystem.body1.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: DesignSystem.spacing4),
                  Text(
                    subtitle,
                    style: DesignSystem.caption.copyWith(
                      color: DesignSystem.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null)
              trailing
            else if (onTap != null)
              Icon(Icons.chevron_right, color: DesignSystem.textSecondary),
          ],
        ),
      ),
    );
  }

  /// 로그아웃 다이얼로그
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('로그아웃', style: DesignSystem.headline3),
        content: Text('정말 로그아웃 하시겠습니까?', style: DesignSystem.body1),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          AppButton(
            text: '로그아웃',
            onPressed: () async {
              await _logout();
            },
            type: AppButtonType.secondary,
          ),
        ],
      ),
    );
  }

  /// 로그아웃 처리
  Future<void> _logout() async {
    try {
      // Firebase Auth 로그아웃
      await FirebaseAuth.instance.signOut();
      
      // 다이얼로그 닫기
      if (mounted) {
        Navigator.pop(context); // 다이얼로그 닫기
        
        // 로그인 화면으로 이동 (모든 이전 화면 제거)
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
          (route) => false, // 모든 이전 화면 제거
        );
      }
    } catch (e) {
      // 로그아웃 실패 시 에러 메시지
      if (mounted) {
        Navigator.pop(context); // 다이얼로그 닫기
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그아웃 중 오류가 발생했습니다: $e'),
            backgroundColor: DesignSystem.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

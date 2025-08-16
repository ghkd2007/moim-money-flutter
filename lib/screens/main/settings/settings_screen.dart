import 'package:flutter/material.dart';
import '../../../constants/design_system.dart';
import '../../../widgets/common/app_button.dart';

/// 설정 화면
/// 사용자 정보, 앱 설정, 로그아웃 등을 관리하는 화면입니다.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // 임시 사용자 데이터 (추후 Firebase에서 가져올 예정)
  final Map<String, dynamic> _user = {
    'name': '홍길동',
    'email': 'hong@example.com',
    'profileImage': null,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.background,
      body: SafeArea(
        child: CustomScrollView(
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
        ),
      ),
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
              child: _user['profileImage'] != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(
                        DesignSystem.radiusCircular,
                      ),
                      child: Image.network(
                        _user['profileImage'],
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
                    _user['name'],
                    style: DesignSystem.headline3.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: DesignSystem.spacing4),
                  Text(
                    _user['email'],
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
            child: Text('취소'),
          ),
          AppButton(
            text: '로그아웃',
            onPressed: () {
              // 로그아웃 로직 (추후 Firebase 연동)
              Navigator.pop(context);
              // 로그인 화면으로 이동
            },
            type: AppButtonType.secondary,
          ),
        ],
      ),
    );
  }
}

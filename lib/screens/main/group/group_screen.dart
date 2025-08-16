import 'package:flutter/material.dart';
import '../../../constants/design_system.dart';
import '../../../widgets/common/app_button.dart';
import '../../../models/models.dart';
import '../../../services/group_service.dart';
import '../../../services/app_state_service.dart';
import 'create_group_screen.dart';
import 'join_group_screen.dart';

/// 모임 화면
/// 사용자가 참여하고 있는 모든 모임을 보여주고, 모임 생성 및 관리를 제공합니다.
class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  // 현재 사용자 ID (추후 Firebase Auth에서 가져올 예정)
  final String _currentUserId = 'current_user_id';

  // 내가 참여하고 있는 모든 모임
  List<Group> _myGroups = [];
  bool _isLoading = true;

  // GroupService 인스턴스
  final GroupService _groupService = GroupService();
  final AppStateService _appStateService = AppStateService();

  @override
  void initState() {
    super.initState();
    _loadMyGroups();
  }

  /// 내가 참여하고 있는 모임들 로드
  Future<void> _loadMyGroups() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('🔍 모임 목록 로드 시작...');
      final groups = await _groupService.getMyGroups('current_user_id');
      print('✅ 모임 목록 로드 완료: ${groups.length}개');

      setState(() {
        _myGroups = groups;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ 모임 목록 로드 오류: $e');
      setState(() {
        _myGroups = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 헤더
            SliverToBoxAdapter(
              child: Padding(
                padding: DesignSystem.getScreenPadding(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: DesignSystem.spacing24),

                    // 제목
                    Text(
                      '내 모임',
                      style: DesignSystem.headline1.copyWith(
                        color: DesignSystem.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: DesignSystem.spacing8),

                    // 부제목
                    Text(
                      '참여하고 있는 모임들을 관리하세요',
                      style: DesignSystem.body1.copyWith(
                        color: DesignSystem.textSecondary,
                      ),
                    ),

                    const SizedBox(height: DesignSystem.spacing32),
                  ],
                ),
              ),
            ),

            // 모임 리스트
            if (_isLoading)
              // 로딩 중
              SliverToBoxAdapter(
                child: Padding(
                  padding: DesignSystem.getScreenPadding(context),
                  child: _buildLoadingState(),
                ),
              )
            else if (_myGroups.isEmpty)
              // 모임이 없을 때
              SliverToBoxAdapter(
                child: Padding(
                  padding: DesignSystem.getScreenPadding(context),
                  child: _buildEmptyState(),
                ),
              )
            else
              // 모임이 있을 때
              SliverPadding(
                padding: DesignSystem.getScreenPadding(context),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final group = _myGroups[index];
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: DesignSystem.spacing16,
                      ),
                      child: _buildGroupCard(group),
                    );
                  }, childCount: _myGroups.length),
                ),
              ),

            // 하단 여백
            const SliverToBoxAdapter(
              child: SizedBox(height: DesignSystem.spacing32),
            ),
          ],
        ),
      ),

      // 모임 생성 버튼 제거
    );
  }

  /// 모임이 없을 때 표시할 빈 상태
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spacing24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 빈 상태 아이콘
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: DesignSystem.surface,
                borderRadius: BorderRadius.circular(60),
                boxShadow: [DesignSystem.shadowSmall[0]],
              ),
              child: Icon(
                Icons.group_outlined,
                size: 60,
                color: DesignSystem.textSecondary,
              ),
            ),

            const SizedBox(height: DesignSystem.spacing24),

            // 메인 메시지
            Text(
              '아직 참여한 모임이 없어요',
              style: DesignSystem.headline3.copyWith(
                color: DesignSystem.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: DesignSystem.spacing12),

            // 부가 설명
            Text(
              '첫 번째 모임을 만들어보거나\n친구가 만든 모임에 참여해보세요!',
              style: DesignSystem.body1.copyWith(
                color: DesignSystem.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: DesignSystem.spacing32),

            // 모임 만들기 버튼 (주요 액션)
            AppButton(
              onPressed: () => _showCreateGroupScreen(),
              text: '모임 만들기',
              isFullWidth: true,
              size: AppButtonSize.large,
            ),

            const SizedBox(height: DesignSystem.spacing16),

            // 참여 코드로 입장 버튼 (보조 액션)
            AppButton(
              onPressed: () => _showJoinGroupScreen(),
              text: '참여 코드로 입장',
              type: AppButtonType.secondary,
              isFullWidth: true,
              size: AppButtonSize.large,
            ),

            const SizedBox(height: DesignSystem.spacing24),

            // 도움말 텍스트
            Container(
              padding: const EdgeInsets.all(DesignSystem.spacing16),
              decoration: BoxDecoration(
                color: DesignSystem.surface,
                borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
                border: Border.all(color: DesignSystem.divider, width: 1),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 20,
                        color: DesignSystem.warning,
                      ),
                      const SizedBox(width: DesignSystem.spacing8),
                      Text(
                        '모임이란?',
                        style: DesignSystem.body2.copyWith(
                          fontWeight: FontWeight.w600,
                          color: DesignSystem.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignSystem.spacing8),
                  Text(
                    '친구들과 함께 지출을 관리하고\n예산을 계획할 수 있는 공간이에요.',
                    style: DesignSystem.caption.copyWith(
                      color: DesignSystem.textSecondary,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 모임 카드 위젯
  Widget _buildGroupCard(Group group) {
    final isOwner = group.isOwner(_currentUserId);

    return Container(
      decoration: BoxDecoration(
        color: DesignSystem.surface,
        borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
        boxShadow: [DesignSystem.shadowSmall[0]],
        border: Border.all(
          color: isOwner
              ? DesignSystem.primary.withOpacity(0.3)
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToGroupDetail(group),
          borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
          child: Padding(
            padding: const EdgeInsets.all(DesignSystem.spacing20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 모임 헤더
                Row(
                  children: [
                    // 모임 아이콘
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: DesignSystem.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          DesignSystem.radiusMedium,
                        ),
                      ),
                      child: Icon(
                        Icons.group,
                        color: DesignSystem.primary,
                        size: 24,
                      ),
                    ),

                    const SizedBox(width: DesignSystem.spacing16),

                    // 모임 정보
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  group.name,
                                  style: DesignSystem.headline3.copyWith(
                                    color: DesignSystem.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              // 모임장 배지
                              if (isOwner)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: DesignSystem.spacing8,
                                    vertical: DesignSystem.spacing4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: DesignSystem.primary,
                                    borderRadius: BorderRadius.circular(
                                      DesignSystem.radiusSmall,
                                    ),
                                  ),
                                  child: Text(
                                    '모임장',
                                    style: DesignSystem.caption.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          if (group.description != null &&
                              group.description!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: DesignSystem.spacing4,
                              ),
                              child: Text(
                                group.description!,
                                style: DesignSystem.body2.copyWith(
                                  color: DesignSystem.textSecondary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ),

                    // 더보기 버튼
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: DesignSystem.textSecondary,
                      ),
                      onSelected: (value) => _handleGroupAction(value, group),
                      itemBuilder: (context) => [
                        if (isOwner) ...[
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 8),
                                Text('모임 수정'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  '모임 삭제',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          const PopupMenuItem(
                            value: 'leave',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.exit_to_app,
                                  size: 20,
                                  color: Colors.orange,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '모임 나가기',
                                  style: TextStyle(color: Colors.orange),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const PopupMenuItem(
                          value: 'invite',
                          child: Row(
                            children: [
                              Icon(Icons.person_add, size: 20),
                              SizedBox(width: 8),
                              Text('멤버 초대'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: DesignSystem.spacing16),

                // 모임 통계
                Row(
                  children: [
                    // 멤버 수
                    _buildStatItem(
                      icon: Icons.people,
                      label: '멤버',
                      value: '${group.members.length}명',
                      color: DesignSystem.info,
                    ),

                    const SizedBox(width: DesignSystem.spacing24),

                    // 카테고리 수
                    _buildStatItem(
                      icon: Icons.category,
                      label: '카테고리',
                      value: '${group.categories.length}개',
                      color: DesignSystem.warning,
                    ),

                    const SizedBox(width: DesignSystem.spacing24),

                    // 거래 내역 수
                    _buildStatItem(
                      icon: Icons.receipt_long,
                      label: '거래',
                      value: '${group.transactions.length}건',
                      color: DesignSystem.success,
                    ),
                  ],
                ),

                const SizedBox(height: DesignSystem.spacing16),

                // 모임 생성일
                Text(
                  '${group.createdAt.year}년 ${group.createdAt.month}월 ${group.createdAt.day}일 생성',
                  style: DesignSystem.caption.copyWith(
                    color: DesignSystem.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 통계 아이템 위젯
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: DesignSystem.spacing4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: DesignSystem.body2.copyWith(
                    color: DesignSystem.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  label,
                  style: DesignSystem.caption.copyWith(
                    color: DesignSystem.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 모임 생성 화면으로 이동
  void _showCreateGroupScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateGroupScreen()),
    ).then((_) {
      // 모임 생성 후 목록 새로고침
      _loadMyGroups();
    });
  }

  /// 모임 상세 화면으로 이동
  void _navigateToGroupDetail(Group group) {
    // 선택된 모임을 AppStateService에 설정
    _appStateService.selectGroup(group);

    // 성공 메시지 표시
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${group.name} 모임이 선택되었습니다. 홈 탭에서 확인하세요.'),
        backgroundColor: DesignSystem.success,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// 모임 액션 처리
  void _handleGroupAction(String action, Group group) {
    switch (action) {
      case 'edit':
        _editGroup(group);
        break;
      case 'delete':
        _deleteGroup(group);
        break;
      case 'leave':
        _leaveGroup(group);
        break;
      case 'invite':
        _inviteMembers(group);
        break;
    }
  }

  /// 모임 수정
  void _editGroup(Group group) {
    // TODO: 모임 수정 화면 구현
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${group.name} 수정 기능은 준비 중입니다.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// 모임 삭제
  void _deleteGroup(Group group) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('모임 삭제'),
        content: Text('정말로 "${group.name}" 모임을 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Firebase에서 모임 삭제
              setState(() {
                _myGroups.removeWhere((g) => g.id == group.id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${group.name} 모임이 삭제되었습니다.'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  /// 모임 나가기
  void _leaveGroup(Group group) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('모임 나가기'),
        content: Text('정말로 "${group.name}" 모임에서 나가시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Firebase에서 모임 멤버 제거
              setState(() {
                _myGroups.removeWhere((g) => g.id == group.id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${group.name} 모임에서 나갔습니다.'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('나가기'),
          ),
        ],
      ),
    );
  }

  /// 멤버 초대
  void _inviteMembers(Group group) {
    // TODO: 멤버 초대 기능 구현
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${group.name} 멤버 초대 기능은 준비 중입니다.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// 참여 코드로 입장 화면으로 이동
  void _showJoinGroupScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const JoinGroupScreen()),
    ).then((_) {
      // 참여 코드로 입장 후 목록 새로고침
      _loadMyGroups();
    });
  }

  /// 로딩 상태 위젯
  Widget _buildLoadingState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 80),
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(DesignSystem.primary),
        ),
        const SizedBox(height: DesignSystem.spacing24),
        Text(
          '모임 목록을 불러오는 중...',
          style: DesignSystem.body1.copyWith(color: DesignSystem.textSecondary),
        ),
      ],
    );
  }
}

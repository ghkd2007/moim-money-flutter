import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../constants/design_system.dart';
import '../../../widgets/common/app_button.dart';
import '../../../models/models.dart';
import '../../../services/transaction_service.dart';
import '../../../services/group_service.dart';
import '../../../services/app_state_service.dart';
import '../../../services/category_service.dart';
import '../group/create_group_screen.dart';

/// 홈 화면
/// 예산, 캘린더, 거래 내역을 보여주는 메인 화면입니다.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _budget = 500000; // 기본 예산 50만원
  bool _isEditingBudget = false;
  final TextEditingController _budgetController = TextEditingController();

  // 달력 상태
  DateTime _focusedDay = DateTime.now();

  // 데이터베이스 연동
  final TransactionService _transactionService = TransactionService();
  final GroupService _groupService = GroupService();
  final AppStateService _appStateService = AppStateService();
  final CategoryService _categoryService = CategoryService();
  List<Transaction> _transactions = [];
  Map<String, dynamic> _groupStatistics = {};
  bool _isLoading = true;

  // 거래 추가 모달 상태
  String _selectedTransactionType = 'expense'; // 기본값: 지출

  // 카테고리 데이터 (Firebase에서 동적으로 로드)
  Map<String, Category> _categories = {};

  // 거래 내역 데이터 (Firebase에서 동적으로 로드)
  Map<String, List<Transaction>> _transactionsByDate = {};

  @override
  void initState() {
    super.initState();
    _budgetController.text = _budget.toInt().toString();

    // AppStateService 리스너 등록
    _appStateService.addListener(_onAppStateChanged);

    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 화면이 다시 포커스될 때 데이터 새로고침
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _appStateService.removeListener(_onAppStateChanged);
    _budgetController.dispose();
    super.dispose();
  }

  /// AppStateService 상태 변경 리스너
  void _onAppStateChanged() {
    if (mounted) {
      setState(() {});
      _loadData();
    }
  }

  /// 데이터 로드
  Future<void> _loadData() async {
    print('🔍 데이터 로드 시작...');
    setState(() {
      _isLoading = true;
    });

    try {
      // 1. AppStateService에서 현재 모임 정보 가져오기
      final currentGroup = _appStateService.selectedGroup;
      final myGroups = _appStateService.myGroups;

      print('👥 현재 모임: ${currentGroup?.name ?? '없음'}');
      print('👥 전체 모임 수: ${myGroups.length}개');

      // 2. 현재 모임의 카테고리, 거래 내역, 통계 로드
      if (currentGroup != null) {
        print('🏷️ 카테고리 조회 중...');
        final categories = await _categoryService.getCategoriesByGroup(
          currentGroup.id,
        );
        print('✅ 카테고리 조회 완료: ${categories.length}개');

        // 카테고리를 Map으로 변환
        _categories.clear();
        for (final category in categories) {
          _categories[category.id] = category;
        }

        print('📊 거래 내역 조회 중...');
        final transactions = await _transactionService.getTransactionsByGroup(
          currentGroup.id,
        );
        print('✅ 거래 내역 조회 완료: ${transactions.length}개');

        // 거래 내역을 날짜별로 그룹화
        _transactionsByDate.clear();
        for (final transaction in transactions) {
          final dateKey =
              '${transaction.date.year}-${transaction.date.month.toString().padLeft(2, '0')}-${transaction.date.day.toString().padLeft(2, '0')}';
          _transactionsByDate.putIfAbsent(dateKey, () => []).add(transaction);
        }

        print('📈 통계 계산 중...');
        final statistics = await _groupService.getGroupStatistics(
          currentGroup.id,
        );
        print('✅ 통계 계산 완료: $statistics');

        setState(() {
          _transactions = transactions;
          _groupStatistics = statistics;
          _isLoading = false;
        });
      } else {
        // 모임이 없는 경우
        setState(() {
          _categories.clear();
          _transactionsByDate.clear();
          _transactions = [];
          _groupStatistics = {
            'totalIncome': 0.0,
            'totalExpense': 0.0,
            'remainingBudget': 0.0,
            'transactionCount': 0,
            'memberCount': 0,
          };
          _isLoading = false;
        });
      }
      print('🎉 데이터 로드 완료!');
    } catch (e) {
      print('❌ 데이터 로드 오류: $e');
      // 오류 발생 시 기본값 사용
      setState(() {
        _transactions = [];
        _groupStatistics = {
          'totalIncome': 0.0,
          'totalExpense': 0.0,
          'remainingBudget': 0.0,
          'transactionCount': 0,
          'memberCount': 0,
        };
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
            // 메인 콘텐츠
            SliverToBoxAdapter(
              child: Padding(
                padding: DesignSystem.getScreenPadding(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: DesignSystem.spacing24),

                    // 모임 이름 (타이틀 형태)
                    _buildGroupNameTitle(),

                    const SizedBox(height: DesignSystem.spacing24),

                    // 예산 카드
                    _buildBudgetCard(),

                    const SizedBox(height: DesignSystem.spacing24),

                    // 수입/지출 통계 카드
                    _buildIncomeExpenseStatsCard(),

                    const SizedBox(height: DesignSystem.spacing24),

                    // 캘린더 카드
                    _buildCalendarCard(),

                    const SizedBox(height: DesignSystem.spacing24),

                    // 최근 거래 내역 카드
                    _buildRecentTransactionsCard(),

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

  /// 모임 이름 (타이틀 형태) - 현대적
  Widget _buildGroupNameTitle() {
    return Container(
      margin: const EdgeInsets.only(bottom: DesignSystem.spacing24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(DesignSystem.spacing12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    DesignSystem.radiusCircular,
                  ),
                  gradient: DesignSystem.primaryGradient,
                ),
                child: const Icon(Icons.group, color: Colors.white, size: 24),
              ),
              const SizedBox(width: DesignSystem.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Builder(
                      builder: (context) {
                        final currentGroup = _appStateService.selectedGroup;
                        if (currentGroup != null) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentGroup.name,
                                style: DesignSystem.headline1.copyWith(
                                  color: DesignSystem.textPrimary,
                                ),
                              ),
                              if (currentGroup.description != null &&
                                  currentGroup.description!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: DesignSystem.spacing4,
                                  ),
                                  child: Text(
                                    currentGroup.description!,
                                    style: DesignSystem.body2.copyWith(
                                      color: DesignSystem.textSecondary,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        } else {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '모임이 없습니다',
                                style: DesignSystem.headline1.copyWith(
                                  color: DesignSystem.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: DesignSystem.spacing4,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '새로운 모임을 만들어보세요!',
                                      style: DesignSystem.body2.copyWith(
                                        color: DesignSystem.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: DesignSystem.spacing8,
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const CreateGroupScreen(),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.add, size: 18),
                                      label: const Text('모임 만들기'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: DesignSystem.primary,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: DesignSystem.spacing16,
                                          vertical: DesignSystem.spacing8,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              // 모임 변경 버튼
              IconButton(
                onPressed: _showGroupSelector,
                icon: Icon(Icons.swap_horiz, color: DesignSystem.textSecondary),
                tooltip: '모임 변경',
              ),
            ],
          ),
          const SizedBox(height: DesignSystem.spacing12),
          Container(
            width: 60,
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DesignSystem.radiusCircular),
              gradient: DesignSystem.primaryGradient,
            ),
          ),
        ],
      ),
    );
  }

  /// 예산 카드 (현대적)
  Widget _buildBudgetCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DesignSystem.radiusXLarge),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DesignSystem.primary.withOpacity(0.05),
            DesignSystem.primary.withOpacity(0.1),
          ],
        ),
        border: Border.all(
          color: DesignSystem.primary.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: DesignSystem.shadowSoft,
      ),
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spacing24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(DesignSystem.spacing8),
                      decoration: BoxDecoration(
                        color: DesignSystem.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          DesignSystem.radiusMedium,
                        ),
                      ),
                      child: Icon(
                        Icons.account_balance_wallet,
                        color: DesignSystem.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: DesignSystem.spacing12),
                    Text(
                      '이번 달 예산',
                      style: DesignSystem.headline3.copyWith(
                        color: DesignSystem.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: DesignSystem.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      DesignSystem.radiusCircular,
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(
                      _isEditingBudget ? Icons.check : Icons.edit,
                      color: DesignSystem.primary,
                      size: 20,
                    ),
                    onPressed: () {
                      if (_isEditingBudget) {
                        _saveBudget();
                      }
                      setState(() {
                        _isEditingBudget = !_isEditingBudget;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignSystem.spacing20),
            if (_isEditingBudget) ...[
              TextField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                style: DesignSystem.displayLarge.copyWith(
                  color: DesignSystem.primary,
                  fontWeight: FontWeight.w800,
                ),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      DesignSystem.radiusMedium,
                    ),
                    borderSide: BorderSide(
                      color: DesignSystem.primary.withOpacity(0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      DesignSystem.radiusMedium,
                    ),
                    borderSide: BorderSide(
                      color: DesignSystem.primary.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      DesignSystem.radiusMedium,
                    ),
                    borderSide: BorderSide(
                      color: DesignSystem.primary,
                      width: 2,
                    ),
                  ),
                  suffixText: '원',
                  suffixStyle: DesignSystem.body1.copyWith(
                    color: DesignSystem.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ] else ...[
              Text(
                '${_budget.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                style: DesignSystem.displayLarge.copyWith(
                  color: DesignSystem.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
            const SizedBox(height: DesignSystem.spacing20),
            // 예산 사용 비율과 통계를 하나로 통합
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '예산 사용률',
                        style: DesignSystem.body2.copyWith(
                          color: DesignSystem.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: DesignSystem.spacing8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          DesignSystem.radiusCircular,
                        ),
                        child: LinearProgressIndicator(
                          value: _groupStatistics['totalExpense'] != null
                              ? (_groupStatistics['totalExpense'] / _budget)
                                    .clamp(0.0, 1.0)
                              : 0.0,
                          backgroundColor: DesignSystem.divider.withOpacity(
                            0.3,
                          ),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            DesignSystem.primary,
                          ),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: DesignSystem.spacing4),
                      Text(
                        '${_groupStatistics['totalExpense'] != null ? ((_groupStatistics['totalExpense'] / _budget) * 100).clamp(0.0, 100.0).toInt() : 0}% 사용',
                        style: DesignSystem.caption.copyWith(
                          color: DesignSystem.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: DesignSystem.spacing24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '남은 예산',
                      style: DesignSystem.body2.copyWith(
                        color: DesignSystem.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: DesignSystem.spacing8),
                    Text(
                      '${_groupStatistics['totalExpense'] != null ? (_budget - _groupStatistics['totalExpense']).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},') : _budget.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                      style: DesignSystem.headline3.copyWith(
                        color: DesignSystem.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 캘린더 카드
  Widget _buildCalendarCard() {
    return Card(
      elevation: DesignSystem.shadowSmall[0].blurRadius,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spacing20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '이번 달 거래 내역',
              style: DesignSystem.headline3.copyWith(
                color: DesignSystem.textPrimary,
              ),
            ),
            const SizedBox(height: DesignSystem.spacing16),

            // 커스텀 달력 헤더
            _buildCalendarHeader(),

            const SizedBox(height: DesignSystem.spacing16),

            Container(
              height: 280, // 높이 조정
              decoration: BoxDecoration(
                color: DesignSystem.background,
                borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
              ),
              child: Stack(
                children: [
                  TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) {
                      return isSameDay(day, DateTime.now());
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      _showTransactionsForDate(selectedDay);
                    },
                    onPageChanged: (focusedDay) {
                      setState(() {
                        _focusedDay = focusedDay;
                      });
                    },
                    // 거래 내역이 있는 날짜에 이벤트 마커 표시 (수입/지출 구분)
                    eventLoader: (day) {
                      final dayTransactions = _transactions
                          .where(
                            (transaction) => isSameDay(transaction.date, day),
                          )
                          .toList();

                      if (dayTransactions.isEmpty) return [];

                      // 수입과 지출 구분하여 마커 생성
                      final hasIncome = dayTransactions.any((t) => t.isIncome);
                      final hasExpense = dayTransactions.any(
                        (t) => !t.isIncome,
                      );

                      if (hasIncome && hasExpense) {
                        return ['mixed']; // 수입+지출
                      } else if (hasIncome) {
                        return ['income']; // 수입만
                      } else {
                        return ['expense']; // 지출만
                      }
                    },
                    // 오늘 날짜 스타일 커스터마이징
                    calendarStyle: CalendarStyle(
                      selectedDecoration: BoxDecoration(
                        color: DesignSystem.primary,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: DesignSystem.primary.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      defaultDecoration: BoxDecoration(shape: BoxShape.circle),
                      weekendDecoration: BoxDecoration(shape: BoxShape.circle),
                      outsideDecoration: BoxDecoration(shape: BoxShape.circle),
                      // 이벤트 마커 스타일 (수입/지출 구분)
                      markerDecoration: BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      markerSize: 8,
                      markerMargin: const EdgeInsets.symmetric(horizontal: 1),
                    ),
                    headerVisible: false, // 기본 헤더 숨김
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: DesignSystem.body2.copyWith(
                        fontWeight: FontWeight.w600,
                        color: DesignSystem.textSecondary,
                      ),
                      weekendStyle: DesignSystem.body2.copyWith(
                        fontWeight: FontWeight.w600,
                        color: DesignSystem.textSecondary,
                      ),
                    ),
                    calendarFormat: CalendarFormat.month,
                    startingDayOfWeek: StartingDayOfWeek.monday,
                  ),
                  // 커스텀 마커 오버레이 (수입/지출 색상 구분)
                  ..._buildCustomMarkers(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 수입/지출 통계 카드
  Widget _buildIncomeExpenseStatsCard() {
    return Row(
      children: [
        // 수입 통계 카드
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  DesignSystem.income.withOpacity(0.1),
                  DesignSystem.income.withOpacity(0.05),
                ],
              ),
              border: Border.all(
                color: DesignSystem.income.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: DesignSystem.shadowSoft,
            ),
            child: Padding(
              padding: const EdgeInsets.all(DesignSystem.spacing20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(DesignSystem.spacing8),
                        decoration: BoxDecoration(
                          color: DesignSystem.income.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(
                            DesignSystem.radiusMedium,
                          ),
                        ),
                        child: Icon(
                          Icons.trending_up,
                          color: DesignSystem.income,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: DesignSystem.spacing12),
                      Text(
                        '이번 달 수입',
                        style: DesignSystem.body2.copyWith(
                          color: DesignSystem.income,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignSystem.spacing16),
                  Text(
                    '${_groupStatistics['totalIncome']?.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},') ?? '0'}원',
                    style: DesignSystem.headline3.copyWith(
                      color: DesignSystem.income,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: DesignSystem.spacing16),
        // 지출 통계 카드
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  DesignSystem.expense.withOpacity(0.1),
                  DesignSystem.expense.withOpacity(0.05),
                ],
              ),
              border: Border.all(
                color: DesignSystem.expense.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: DesignSystem.shadowSoft,
            ),
            child: Padding(
              padding: const EdgeInsets.all(DesignSystem.spacing20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(DesignSystem.spacing8),
                        decoration: BoxDecoration(
                          color: DesignSystem.expense.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(
                            DesignSystem.radiusMedium,
                          ),
                        ),
                        child: Icon(
                          Icons.trending_down,
                          color: DesignSystem.expense,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: DesignSystem.spacing12),
                      Text(
                        '이번 달 지출',
                        style: DesignSystem.body2.copyWith(
                          color: DesignSystem.expense,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignSystem.spacing16),
                  Text(
                    '${_groupStatistics['totalExpense']?.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},') ?? '0'}원',
                    style: DesignSystem.headline3.copyWith(
                      color: DesignSystem.expense,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 커스텀 마커 생성 (수입/지출 색상 구분)
  List<Widget> _buildCustomMarkers() {
    final List<Widget> markers = [];
    final currentMonth = DateTime(_focusedDay.year, _focusedDay.month);

    for (final transaction in _transactions) {
      if (transaction.date.year == currentMonth.year &&
          transaction.date.month == currentMonth.month) {
        // 달력에서 해당 날짜의 위치 계산
        final dayOfWeek = transaction.date.weekday;
        final weekOfMonth = ((transaction.date.day - 1) / 7).floor();

        // 마커 색상 결정
        Color markerColor;
        if (transaction.isIncome) {
          markerColor = DesignSystem.income;
        } else {
          markerColor = DesignSystem.expense;
        }

        // 마커 위치 계산 (대략적인 위치)
        final left = 20.0 + (dayOfWeek - 1) * 40.0;
        final top = 80.0 + weekOfMonth * 35.0;

        markers.add(
          Positioned(
            left: left,
            top: top,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: markerColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      }
    }

    return markers;
  }

  /// 커스텀 달력 헤더
  Widget _buildCalendarHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 이전 월 버튼
        IconButton(
          onPressed: () {
            setState(() {
              _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
            });
          },
          icon: Icon(Icons.chevron_left, color: DesignSystem.primary, size: 28),
        ),

        // 현재 월 표시
        Text(
          '${_focusedDay.year}년 ${_focusedDay.month}월',
          style: DesignSystem.headline3.copyWith(
            color: DesignSystem.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),

        // 다음 월 버튼
        IconButton(
          onPressed: () {
            setState(() {
              _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
            });
          },
          icon: Icon(
            Icons.chevron_right,
            color: DesignSystem.primary,
            size: 28,
          ),
        ),
      ],
    );
  }

  /// 특정 날짜의 거래 내역 모달 표시
  void _showTransactionsForDate(DateTime date) {
    // 해당 날짜의 실제 거래 내역 조회
    final dayTransactions = _transactions
        .where((transaction) => isSameDay(transaction.date, date))
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: DesignSystem.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(DesignSystem.radiusLarge),
          ),
        ),
        child: Column(
          children: [
            // 헤더
            Container(
              padding: const EdgeInsets.all(DesignSystem.spacing20),
              decoration: BoxDecoration(
                color: DesignSystem.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(DesignSystem.radiusLarge),
                ),
                boxShadow: DesignSystem.shadowSmall,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${date.month}월 ${date.day}일 거래 내역',
                    style: DesignSystem.headline3.copyWith(
                      color: DesignSystem.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // 거래 내역 목록
            Expanded(
              child: dayTransactions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_note,
                            size: 64,
                            color: DesignSystem.textSecondary.withOpacity(0.5),
                          ),
                          const SizedBox(height: DesignSystem.spacing16),
                          Text(
                            '거래 내역이 없습니다',
                            style: DesignSystem.body1.copyWith(
                              color: DesignSystem.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(DesignSystem.spacing20),
                      itemCount: dayTransactions.length,
                      itemBuilder: (context, index) {
                        final transaction = dayTransactions[index];
                        final category = _categories[transaction.categoryId];
                        return _buildTransactionItemWithActions(
                          category?.name ?? '알 수 없음',
                          transaction.amount,
                          transaction.description ?? '',
                          transaction.date,
                          transaction.id,
                        );
                      },
                    ),
            ),

            // 새 거래 추가 버튼
            if (dayTransactions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(DesignSystem.spacing20),
                child: AppButton(
                  text: '새 거래 추가',
                  onPressed: () {
                    Navigator.pop(context);
                    _showAddTransactionModal();
                  },
                  isFullWidth: true,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 최근 거래 내역 카드
  Widget _buildRecentTransactionsCard() {
    return Card(
      elevation: DesignSystem.shadowSmall[0].blurRadius,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spacing20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '최근 거래 내역',
                  style: DesignSystem.headline3.copyWith(
                    color: DesignSystem.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: _loadData,
                      icon: Icon(
                        Icons.refresh,
                        color: DesignSystem.primary,
                        size: 20,
                      ),
                      tooltip: '새로고침',
                    ),
                    TextButton(
                      onPressed: () {
                        // 전체 거래 내역 화면으로 이동
                      },
                      child: Text(
                        '전체보기',
                        style: TextStyle(color: DesignSystem.primary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: DesignSystem.spacing16),
            // 실제 거래 내역 데이터 표시
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(DesignSystem.spacing24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_transactions.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 48,
                      color: DesignSystem.textSecondary.withOpacity(0.5),
                    ),
                    const SizedBox(height: DesignSystem.spacing16),
                    Text(
                      '아직 거래 내역이 없습니다',
                      style: DesignSystem.body1.copyWith(
                        color: DesignSystem.textSecondary,
                      ),
                    ),
                    const SizedBox(height: DesignSystem.spacing8),
                    Text(
                      '플로팅 버튼을 눌러 첫 거래를 추가해보세요!',
                      style: DesignSystem.caption.copyWith(
                        color: DesignSystem.textSecondary.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: DesignSystem.spacing16),
                    AppButton(
                      text: '첫 거래 추가하기',
                      onPressed: _showAddTransactionModal,
                      type: AppButtonType.secondary,
                    ),
                  ],
                ),
              )
            else
              ..._transactions.take(5).map((transaction) {
                final category = _categories[transaction.categoryId];
                return _buildTransactionItem(
                  category?.name ?? '알 수 없음',
                  transaction.amount,
                  transaction.description ?? '',
                  transaction.date,
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  /// 거래 내역 아이템 (수정/삭제 기능 포함)
  Widget _buildTransactionItemWithActions(
    String categoryName,
    int amount,
    String description,
    DateTime date,
    String id,
  ) {
    final isExpense = amount < 0;
    final color = isExpense ? DesignSystem.expense : DesignSystem.income;
    final icon = isExpense ? Icons.remove_circle : Icons.add_circle;

    return Card(
      margin: const EdgeInsets.only(bottom: DesignSystem.spacing12),
      elevation: DesignSystem.shadowSmall[0].blurRadius,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spacing16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: DesignSystem.spacing12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoryName,
                    style: DesignSystem.body1.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (description.isNotEmpty)
                    Text(
                      description,
                      style: DesignSystem.caption.copyWith(
                        color: DesignSystem.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isExpense ? '-' : '+'}${amount.abs().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                  style: DesignSystem.body1.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 16),
                      onPressed: () => _editTransaction(id),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 16),
                      onPressed: () => _deleteTransaction(id),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 거래 내역 아이템 (기본)
  Widget _buildTransactionItem(
    String categoryName,
    int amount,
    String description,
    DateTime date,
  ) {
    final isExpense = amount < 0;
    final color = isExpense ? DesignSystem.expense : DesignSystem.income;
    final icon = isExpense ? Icons.remove_circle : Icons.add_circle;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DesignSystem.spacing8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: DesignSystem.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoryName,
                  style: DesignSystem.body1.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (description.isNotEmpty)
                  Text(
                    description,
                    style: DesignSystem.caption.copyWith(
                      color: DesignSystem.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isExpense ? '-' : '+'}${amount.abs().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                style: DesignSystem.body1.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${date.month}/${date.day}',
                style: DesignSystem.caption.copyWith(
                  color: DesignSystem.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 예산 저장
  void _saveBudget() {
    final newBudget = double.tryParse(_budgetController.text);
    if (newBudget != null && newBudget > 0) {
      setState(() {
        _budget = newBudget;
      });
    }
  }

  /// 거래 내역 수정
  void _editTransaction(String id) {
    // 거래 내역 수정 화면으로 이동
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('거래 내역 수정 기능은 준비 중입니다.'),
        backgroundColor: DesignSystem.info,
      ),
    );
  }

  /// 거래 내역 삭제
  void _deleteTransaction(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('거래 내역 삭제'),
        content: Text('정말 이 거래 내역을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          AppButton(
            text: '삭제',
            onPressed: () {
              // 삭제 로직 (추후 Firebase 연동)
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('거래 내역이 삭제되었습니다.'),
                  backgroundColor: DesignSystem.success,
                ),
              );
            },
            type: AppButtonType.secondary,
          ),
        ],
      ),
    );
  }

  /// 거래 추가 모달 표시
  void _showAddTransactionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true, // 드래그로 닫기 가능
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6, // 60%로 줄임
        decoration: const BoxDecoration(
          color: DesignSystem.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(DesignSystem.radiusLarge),
          ),
        ),
        child: Column(
          children: [
            // 드래그 핸들
            Container(
              margin: const EdgeInsets.only(top: DesignSystem.spacing8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: DesignSystem.divider,
                borderRadius: BorderRadius.circular(
                  DesignSystem.radiusCircular,
                ),
              ),
            ),
            // 헤더
            Container(
              padding: const EdgeInsets.all(DesignSystem.spacing20),
              decoration: BoxDecoration(
                color: DesignSystem.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(DesignSystem.radiusLarge),
                ),
                boxShadow: DesignSystem.shadowSmall,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '새 거래 추가',
                    style: DesignSystem.headline3.copyWith(
                      color: DesignSystem.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // 거래 추가 폼
            Expanded(child: _buildAddTransactionForm()),
          ],
        ),
      ),
    );
  }

  /// 거래 추가 폼
  Widget _buildAddTransactionForm() {
    return Padding(
      padding: const EdgeInsets.all(DesignSystem.spacing20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 거래 유형 선택
          Text(
            '거래 유형',
            style: DesignSystem.body1.copyWith(
              color: DesignSystem.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DesignSystem.spacing12),
          Row(
            children: [
              Expanded(
                child: _buildTransactionTypeButton(
                  type: 'income',
                  label: '수입',
                  icon: Icons.add_circle,
                  color: DesignSystem.income,
                ),
              ),
              const SizedBox(width: DesignSystem.spacing12),
              Expanded(
                child: _buildTransactionTypeButton(
                  type: 'expense',
                  label: '지출',
                  icon: Icons.remove_circle,
                  color: DesignSystem.expense,
                ),
              ),
            ],
          ),

          const SizedBox(height: DesignSystem.spacing24),

          // 금액 입력
          Text(
            '금액',
            style: DesignSystem.body1.copyWith(
              color: DesignSystem.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DesignSystem.spacing12),
          TextField(
            keyboardType: TextInputType.number,
            style: DesignSystem.headline3.copyWith(
              color: DesignSystem.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: '0',
              suffixText: '원',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
                borderSide: BorderSide(color: DesignSystem.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
                borderSide: BorderSide(color: DesignSystem.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
                borderSide: BorderSide(color: DesignSystem.primary, width: 2),
              ),
            ),
          ),

          const SizedBox(height: DesignSystem.spacing24),

          // 카테고리 선택
          Text(
            '카테고리',
            style: DesignSystem.body1.copyWith(
              color: DesignSystem.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DesignSystem.spacing12),
          _buildCategorySelector(),

          const SizedBox(height: DesignSystem.spacing24),

          // 설명 입력
          Text(
            '설명 (선택사항)',
            style: DesignSystem.body1.copyWith(
              color: DesignSystem.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DesignSystem.spacing12),
          TextField(
            style: DesignSystem.body1.copyWith(color: DesignSystem.textPrimary),
            decoration: InputDecoration(
              hintText: '거래에 대한 설명을 입력하세요',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
                borderSide: BorderSide(color: DesignSystem.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
                borderSide: BorderSide(color: DesignSystem.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
                borderSide: BorderSide(color: DesignSystem.primary, width: 2),
              ),
            ),
          ),

          const SizedBox(height: DesignSystem.spacing24),

          // 날짜 선택
          Text(
            '날짜',
            style: DesignSystem.body1.copyWith(
              color: DesignSystem.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DesignSystem.spacing12),
          _buildDateSelector(),

          const SizedBox(height: DesignSystem.spacing32),

          // 저장 버튼
          AppButton(
            text: '거래 추가',
            onPressed: () {
              // 거래 추가 로직 (추후 Firebase 연동)
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('거래가 추가되었습니다.'),
                  backgroundColor: DesignSystem.success,
                ),
              );
              // 데이터 새로고침
              _loadData();
            },
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  /// 거래 유형 선택 버튼
  Widget _buildTransactionTypeButton({
    required String type,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTransactionType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(DesignSystem.spacing16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
          border: Border.all(
            color: _selectedTransactionType == type
                ? color
                : color.withOpacity(0.3),
            width: _selectedTransactionType == type ? 3 : 2,
          ),
          color: _selectedTransactionType == type
              ? color.withOpacity(0.15)
              : color.withOpacity(0.05),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: DesignSystem.spacing8),
            Text(
              label,
              style: DesignSystem.body1.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 카테고리 선택기
  Widget _buildCategorySelector() {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.spacing16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
        border: Border.all(color: DesignSystem.divider),
      ),
      child: Row(
        children: [
          Icon(Icons.category, color: DesignSystem.textSecondary),
          const SizedBox(width: DesignSystem.spacing12),
          Expanded(
            child: Text(
              '카테고리 선택',
              style: DesignSystem.body1.copyWith(
                color: DesignSystem.textSecondary,
              ),
            ),
          ),
          Icon(Icons.arrow_drop_down, color: DesignSystem.textSecondary),
        ],
      ),
    );
  }

  /// 날짜 선택기
  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.spacing16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
        border: Border.all(color: DesignSystem.divider),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: DesignSystem.textSecondary),
          const SizedBox(width: DesignSystem.spacing12),
          Expanded(
            child: Text(
              '오늘',
              style: DesignSystem.body1.copyWith(
                color: DesignSystem.textPrimary,
              ),
            ),
          ),
          Icon(Icons.arrow_drop_down, color: DesignSystem.textSecondary),
        ],
      ),
    );
  }

  /// 모임 생성 화면으로 이동
  void _showCreateGroupScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateGroupScreen()),
    );
  }

  /// 모임 변경 화면으로 이동
  void _showGroupSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: DesignSystem.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(DesignSystem.radiusLarge),
          ),
        ),
        child: Column(
          children: [
            // 드래그 핸들
            Container(
              margin: const EdgeInsets.only(top: DesignSystem.spacing8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: DesignSystem.divider,
                borderRadius: BorderRadius.circular(
                  DesignSystem.radiusCircular,
                ),
              ),
            ),
            // 헤더
            Container(
              padding: const EdgeInsets.all(DesignSystem.spacing20),
              decoration: BoxDecoration(
                color: DesignSystem.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(DesignSystem.radiusLarge),
                ),
                boxShadow: DesignSystem.shadowSmall,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '모임 변경',
                    style: DesignSystem.headline3.copyWith(
                      color: DesignSystem.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // 모임 목록
            Expanded(
              child: Builder(
                builder: (context) {
                  final currentGroup = _appStateService.selectedGroup;
                  if (currentGroup != null) {
                    return ListView.builder(
                      padding: const EdgeInsets.all(DesignSystem.spacing20),
                      itemCount: 1, // 임시로 1개만 표시
                      itemBuilder: (context, index) {
                        return _buildGroupListItem(currentGroup);
                      },
                    );
                  } else {
                    return Center(
                      child: Text(
                        '참여하고 있는 모임이 없습니다.',
                        style: DesignSystem.body1.copyWith(
                          color: DesignSystem.textSecondary,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 모임 목록 아이템
  Widget _buildGroupListItem(Group group) {
    return Card(
      margin: const EdgeInsets.only(bottom: DesignSystem.spacing12),
      elevation: DesignSystem.shadowSmall[0].blurRadius,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spacing16),
        child: Row(
          children: [
            Icon(Icons.group, color: DesignSystem.textSecondary, size: 24),
            const SizedBox(width: DesignSystem.spacing12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    style: DesignSystem.body1.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (group.description != null &&
                      group.description!.isNotEmpty)
                    Text(
                      group.description!,
                      style: DesignSystem.caption.copyWith(
                        color: DesignSystem.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: DesignSystem.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

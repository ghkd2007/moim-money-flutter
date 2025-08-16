import 'package:flutter/material.dart';
import '../../../constants/design_system.dart';
import '../../../widgets/common/app_button.dart';
import '../../../models/models.dart';
import '../../../services/transaction_service.dart';

/// 지출/수입 추가 화면
/// 새로운 거래 내역을 추가하는 화면입니다.
class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  // 거래 타입 (지출/수입)
  String _transactionType = 'expense';

  // 입력 필드 컨트롤러
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // 선택된 값들
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();

  // 임시 카테고리 데이터 (추후 Firebase에서 가져올 예정)
  final Map<String, Category> _categories = {
    'cat1': const Category(
      id: 'cat1',
      groupId: '1',
      name: '스타벅스',
      color: Colors.brown,
      icon: '☕',
    ),
    'cat2': const Category(
      id: 'cat2',
      groupId: '1',
      name: '맛집',
      color: Colors.orange,
      icon: '🍽️',
    ),
    'cat3': const Category(
      id: 'cat3',
      groupId: '1',
      name: '회사',
      color: Colors.blue,
      icon: '🏢',
    ),
    'cat4': const Category(
      id: 'cat4',
      groupId: '1',
      name: 'CGV',
      color: Colors.purple,
      icon: '🎬',
    ),
    'cat5': const Category(
      id: 'cat5',
      groupId: '1',
      name: '교통비',
      color: Colors.green,
      icon: '🚌',
    ),
    'cat6': const Category(
      id: 'cat6',
      groupId: '1',
      name: '쇼핑',
      color: Colors.pink,
      icon: '🛍️',
    ),
  };

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        backgroundColor: DesignSystem.surface,
        elevation: 0,
        title: Text(
          '거래 내역 추가',
          style: DesignSystem.headline3.copyWith(
            color: DesignSystem.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: DesignSystem.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: DesignSystem.getScreenPadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: DesignSystem.spacing24),

              // 거래 타입 선택
              _buildTransactionTypeSelector(),

              const SizedBox(height: DesignSystem.spacing32),

              // 금액 입력
              _buildAmountInput(),

              const SizedBox(height: DesignSystem.spacing32),

              // 카테고리 선택
              _buildCategorySelector(),

              const SizedBox(height: DesignSystem.spacing32),

              // 날짜 선택
              _buildDateSelector(),

              const SizedBox(height: DesignSystem.spacing32),

              // 메모 입력
              _buildDescriptionInput(),

              const SizedBox(height: DesignSystem.spacing48),

              // 저장 버튼
              _buildSaveButton(),

              const SizedBox(height: DesignSystem.spacing24),
            ],
          ),
        ),
      ),
    );
  }

  /// 거래 타입 선택 (지출/수입)
  Widget _buildTransactionTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '거래 타입',
          style: DesignSystem.headline3.copyWith(
            color: DesignSystem.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: DesignSystem.spacing16),
        Row(
          children: [
            Expanded(
              child: _buildTypeOption(
                'expense',
                '지출',
                Icons.remove_circle_outline,
                DesignSystem.expense,
              ),
            ),
            const SizedBox(width: DesignSystem.spacing16),
            Expanded(
              child: _buildTypeOption(
                'income',
                '수입',
                Icons.add_circle_outline,
                DesignSystem.income,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 거래 타입 옵션
  Widget _buildTypeOption(
    String type,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _transactionType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _transactionType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(DesignSystem.spacing20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
          border: Border.all(
            color: isSelected ? color : DesignSystem.divider,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? color.withOpacity(0.1) : DesignSystem.surface,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : DesignSystem.textSecondary,
              size: 32,
            ),
            const SizedBox(height: DesignSystem.spacing12),
            Text(
              label,
              style: DesignSystem.body1.copyWith(
                color: isSelected ? color : DesignSystem.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 금액 입력
  Widget _buildAmountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '금액',
          style: DesignSystem.headline3.copyWith(
            color: DesignSystem.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: DesignSystem.spacing16),
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          style: DesignSystem.displayLarge.copyWith(
            color: _transactionType == 'expense'
                ? DesignSystem.expense
                : DesignSystem.income,
            fontWeight: FontWeight.w800,
          ),
          decoration: InputDecoration(
            hintText: '0',
            hintStyle: DesignSystem.displayLarge.copyWith(
              color: DesignSystem.textSecondary.withOpacity(0.3),
              fontWeight: FontWeight.w800,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
              borderSide: BorderSide(color: DesignSystem.divider, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
              borderSide: BorderSide(color: DesignSystem.divider, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
              borderSide: BorderSide(
                color: _transactionType == 'expense'
                    ? DesignSystem.expense
                    : DesignSystem.income,
                width: 3,
              ),
            ),
            suffixText: '원',
            suffixStyle: DesignSystem.headline3.copyWith(
              color: _transactionType == 'expense'
                  ? DesignSystem.expense
                  : DesignSystem.income,
              fontWeight: FontWeight.w600,
            ),
            filled: true,
            fillColor: DesignSystem.surface,
          ),
        ),
      ],
    );
  }

  /// 카테고리 선택
  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '카테고리',
          style: DesignSystem.headline3.copyWith(
            color: DesignSystem.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: DesignSystem.spacing16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: DesignSystem.spacing16,
            mainAxisSpacing: DesignSystem.spacing16,
            childAspectRatio: 1.2,
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories.values.elementAt(index);
            final isSelected = _selectedCategoryId == category.id;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategoryId = category.id;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
                  border: Border.all(
                    color: isSelected ? category.color : DesignSystem.divider,
                    width: isSelected ? 2 : 1,
                  ),
                  color: isSelected
                      ? category.color.withOpacity(0.1)
                      : DesignSystem.surface,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(category.icon, style: const TextStyle(fontSize: 32)),
                    const SizedBox(height: DesignSystem.spacing8),
                    Text(
                      category.name,
                      style: DesignSystem.body2.copyWith(
                        color: isSelected
                            ? category.color
                            : DesignSystem.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// 날짜 선택
  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '날짜',
          style: DesignSystem.headline3.copyWith(
            color: DesignSystem.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: DesignSystem.spacing16),
        GestureDetector(
          onTap: () => _selectDate(context),
          child: Container(
            padding: const EdgeInsets.all(DesignSystem.spacing20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
              border: Border.all(color: DesignSystem.divider, width: 2),
              color: DesignSystem.surface,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: DesignSystem.primary,
                  size: 24,
                ),
                const SizedBox(width: DesignSystem.spacing16),
                Text(
                  '${_selectedDate.year}년 ${_selectedDate.month}월 ${_selectedDate.day}일',
                  style: DesignSystem.body1.copyWith(
                    color: DesignSystem.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_drop_down,
                  color: DesignSystem.textSecondary,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 메모 입력
  Widget _buildDescriptionInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '메모 (선택사항)',
          style: DesignSystem.headline3.copyWith(
            color: DesignSystem.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: DesignSystem.spacing16),
        TextField(
          controller: _descriptionController,
          maxLines: 3,
          style: DesignSystem.body1.copyWith(color: DesignSystem.textPrimary),
          decoration: InputDecoration(
            hintText: '거래에 대한 메모를 입력하세요',
            hintStyle: DesignSystem.body1.copyWith(
              color: DesignSystem.textSecondary.withOpacity(0.5),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
              borderSide: BorderSide(color: DesignSystem.divider, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
              borderSide: BorderSide(color: DesignSystem.divider, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
              borderSide: BorderSide(color: DesignSystem.primary, width: 3),
            ),
            filled: true,
            fillColor: DesignSystem.surface,
          ),
        ),
      ],
    );
  }

  /// 저장 버튼
  Widget _buildSaveButton() {
    final isValid =
        _amountController.text.isNotEmpty && _selectedCategoryId != null;

    return AppButton(
      text: '저장하기',
      onPressed: isValid ? _saveTransaction : null,
      isFullWidth: true,
      type: AppButtonType.primary,
    );
  }

  /// 날짜 선택 다이얼로그
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: DesignSystem.primary,
              onPrimary: Colors.white,
              surface: DesignSystem.surface,
              onSurface: DesignSystem.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// 거래 내역 저장
  Future<void> _saveTransaction() async {
    final amount = int.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showErrorSnackBar('올바른 금액을 입력해주세요.');
      return;
    }

    if (_selectedCategoryId == null) {
      _showErrorSnackBar('카테고리를 선택해주세요.');
      return;
    }

    // 실제 금액 (지출은 음수, 수입은 양수)
    final actualAmount = _transactionType == 'expense' ? -amount : amount;

    // Firebase에 거래 내역 저장
    final transaction = Transaction(
      id: '', // Firestore에서 자동 생성
      groupId: '1', // 현재 그룹 ID (추후 동적으로 변경)
      userId: 'user1', // 현재 사용자 ID (추후 동적으로 변경)
      type: _transactionType,
      amount: actualAmount,
      categoryId: _selectedCategoryId!,
      description: _descriptionController.text.trim(),
      date: _selectedDate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      final transactionService = TransactionService();
      final transactionId = await transactionService.addTransaction(
        transaction,
      );

      if (transactionId != null) {
        // 성공 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_transactionType == 'expense' ? '지출' : '수입'}이 추가되었습니다.',
            ),
            backgroundColor: DesignSystem.success,
          ),
        );

        // 이전 화면으로 돌아가기
        Navigator.pop(context);
      } else {
        _showErrorSnackBar('저장에 실패했습니다. 다시 시도해주세요.');
      }
    } catch (e) {
      _showErrorSnackBar('오류가 발생했습니다: $e');
    }
  }

  /// 에러 메시지 표시
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: DesignSystem.error),
    );
  }
}

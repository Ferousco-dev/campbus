import 'package:flutter/material.dart';
import '../models/wallet_models.dart';
import '../theme/app_theme.dart';
import '../widgets/wallet/wallet_balance_hero.dart';
import '../widgets/wallet/wallet_summary_cards.dart';
import '../widgets/wallet/spending_chart_card.dart';
import '../widgets/wallet/wallet_transaction_item.dart';
import '../widgets/wallet/receipt_bottom_sheet.dart';
import 'notifications_screen.dart';
import 'transactions_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  // Filter state
  TxCategory? _selectedCategory;
  final ScrollController _scrollController = ScrollController();
  bool _showElevatedAppBar = false;

  // Computed from sample data
  double get _balance => 12350.00;
  double get _monthlyIncome => 17000.00;
  double get _monthlySpent => 9500.00;

  List<WalletTransaction> get _filteredTransactions {
    if (_selectedCategory == null) return walletTransactions;
    return walletTransactions
        .where((tx) => tx.category == _selectedCategory)
        .toList();
  }

  int get _totalTransactions => walletTransactions.length;

  double get _avgTransaction {
    final debits =
        walletTransactions.where((tx) => tx.type == WalletTxType.debit);
    if (debits.isEmpty) return 0;
    return debits.fold(0.0, (sum, tx) => sum + tx.amount) / debits.length;
  }

  double get _biggestSpend {
    final debits =
        walletTransactions.where((tx) => tx.type == WalletTxType.debit);
    if (debits.isEmpty) return 0;
    return debits.fold(0.0, (max, tx) => tx.amount > max ? tx.amount : max);
  }

  String get _topCategory {
    final categoryCount = <TxCategory, int>{};
    for (final tx in walletTransactions) {
      categoryCount[tx.category] = (categoryCount[tx.category] ?? 0) + 1;
    }
    if (categoryCount.isEmpty) return 'None';
    final sorted = categoryCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key.name[0].toUpperCase() +
        sorted.first.key.name.substring(1);
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final showElevation = _scrollController.offset > 10;
    if (showElevation != _showElevatedAppBar) {
      setState(() => _showElevatedAppBar = showElevation);
    }
  }

  void _onGenerateReceipt(WalletTransaction transaction) {
    ReceiptBottomSheet.show(context, transaction);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── App Bar ────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            floating: false,
            backgroundColor: _showElevatedAppBar
                ? AppColors.surface
                : AppColors.background,
            elevation: 0,
            scrolledUnderElevation: 0,
            toolbarHeight: 64,
            title: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _showElevatedAppBar ? 1.0 : 0.0,
              child: const Text(
                'My Wallet',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            leading: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Center(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationsScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
            bottom: _showElevatedAppBar
                ? PreferredSize(
                    preferredSize: const Size.fromHeight(1),
                    child: Container(
                      height: 1,
                      color: AppColors.border,
                    ),
                  )
                : null,
          ),

          // ─── Page Header ────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'My Wallet',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage your campus finances',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Balance Hero ───────────────────────────────────
          SliverToBoxAdapter(
            child: WalletBalanceHero(
              balance: _balance,
              monthlyIncome: _monthlyIncome,
              monthlySpent: _monthlySpent,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ─── Quick Insights ─────────────────────────────────
          SliverToBoxAdapter(
            child: WalletSummaryCards(
              totalTransactions: _totalTransactions,
              avgTransaction: _avgTransaction,
              biggestSpend: _biggestSpend,
              topCategory: _topCategory,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ─── Spending Chart ─────────────────────────────────
          SliverToBoxAdapter(
            child: SpendingChartCard(
              weeklyData: weeklySpending,
              monthlyData: monthlySpending,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ─── Transaction Header + Filter ────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Transactions',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TransactionsScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'See All',
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Category filter chips
                  SizedBox(
                    height: 36,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _FilterChip(
                          label: 'All',
                          isSelected: _selectedCategory == null,
                          onTap: () =>
                              setState(() => _selectedCategory = null),
                        ),
                        ...TxCategory.values.map((cat) {
                          final label = cat.name[0].toUpperCase() +
                              cat.name.substring(1);
                          return Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: _FilterChip(
                              label: label,
                              isSelected: _selectedCategory == cat,
                              onTap: () =>
                                  setState(() => _selectedCategory = cat),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // ─── Transactions List ──────────────────────────────
          _filteredTransactions.isEmpty
              ? SliverToBoxAdapter(
                  child: _EmptyTransactions(
                    category: _selectedCategory,
                    onReset: () =>
                        setState(() => _selectedCategory = null),
                  ),
                )
              : SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.textPrimary.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Column(
                        children: List.generate(
                          _filteredTransactions.length,
                          (index) {
                            final tx = _filteredTransactions[index];
                            return WalletTransactionItem(
                              transaction: tx,
                              showDivider:
                                  index < _filteredTransactions.length - 1,
                              onGenerateReceipt: tx.hasReceipt
                                  ? () => _onGenerateReceipt(tx)
                                  : null,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),

          // Bottom padding
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).padding.bottom + 100,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Filter Chip ──────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────
class _EmptyTransactions extends StatelessWidget {
  final TxCategory? category;
  final VoidCallback onReset;

  const _EmptyTransactions({
    required this.category,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 30,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No transactions found',
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            category != null
                ? 'No ${category!.name} transactions yet'
                : 'Your transaction history will appear here',
            style: const TextStyle(
              fontFamily: 'Sora',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (category != null) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: onReset,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Show All Transactions',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

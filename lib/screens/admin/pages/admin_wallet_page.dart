import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/wallet_models.dart';
import '../../../services/admin/admin_service.dart';
import '../../../theme/app_theme.dart';

class AdminWalletPage extends StatefulWidget {
  const AdminWalletPage({super.key});
  @override
  State<AdminWalletPage> createState() => _AdminWalletPageState();
}

class _AdminWalletPageState extends State<AdminWalletPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  List<WalletTransaction> _transactions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  Future<void> _load() async {
    final txs = await AdminService.fetchAllTransactions();
    if (mounted) setState(() { _transactions = txs; _loading = false; });
  }

  List<WalletTransaction> get _topups => _transactions.where((t) => t.category == TxCategory.topup).toList();
  List<WalletTransaction> get _refunds => _transactions.where((t) => t.category == TxCategory.refund).toList();

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Column(
      children: [
        // Top summary cards
        Container(
          padding: const EdgeInsets.all(20),
          color: Colors.white,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;
              final cards = [
                _summaryCard('Total Top-ups', '₦${(_topups.fold<double>(0, (s, t) => s + t.amount) / 1000).toStringAsFixed(1)}K', const Color(0xFF00B37E), Icons.add_circle_rounded, isMobile),
                if (isMobile) const SizedBox(height: 12) else const SizedBox(width: 12),
                _summaryCard('Total Refunds', '₦${(_refunds.fold<double>(0, (s, t) => s + t.amount)).toStringAsFixed(0)}', const Color(0xFF00A3CC), Icons.replay_rounded, isMobile),
                if (isMobile) const SizedBox(height: 12) else const SizedBox(width: 12),
                _summaryCard('Net Flow', '₦${(_transactions.where((t) => t.isCredit).fold<double>(0, (s, t) => s + t.amount) - _transactions.where((t) => !t.isCredit).fold<double>(0, (s, t) => s + t.amount)).toStringAsFixed(0)}', AppColors.primary, Icons.swap_vert_rounded, isMobile),
              ];
              
              if (isMobile) {
                return Column(children: cards);
              } else {
                return Row(children: cards);
              }
            }
          ),
        ),
        Container(height: 1, color: AppColors.border),
        // Tabs
        TabBar(
          controller: _tab,
          isScrollable: false,
          labelStyle: const TextStyle(fontFamily: 'Sora', fontSize: 12, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Sora', fontSize: 12),
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [Tab(text: 'Top-ups'), Tab(text: 'Transfers'), Tab(text: 'Refunds')],
        ),
        Container(height: 1, color: AppColors.border),
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: [
              _buildTxList(_topups, 'No top-up records'),
              _buildTxList([], 'No transfer records'),
              _buildRefundList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryCard(String label, String value, Color color, IconData icon, bool isMobile) {
    final content = Container(
      width: isMobile ? double.infinity : null,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontFamily: 'Sora', fontSize: 18, fontWeight: FontWeight.w700, color: color)),
          Text(label, style: const TextStyle(fontFamily: 'Sora', fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
    
    if (isMobile) return content;
    return Expanded(child: content);
  }

  Widget _buildTxList(List<WalletTransaction> txs, String emptyMsg) {
    if (txs.isEmpty) {
      return Center(child: Text(emptyMsg, style: const TextStyle(fontFamily: 'Sora', fontSize: 14, color: AppColors.textMuted)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(0),
      itemCount: txs.length,
      itemBuilder: (_, i) {
        final tx = txs[i];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: AppColors.border))),
          child: Row(
            children: [
              Container(width: 38, height: 38, decoration: BoxDecoration(color: tx.categoryBgColor, borderRadius: BorderRadius.circular(10)), child: Icon(tx.categoryIcon, color: tx.categoryColor, size: 18)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(tx.title, style: const TextStyle(fontFamily: 'Sora', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                Text(tx.subtitle, style: const TextStyle(fontFamily: 'Sora', fontSize: 11, color: AppColors.textSecondary)),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('${tx.isCredit ? '+' : '-'}₦${tx.amount.toStringAsFixed(0)}', style: TextStyle(fontFamily: 'Sora', fontSize: 13, fontWeight: FontWeight.w700, color: tx.isCredit ? const Color(0xFF00B37E) : AppColors.textPrimary)),
                Text('${tx.date.day}/${tx.date.month}', style: const TextStyle(fontFamily: 'Sora', fontSize: 10, color: AppColors.textMuted)),
              ]),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRefundList() {
    return ListView.builder(
      itemCount: _refunds.length,
      itemBuilder: (_, i) {
        final tx = _refunds[i];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: AppColors.border))),
          child: Row(
            children: [
              Container(width: 38, height: 38, decoration: BoxDecoration(color: tx.categoryBgColor, borderRadius: BorderRadius.circular(10)), child: Icon(tx.categoryIcon, color: tx.categoryColor, size: 18)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(tx.title, style: const TextStyle(fontFamily: 'Sora', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                Text(tx.reference ?? '', style: const TextStyle(fontFamily: 'Sora', fontSize: 11, color: AppColors.textMuted)),
              ])),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text('Refund approved ✓', style: TextStyle(fontFamily: 'Sora')),
                    backgroundColor: const Color(0xFF00B37E),
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    duration: const Duration(seconds: 2),
                  ));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFFE6FAF4), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF00B37E).withValues(alpha: 0.3))),
                  child: const Text('Approve', style: TextStyle(fontFamily: 'Sora', fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF00B37E))),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

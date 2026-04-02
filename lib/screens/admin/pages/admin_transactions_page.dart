import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/wallet_models.dart';
import '../../../services/admin/admin_service.dart';
import '../../../theme/app_theme.dart';
import '../widgets/admin_section_header.dart';

class AdminTransactionsPage extends StatefulWidget {
  const AdminTransactionsPage({super.key});
  @override
  State<AdminTransactionsPage> createState() => _AdminTransactionsPageState();
}

class _AdminTransactionsPageState extends State<AdminTransactionsPage> {
  List<WalletTransaction> _all = [];
  List<WalletTransaction> _filtered = [];
  bool _loading = true;
  final _search = TextEditingController();
  WalletTxType? _typeFilter;
  TxCategory? _catFilter;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final txs = await AdminService.fetchAllTransactions();
    if (mounted) setState(() { _all = txs; _filtered = txs; _loading = false; });
  }

  void _applyFilter() {
    setState(() {
      _filtered = _all.where((t) {
        final q = _search.text.toLowerCase();
        final matchSearch = q.isEmpty || t.title.toLowerCase().contains(q) || (t.reference?.toLowerCase().contains(q) ?? false);
        final matchType = _typeFilter == null || t.type == _typeFilter;
        final matchCat = _catFilter == null || t.category == _catFilter;
        return matchSearch && matchType && matchCat;
      }).toList();
    });
  }

  double get _totalCredit => _filtered.where((t) => t.isCredit).fold(0, (s, t) => s + t.amount);
  double get _totalDebit => _filtered.where((t) => !t.isCredit).fold(0, (s, t) => s + t.amount);

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Column(
      children: [
        // Top bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          color: Colors.white,
          child: Column(
            children: [
              Row(children: [
                Expanded(child: AdminSearchBar(controller: _search, hint: 'Search by title or reference…', onChanged: (_) => _applyFilter())),
                const SizedBox(width: 12),
                AdminActionButton(label: 'Export CSV', icon: Icons.download_rounded, onTap: () {
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('CSV exported ✓', style: TextStyle(fontFamily: 'Sora')),
                    backgroundColor: Color(0xFF00B37E),
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.fromLTRB(20, 0, 20, 16),
                  ));
                }),
              ]),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  _chip('All', _typeFilter == null && _catFilter == null, () { _typeFilter = null; _catFilter = null; _applyFilter(); }),
                  const SizedBox(width: 6),
                  _chip('Credits', _typeFilter == WalletTxType.credit, () { _typeFilter = WalletTxType.credit; _applyFilter(); }),
                  const SizedBox(width: 6),
                  _chip('Debits', _typeFilter == WalletTxType.debit, () { _typeFilter = WalletTxType.debit; _applyFilter(); }),
                  const SizedBox(width: 6),
                  _chip('WiFi', _catFilter == TxCategory.wifi, () { _catFilter = TxCategory.wifi; _applyFilter(); }),
                  const SizedBox(width: 6),
                  _chip('Transport', _catFilter == TxCategory.transport, () { _catFilter = TxCategory.transport; _applyFilter(); }),
                  const SizedBox(width: 6),
                  _chip('Refunds', _catFilter == TxCategory.refund, () { _catFilter = TxCategory.refund; _applyFilter(); }),
                ]),
              ),
            ],
          ),
        ),
        // Summary
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          color: AppColors.background,
          child: Row(children: [
            Text('${_filtered.length} records', style: const TextStyle(fontFamily: 'Sora', fontSize: 13, color: AppColors.textSecondary)),
            const Spacer(),
            Text('+₦${_totalCredit.toStringAsFixed(0)} credit', style: const TextStyle(fontFamily: 'Sora', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF00B37E))),
            const SizedBox(width: 16),
            Text('-₦${_totalDebit.toStringAsFixed(0)} debit', style: const TextStyle(fontFamily: 'Sora', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFE03E3E))),
          ]),
        ),
        Container(height: 1, color: AppColors.border),
        // No table header needed, we use rich list items
        Expanded(
          child: _filtered.isEmpty
              ? const Center(child: Text('No transactions match your filter.', style: TextStyle(fontFamily: 'Sora', color: AppColors.textMuted)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: _filtered.length,
                  itemBuilder: (_, i) => _buildRow(_filtered[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildRow(WalletTransaction tx) {
    final receiptColor = tx.receiptStatus == ReceiptStatus.available ? const Color(0xFF00B37E) : tx.receiptStatus == ReceiptStatus.pending ? const Color(0xFFE08C00) : const Color(0xFF6B7A99);
    final receiptLabel = tx.receiptStatus == ReceiptStatus.available ? 'Available' : tx.receiptStatus == ReceiptStatus.pending ? 'Pending' : 'N/A';
    
    IconData getIcon() {
      if (tx.category == TxCategory.wifi) return Icons.wifi_rounded;
      if (tx.category == TxCategory.transport) return Icons.directions_bus_rounded;
      if (tx.category == TxCategory.refund) return Icons.replay_rounded;
      return tx.isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: tx.isCredit ? const Color(0xFF00B37E).withValues(alpha: 0.1) : const Color(0xFFE03E3E).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14)
            ),
            child: Icon(getIcon(), color: tx.isCredit ? const Color(0xFF00B37E) : const Color(0xFFE03E3E), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(tx.title, style: const TextStyle(fontFamily: 'Sora', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 12),
                    Text(
                      '${tx.isCredit ? '+' : '-'}₦${tx.amount.toStringAsFixed(0)}',
                      style: TextStyle(fontFamily: 'Sora', fontSize: 16, fontWeight: FontWeight.w700, color: tx.isCredit ? const Color(0xFF00B37E) : AppColors.textPrimary),
                    ),
                  ]
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    AdminStatusChip(label: tx.categoryLabel, color: tx.categoryColor),
                    if (tx.receiptStatus == ReceiptStatus.available)
                      AdminStatusChip(label: 'Receipt', color: receiptColor),
                    Text(tx.subtitle, style: const TextStyle(fontFamily: 'Sora', fontSize: 12, color: AppColors.textSecondary)),
                    Text('· ${tx.date.day.toString().padLeft(2, '0')}/${tx.date.month.toString().padLeft(2, '0')}/${tx.date.year}', style: const TextStyle(fontFamily: 'Sora', fontSize: 12, color: AppColors.textSecondary)),
                  ]
                ),
              ],
            ),
          ),
        ]
      )
    );
  }

  Widget _chip(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: () { setState(onTap); },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: active ? AppColors.primary : AppColors.border),
        ),
        child: Text(label, style: TextStyle(fontFamily: 'Sora', fontSize: 13, fontWeight: FontWeight.w600, color: active ? Colors.white : AppColors.textSecondary)),
      ),
    );
  }
}

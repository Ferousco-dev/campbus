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
          padding: const EdgeInsets.all(16),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: AppColors.background,
          child: Row(children: [
            Text('${_filtered.length} records', style: const TextStyle(fontFamily: 'Sora', fontSize: 12, color: AppColors.textSecondary)),
            const Spacer(),
            Text('+₦${_totalCredit.toStringAsFixed(0)} credit', style: const TextStyle(fontFamily: 'Sora', fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF00B37E))),
            const SizedBox(width: 12),
            Text('-₦${_totalDebit.toStringAsFixed(0)} debit', style: const TextStyle(fontFamily: 'Sora', fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFE03E3E))),
          ]),
        ),
        Container(height: 1, color: AppColors.border),
        // Table header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          color: AppColors.background,
          child: Row(children: const [
            Expanded(flex: 3, child: Text('TITLE', style: TextStyle(fontFamily: 'Sora', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.8))),
            Expanded(child: Text('TYPE', style: TextStyle(fontFamily: 'Sora', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.8))),
            Expanded(child: Text('AMOUNT', style: TextStyle(fontFamily: 'Sora', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.8))),
            Expanded(child: Text('DATE', style: TextStyle(fontFamily: 'Sora', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.8))),
            Expanded(child: Text('RECEIPT', style: TextStyle(fontFamily: 'Sora', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.8))),
          ]),
        ),
        Container(height: 1, color: AppColors.border),
        Expanded(
          child: _filtered.isEmpty
              ? const Center(child: Text('No transactions match your filter.', style: TextStyle(fontFamily: 'Sora', color: AppColors.textMuted)))
              : ListView.builder(
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(
        children: [
          Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tx.title, style: const TextStyle(fontFamily: 'Sora', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(tx.subtitle, style: const TextStyle(fontFamily: 'Sora', fontSize: 10, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
          Expanded(child: AdminStatusChip(label: tx.categoryLabel, color: tx.categoryColor)),
          Expanded(child: Text(
            '${tx.isCredit ? '+' : '-'}₦${tx.amount.toStringAsFixed(0)}',
            style: TextStyle(fontFamily: 'Sora', fontSize: 12, fontWeight: FontWeight.w600, color: tx.isCredit ? const Color(0xFF00B37E) : const Color(0xFFE03E3E)),
          )),
          Expanded(child: Text('${tx.date.day}/${tx.date.month}/${tx.date.year}', style: const TextStyle(fontFamily: 'Sora', fontSize: 11, color: AppColors.textSecondary))),
          Expanded(child: AdminStatusChip(label: receiptLabel, color: receiptColor)),
        ],
      ),
    );
  }

  Widget _chip(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: () { setState(onTap); },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: active ? AppColors.primary : AppColors.border),
        ),
        child: Text(label, style: TextStyle(fontFamily: 'Sora', fontSize: 11, fontWeight: FontWeight.w600, color: active ? Colors.white : AppColors.textSecondary)),
      ),
    );
  }
}

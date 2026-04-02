import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/admin/admin_models.dart';
import '../../../services/admin/admin_service.dart';
import '../../../theme/app_theme.dart';
import '../widgets/admin_section_header.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});
  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  bool _loading = true;
  List<AdminUser> _users = [];
  List<AdminUser> _filtered = [];
  final _search = TextEditingController();
  AdminCardStatus? _filterCard;
  AdminUserTier? _filterTier;
  AdminUser? _selected;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final users = await AdminService.fetchUsers();
    if (mounted) setState(() { _users = users; _filtered = users; _loading = false; });
  }

  void _applyFilter() {
    setState(() {
      _filtered = _users.where((u) {
        final q = _search.text.toLowerCase();
        final matchSearch = q.isEmpty ||
            u.fullName.toLowerCase().contains(q) ||
            u.studentId.toLowerCase().contains(q) ||
            u.email.toLowerCase().contains(q);
        final matchCard = _filterCard == null || u.cardStatus == _filterCard;
        final matchTier = _filterTier == null || u.tier == _filterTier;
        return matchSearch && matchCard && matchTier;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Row(
      children: [
        // List panel
        Expanded(
          flex: _selected != null ? 5 : 1,
          child: _buildList(),
        ),
        // Detail panel
        if (_selected != null) ...[
          Container(width: 1, color: AppColors.border),
          Expanded(flex: 4, child: _buildDetail(_selected!)),
        ],
      ],
    );
  }

  Widget _buildList() {
    return Column(
      children: [
        // Search + filters
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            children: [
              AdminSearchBar(
                controller: _search,
                hint: 'Search by name, ID or email…',
                onChanged: (_) => _applyFilter(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _filterChip('All Cards', _filterCard == null, () { _filterCard = null; _applyFilter(); }),
                  const SizedBox(width: 8),
                  _filterChip('Active', _filterCard == AdminCardStatus.active, () { _filterCard = AdminCardStatus.active; _applyFilter(); }),
                  const SizedBox(width: 8),
                  _filterChip('Inactive', _filterCard == AdminCardStatus.inactive, () { _filterCard = AdminCardStatus.inactive; _applyFilter(); }),
                  const SizedBox(width: 8),
                  _filterChip('Blocked', _filterCard == AdminCardStatus.blocked, () { _filterCard = AdminCardStatus.blocked; _applyFilter(); }),
                ],
              ),
            ],
          ),
        ),
        Container(height: 1, color: AppColors.border),
        // Stats row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: AppColors.background,
          child: Row(
            children: [
              Text('${_filtered.length} users', style: const TextStyle(fontFamily: 'Sora', fontSize: 12, color: AppColors.textSecondary)),
              const Spacer(),
              Text('${_users.where((u) => u.cardStatus == AdminCardStatus.active).length} active cards',
                  style: const TextStyle(fontFamily: 'Sora', fontSize: 12, color: Color(0xFF00B37E), fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        // User list
        Expanded(
          child: ListView.builder(
            itemCount: _filtered.length,
            itemBuilder: (_, i) => _buildUserTile(_filtered[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildUserTile(AdminUser user) {
    final isSelected = _selected?.id == user.id;
    return InkWell(
      onTap: () { HapticFeedback.selectionClick(); setState(() => _selected = user); },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: isSelected ? AppColors.primarySurface : Colors.white,
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: isSelected ? AppColors.primary : AppColors.primarySurface,
              child: Text(
                user.fullName.substring(0, 1),
                style: TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : AppColors.primary),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.fullName, style: const TextStyle(fontFamily: 'Sora', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('${user.studentId} · ${user.tierLabel}', style: const TextStyle(fontFamily: 'Sora', fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ),
            AdminStatusChip(label: user.cardStatusLabel, color: user.cardStatusColor),
          ],
        ),
      ),
    );
  }

  Widget _buildDetail(AdminUser user) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              const Text('User Detail', style: TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const Spacer(),
              GestureDetector(onTap: () => setState(() => _selected = null), child: const Icon(Icons.close_rounded, size: 20, color: AppColors.textSecondary)),
            ],
          ),
        ),
        Container(height: 1, color: AppColors.border),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar card
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: AppColors.primary,
                        child: Text(user.fullName.substring(0, 1), style: const TextStyle(fontFamily: 'Sora', fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                      const SizedBox(height: 10),
                      Text(user.fullName, style: const TextStyle(fontFamily: 'Sora', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      Text(user.studentId, style: const TextStyle(fontFamily: 'Sora', fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AdminStatusChip(label: user.tierLabel, color: user.tierColor),
                          const SizedBox(width: 8),
                          AdminStatusChip(label: user.cardStatusLabel, color: user.cardStatusColor),
                          if (user.isVerified) ...[
                            const SizedBox(width: 8),
                            const AdminStatusChip(label: 'Verified', color: Color(0xFF00B37E)),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Wallet
                _infoCard('Wallet Balance', '₦${user.walletBalance.toStringAsFixed(0)}', Icons.account_balance_wallet_rounded, AppColors.primary),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _infoCard('Total Spent', '₦${(user.totalSpent / 1000).toStringAsFixed(1)}K', Icons.payments_rounded, const Color(0xFF9B5CF6))),
                  const SizedBox(width: 12),
                  Expanded(child: _infoCard('Transactions', '${user.totalTransactions}', Icons.receipt_long_rounded, const Color(0xFF00B37E))),
                ]),
                const SizedBox(height: 24),

                // Info
                _detailRow('Email', user.email),
                _detailRow('Phone', user.phone),
                _detailRow('Faculty', user.faculty),
                _detailRow('Department', user.department),
                _detailRow('Level', user.level),
                _detailRow('Joined', '${user.joinDate.day}/${user.joinDate.month}/${user.joinDate.year}'),
                const SizedBox(height: 24),

                // Actions
                const AdminSectionHeader(title: 'Actions'),
                const SizedBox(height: 12),
                _actionRow(
                  label: user.cardStatus == AdminCardStatus.blocked ? 'Unblock Card' : 'Block Card',
                  icon: user.cardStatus == AdminCardStatus.blocked ? Icons.lock_open_rounded : Icons.block_rounded,
                  color: user.cardStatus == AdminCardStatus.blocked ? const Color(0xFF00B37E) : const Color(0xFFE03E3E),
                ),
                const SizedBox(height: 8),
                _actionRow(label: 'Upgrade Tier', icon: Icons.upgrade_rounded, color: AppColors.primary),
                const SizedBox(height: 8),
                _actionRow(label: 'Issue Refund', icon: Icons.replay_rounded, color: const Color(0xFF00A3CC)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontFamily: 'Sora', fontSize: 10, color: AppColors.textSecondary)),
              Text(value, style: TextStyle(fontFamily: 'Sora', fontSize: 15, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 90, child: Text(label, style: const TextStyle(fontFamily: 'Sora', fontSize: 12, color: AppColors.textSecondary))),
          Expanded(child: Text(value, style: const TextStyle(fontFamily: 'Sora', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
        ],
      ),
    );
  }

  Widget _actionRow({required String label, required IconData icon, required Color color}) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('$label — feature stub', style: const TextStyle(fontFamily: 'Sora', fontSize: 13)),
          backgroundColor: AppColors.textPrimary,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ));
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(fontFamily: 'Sora', fontSize: 13, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: () { setState(onTap); _applyFilter(); },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: active ? AppColors.primary : AppColors.border),
        ),
        child: Text(label, style: TextStyle(fontFamily: 'Sora', fontSize: 11, fontWeight: FontWeight.w600, color: active ? Colors.white : AppColors.textSecondary)),
      ),
    );
  }
}

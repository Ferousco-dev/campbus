import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/admin/admin_models.dart';
import '../../../services/admin/admin_service.dart';
import '../../../theme/app_theme.dart';
import '../widgets/admin_section_header.dart';

class AdminAuditPage extends StatefulWidget {
  const AdminAuditPage({super.key});
  @override
  State<AdminAuditPage> createState() => _AdminAuditPageState();
}

class _AdminAuditPageState extends State<AdminAuditPage> {
  List<AuditLogEntry> _log = [];
  bool _loading = true;
  final _search = TextEditingController();
  List<AuditLogEntry> _filtered = [];
  String? _moduleFilter;

  final _modules = ['All', 'Shop', 'Users', 'Transport', 'Wallet', 'Notifications', 'Support'];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final log = await AdminService.fetchAuditLog();
    if (mounted) setState(() { _log = log; _filtered = log; _loading = false; });
  }

  void _applyFilter() {
    setState(() {
      _filtered = _log.where((entry) {
        final q = _search.text.toLowerCase();
        final matchSearch = q.isEmpty || entry.action.toLowerCase().contains(q) || entry.target.toLowerCase().contains(q) || entry.adminName.toLowerCase().contains(q);
        final matchModule = _moduleFilter == null || _moduleFilter == 'All' || entry.module == _moduleFilter;
        return matchSearch && matchModule;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Column(
      children: [
        // Toolbar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.white,
          child: Row(children: [
            Expanded(child: AdminSearchBar(controller: _search, hint: 'Search actions, targets, admins…', onChanged: (_) => _applyFilter())),
          ]),
        ),
        // Module filter
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          color: AppColors.background,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _modules.map((m) {
                final active = (_moduleFilter ?? 'All') == m;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () { setState(() => _moduleFilter = m == 'All' ? null : m); _applyFilter(); },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: active ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: active ? AppColors.primary : AppColors.border),
                      ),
                      child: Text(m, style: TextStyle(fontFamily: 'Sora', fontSize: 11, fontWeight: FontWeight.w600, color: active ? Colors.white : AppColors.textSecondary)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Container(height: 1, color: AppColors.border),
        // No table header needed, we use rich list items
        Expanded(
          child: _filtered.isEmpty
              ? const Center(child: Text('No audit entries match.', style: TextStyle(fontFamily: 'Sora', color: AppColors.textMuted)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: _filtered.length,
                  itemBuilder: (_, i) => _buildLogTile(_filtered[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildLogTile(AuditLogEntry entry) {
    final moduleColors = {
      'Shop': const Color(0xFF9B5CF6),
      'Users': AppColors.primary,
      'Transport': const Color(0xFFE08C00),
      'Wallet': const Color(0xFF00B37E),
      'Notifications': const Color(0xFF00A3CC),
      'Support': const Color(0xFFE03E3E),
    };
    final moduleColor = moduleColors[entry.module] ?? AppColors.textSecondary;

    return GestureDetector(
      onTap: () { HapticFeedback.selectionClick(); _showLogDetails(entry, moduleColor); },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            CircleAvatar(radius: 22, backgroundColor: AppColors.primarySurface, child: Text(entry.adminName.substring(0, 1), style: const TextStyle(fontFamily: 'Sora', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary))),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(entry.action, style: const TextStyle(fontFamily: 'Sora', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: moduleColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                        child: Text(entry.module, style: TextStyle(fontFamily: 'Sora', fontSize: 10, fontWeight: FontWeight.w700, color: moduleColor), maxLines: 1),
                      )
                    ]
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(child: Text(entry.target, style: const TextStyle(fontFamily: 'Sora', fontSize: 13, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 12),
                      Text('by ${entry.adminName}', style: const TextStyle(fontFamily: 'Sora', fontSize: 12, color: AppColors.textMuted, fontStyle: FontStyle.italic)),
                    ]
                  )
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 Text('${entry.timestamp.hour}:${entry.timestamp.minute.toString().padLeft(2, '0')}', style: const TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                 const SizedBox(height: 4),
                 Text(entry.ipAddress, style: const TextStyle(fontFamily: 'Sora', fontSize: 11, color: AppColors.textMuted)),
              ]
            )
          ],
        ),
      ),
    );
  }

  void _showLogDetails(AuditLogEntry entry, Color moduleColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: moduleColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                  child: Text(entry.module, style: TextStyle(fontFamily: 'Sora', fontSize: 10, fontWeight: FontWeight.w700, color: moduleColor), maxLines: 1),
                ),
                const Spacer(),
                Text('${entry.timestamp.day.toString().padLeft(2, '0')}/${entry.timestamp.month.toString().padLeft(2, '0')}/${entry.timestamp.year} — ${entry.timestamp.hour}:${entry.timestamp.minute.toString().padLeft(2, '0')}', style: const TextStyle(fontFamily: 'Sora', fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 20),
            Text(entry.action, style: const TextStyle(fontFamily: 'Sora', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text(entry.target, style: const TextStyle(fontFamily: 'Sora', fontSize: 14, color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            Container(height: 1, color: AppColors.border),
            const SizedBox(height: 20),
            _detailRow('Log ID', entry.id),
            _detailRow('Admin Name', entry.adminName),
            _detailRow('IP Address', entry.ipAddress),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton(
                onPressed: () => Navigator.pop(ctx),
                style: TextButton.styleFrom(backgroundColor: AppColors.background, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: const Text('Close', style: TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(fontFamily: 'Sora', fontSize: 13, color: AppColors.textSecondary))),
          Expanded(child: Text(value, style: const TextStyle(fontFamily: 'Sora', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
        ],
      ),
    );
  }
}

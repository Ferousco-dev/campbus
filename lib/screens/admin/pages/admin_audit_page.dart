import 'package:flutter/material.dart';
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
        // Table header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          color: AppColors.background,
          child: const Row(children: [
            Expanded(flex: 2, child: Text('ADMIN', style: TextStyle(fontFamily: 'Sora', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.8))),
            Expanded(flex: 3, child: Text('ACTION', style: TextStyle(fontFamily: 'Sora', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.8))),
            Expanded(flex: 3, child: Text('TARGET', style: TextStyle(fontFamily: 'Sora', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.8))),
            Expanded(child: Text('MODULE', style: TextStyle(fontFamily: 'Sora', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.8))),
            Expanded(flex: 2, child: Text('TIMESTAMP', style: TextStyle(fontFamily: 'Sora', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.8))),
          ]),
        ),
        Container(height: 1, color: AppColors.border),
        Expanded(
          child: _filtered.isEmpty
              ? const Center(child: Text('No audit entries match.', style: TextStyle(fontFamily: 'Sora', color: AppColors.textMuted)))
              : ListView.builder(
                  itemCount: _filtered.length,
                  itemBuilder: (_, i) => _buildRow(_filtered[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildRow(AuditLogEntry entry) {
    final moduleColors = {
      'Shop': const Color(0xFF9B5CF6),
      'Users': AppColors.primary,
      'Transport': const Color(0xFFE08C00),
      'Wallet': const Color(0xFF00B37E),
      'Notifications': const Color(0xFF00A3CC),
      'Support': const Color(0xFFE03E3E),
    };
    final moduleColor = moduleColors[entry.module] ?? AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(
        children: [
          Expanded(flex: 2, child: Row(children: [
            CircleAvatar(radius: 14, backgroundColor: AppColors.primarySurface, child: Text(entry.adminName.substring(0, 1), style: const TextStyle(fontFamily: 'Sora', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary))),
            const SizedBox(width: 8),
            Flexible(child: Text(entry.adminName, style: const TextStyle(fontFamily: 'Sora', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis)),
          ])),
          Expanded(flex: 3, child: Text(entry.action, style: const TextStyle(fontFamily: 'Sora', fontSize: 12, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis)),
          Expanded(flex: 3, child: Text(entry.target, style: const TextStyle(fontFamily: 'Sora', fontSize: 11, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis)),
          Expanded(child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(color: moduleColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
            child: Text(entry.module, style: TextStyle(fontFamily: 'Sora', fontSize: 10, fontWeight: FontWeight.w600, color: moduleColor), maxLines: 1),
          )),
          Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${entry.timestamp.hour}:${entry.timestamp.minute.toString().padLeft(2, '0')}', style: const TextStyle(fontFamily: 'Sora', fontSize: 11, color: AppColors.textPrimary)),
            Text(entry.ipAddress, style: const TextStyle(fontFamily: 'Sora', fontSize: 9, color: AppColors.textMuted)),
          ])),
        ],
      ),
    );
  }
}

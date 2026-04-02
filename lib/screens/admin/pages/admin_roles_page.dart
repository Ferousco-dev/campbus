import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/admin/admin_models.dart';
import '../../../services/admin/admin_service.dart';
import '../../../theme/app_theme.dart';
import '../widgets/admin_section_header.dart';

class AdminRolesPage extends StatefulWidget {
  const AdminRolesPage({super.key});
  @override
  State<AdminRolesPage> createState() => _AdminRolesPageState();
}

class _AdminRolesPageState extends State<AdminRolesPage> {
  List<RolePermission> _roles = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final roles = await AdminService.fetchRoles();
    if (mounted) setState(() { _roles = roles; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AdminSectionHeader(title: 'Roles & Permissions'),
              const Spacer(),
              AdminActionButton(label: 'Add Role', icon: Icons.add_rounded, onTap: () {
                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Add Role — feature stub', style: TextStyle(fontFamily: 'Sora')),
                  backgroundColor: AppColors.textPrimary,
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.fromLTRB(20, 0, 20, 16),
                ));
              }),
            ],
          ),
          const SizedBox(height: 20),

          // Role cards
          ..._roles.map((role) => _buildRoleCard(role)),
        ],
      ),
    );
  }

  Widget _buildRoleCard(RolePermission role) {
    final modules = role.permissions.keys.toList();
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: role.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.verified_user_rounded, color: role.color, size: 20),
                ),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(role.roleName, style: const TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  Text('${role.userCount} admin users', style: const TextStyle(fontFamily: 'Sora', fontSize: 11, color: AppColors.textSecondary)),
                ]),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: role.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text(role.roleName, style: TextStyle(fontFamily: 'Sora', fontSize: 11, fontWeight: FontWeight.w700, color: role.color)),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          // Permissions grid
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Permissions', style: TextStyle(fontFamily: 'Sora', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.8)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: modules.map((module) {
                    final hasAccess = role.permissions[module] ?? false;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: hasAccess ? role.color.withValues(alpha: 0.1) : AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: hasAccess ? role.color.withValues(alpha: 0.3) : AppColors.border),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(hasAccess ? Icons.check_rounded : Icons.remove_rounded, size: 12, color: hasAccess ? role.color : AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(module, style: TextStyle(fontFamily: 'Sora', fontSize: 11, fontWeight: FontWeight.w500, color: hasAccess ? role.color : AppColors.textMuted)),
                      ]),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

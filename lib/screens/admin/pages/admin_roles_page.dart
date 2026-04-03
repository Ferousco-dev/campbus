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
  List<AdminUser> _users = [];
  bool _loading = true;
  RolePermission? _selectedRole;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final results = await Future.wait([
      AdminService.fetchRoles(),
      AdminService.fetchUsers(),
    ]);
    final roles = results[0] as List<RolePermission>;
    final users = results[1] as List<AdminUser>;
    if (mounted) {
      setState(() {
        _roles = roles;
        _users = users;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _selectedRole == null ? _buildRolesList() : _buildRoleDetail(),
    );
  }

  Widget _buildRolesList() {
    return SingleChildScrollView(
      key: const ValueKey('list'),
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
    final modules = role.permissions.keys.toList()..sort();
    final userCount =
        _users.where((u) => u.role == role.role.name).length;
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
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedRole = role);
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
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
                    Text('$userCount admin users', style: const TextStyle(fontFamily: 'Sora', fontSize: 11, color: AppColors.textSecondary)),
                  ]),
                  const Spacer(),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
                ],
              ),
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
                    return GestureDetector(
                      onTap: () => _togglePermission(role, module, hasAccess),
                      child: Container(
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
                      ),
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

  Widget _buildRoleDetail() {
    final role = _selectedRole!;
    final usersInRole =
        _users.where((u) => u.role == role.role.name).toList();

    return SingleChildScrollView(
      key: ValueKey('detail-${role.id}'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _selectedRole = null);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(width: 16),
              Text(role.roleName, style: const TextStyle(fontFamily: 'Sora', fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 32),
          Text('Users assigned as ${role.roleName} (${usersInRole.length})', style: const TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          if (usersInRole.isEmpty)
            const Text('No users found.', style: TextStyle(fontFamily: 'Sora', fontSize: 14, color: AppColors.textMuted))
          else
            ...usersInRole.map((u) => _buildUserListTile(u)),
        ],
      ),
    );
  }

  Widget _buildUserListTile(AdminUser user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primarySurface,
            child: Text(user.fullName.substring(0, 1), style: const TextStyle(fontFamily: 'Sora', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.fullName, style: const TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                Text(user.email, style: const TextStyle(fontFamily: 'Sora', fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFF00B37E).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
            child: const Text('Active', style: TextStyle(fontFamily: 'Sora', fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF00B37E))),
          ),
        ],
      ),
    );
  }

  Future<void> _togglePermission(
    RolePermission role,
    String module,
    bool hasAccess,
  ) async {
    HapticFeedback.lightImpact();
    setState(() {
      role.permissions[module] = !hasAccess;
    });
    await AdminService.updateRolePermission(
      role.id,
      module,
      !hasAccess,
    );
  }
}

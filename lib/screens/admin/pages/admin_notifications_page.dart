import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/admin/admin_models.dart';
import '../../../services/admin/admin_service.dart';
import '../../../theme/app_theme.dart';
import '../widgets/admin_section_header.dart';

class AdminNotificationsPage extends StatefulWidget {
  const AdminNotificationsPage({super.key});
  @override
  State<AdminNotificationsPage> createState() => _AdminNotificationsPageState();
}

class _AdminNotificationsPageState extends State<AdminNotificationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  List<AdminNotification> _sent = [];
  bool _loading = true;

  // Composer state
  final _titleCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  String _type = 'system';
  String _audience = 'All Users';
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() { _tab.dispose(); _titleCtrl.dispose(); _messageCtrl.dispose(); super.dispose(); }

  Future<void> _load() async {
    final sent = await AdminService.fetchSentNotifications();
    if (mounted) setState(() { _sent = sent; _loading = false; });
  }

  Future<void> _send() async {
    if (_titleCtrl.text.isEmpty || _messageCtrl.text.isEmpty) return;
    setState(() => _sending = true);
    await AdminService.sendNotification(title: _titleCtrl.text, message: _messageCtrl.text, type: _type, audience: _audience);
    if (mounted) {
      setState(() => _sending = false);
      _titleCtrl.clear(); _messageCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Notification sent ✓', style: TextStyle(fontFamily: 'Sora')),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Column(
      children: [
        TabBar(controller: _tab, labelStyle: const TextStyle(fontFamily: 'Sora', fontSize: 12, fontWeight: FontWeight.w600), unselectedLabelStyle: const TextStyle(fontFamily: 'Sora', fontSize: 12), labelColor: AppColors.primary, unselectedLabelColor: AppColors.textSecondary, indicatorColor: AppColors.primary, tabs: const [Tab(text: 'Send Notification'), Tab(text: 'Sent History')]),
        Container(height: 1, color: AppColors.border),
        Expanded(child: TabBarView(controller: _tab, children: [_buildComposer(), _buildSentList()])),
      ],
    );
  }

  Widget _buildComposer() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminSectionHeader(title: 'Compose Notification'),
          const SizedBox(height: 20),
          _field('Title', _titleCtrl),
          const SizedBox(height: 16),
          _field('Message', _messageCtrl, maxLines: 4),
          const SizedBox(height: 16),
          // Type selector
          const Text('Type', style: TextStyle(fontFamily: 'Sora', fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: ['system', 'promo', 'transaction', 'trip'].map((t) {
            final active = _type == t;
            return GestureDetector(
              onTap: () => setState(() => _type = t),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: active ? AppColors.primary : AppColors.border),
                ),
                child: Text(t[0].toUpperCase() + t.substring(1), style: TextStyle(fontFamily: 'Sora', fontSize: 12, fontWeight: FontWeight.w600, color: active ? Colors.white : AppColors.textSecondary)),
              ),
            );
          }).toList()),
          const SizedBox(height: 16),
          // Audience selector
          const Text('Audience', style: TextStyle(fontFamily: 'Sora', fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: ['All Users', 'Tier 1', 'Tier 2', 'Tier 3'].map((a) {
            final active = _audience == a;
            return GestureDetector(
              onTap: () => setState(() => _audience = a),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: active ? AppColors.primary : AppColors.border),
                ),
                child: Text(a, style: TextStyle(fontFamily: 'Sora', fontSize: 12, fontWeight: FontWeight.w600, color: active ? Colors.white : AppColors.textSecondary)),
              ),
            );
          }).toList()),
          const SizedBox(height: 28),
          SizedBox(width: double.infinity, height: 50,
            child: ElevatedButton.icon(
              onPressed: _sending ? null : () { HapticFeedback.lightImpact(); _send(); },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
              icon: _sending ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.send_rounded, size: 18),
              label: Text(_sending ? 'Sending…' : 'Send to $_audience', style: const TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentList() {
    return ListView.builder(
      itemCount: _sent.length,
      itemBuilder: (_, i) {
        final n = _sent[i];
        final pct = (n.deliveryRate * 100).toStringAsFixed(0);
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(n.title, style: const TextStyle(fontFamily: 'Sora', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
              AdminStatusChip(label: n.audience, color: AppColors.primary),
            ]),
            const SizedBox(height: 6),
            Text(n.message, style: const TextStyle(fontFamily: 'Sora', fontSize: 12, color: AppColors.textSecondary, height: 1.5), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 12),
            Row(children: [
              const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF00B37E)),
              const SizedBox(width: 5),
              Text('$pct% delivery (${n.delivered}/${n.total})', style: const TextStyle(fontFamily: 'Sora', fontSize: 11, color: AppColors.textSecondary)),
              const Spacer(),
              Text('${n.sentAt.day}/${n.sentAt.month}/${n.sentAt.year}', style: const TextStyle(fontFamily: 'Sora', fontSize: 10, color: AppColors.textMuted)),
            ]),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: n.deliveryRate, backgroundColor: AppColors.border, valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00B37E)), minHeight: 4),
            ),
          ]),
        );
      },
    );
  }

  Widget _field(String label, TextEditingController ctrl, {int maxLines = 1}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontFamily: 'Sora', fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
      const SizedBox(height: 6),
      TextField(
        controller: ctrl,
        maxLines: maxLines,
        style: const TextStyle(fontFamily: 'Sora', fontSize: 13, color: AppColors.textPrimary),
        decoration: InputDecoration(
          filled: true, fillColor: AppColors.background,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
        ),
      ),
    ]);
  }
}

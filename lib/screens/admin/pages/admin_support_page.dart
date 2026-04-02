import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/admin/admin_models.dart';
import '../../../services/admin/admin_service.dart';
import '../../../theme/app_theme.dart';
import '../widgets/admin_section_header.dart';

class AdminSupportPage extends StatefulWidget {
  const AdminSupportPage({super.key});
  @override
  State<AdminSupportPage> createState() => _AdminSupportPageState();
}

class _AdminSupportPageState extends State<AdminSupportPage> {
  List<SupportTicket> _tickets = [];
  bool _loading = true;
  SupportTicket? _selected;
  final _replyCtrl = TextEditingController();
  bool _sending = false;

  @override
  void initState() { super.initState(); _load(); }

  @override
  void dispose() { _replyCtrl.dispose(); super.dispose(); }

  Future<void> _load() async {
    final tickets = await AdminService.fetchTickets();
    if (mounted) setState(() { _tickets = tickets; _loading = false; });
  }

  Future<void> _reply() async {
    if (_replyCtrl.text.isEmpty) return;
    setState(() => _sending = true);
    await AdminService.replyToTicket(_selected!.id, _replyCtrl.text);
    if (mounted) {
      setState(() => _sending = false);
      _replyCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Reply sent ✓', style: TextStyle(fontFamily: 'Sora')),
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
    return Row(
      children: [
        // Ticket list
        SizedBox(
          width: 320,
          child: _buildTicketList(),
        ),
        Container(width: 1, color: AppColors.border),
        // Detail view
        Expanded(
          child: _selected == null
              ? const Center(child: Text('Select a ticket to view details', style: TextStyle(fontFamily: 'Sora', color: AppColors.textMuted)))
              : _buildTicketDetail(_selected!),
        ),
      ],
    );
  }

  Widget _buildTicketList() {
    final open = _tickets.where((t) => t.status == TicketStatus.open || t.status == TicketStatus.inProgress).toList();
    final closed = _tickets.where((t) => t.status == TicketStatus.resolved || t.status == TicketStatus.closed).toList();
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          color: Colors.white,
          child: Row(children: [
            Text('${open.length} Open', style: const TextStyle(fontFamily: 'Sora', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(width: 8),
            Text('· ${closed.length} Closed', style: const TextStyle(fontFamily: 'Sora', fontSize: 12, color: AppColors.textSecondary)),
          ]),
        ),
        Container(height: 1, color: AppColors.border),
        Expanded(
          child: ListView(
            children: [
              if (open.isNotEmpty) ...[
                Padding(padding: const EdgeInsets.fromLTRB(14, 12, 14, 4), child: Text('OPEN', style: const TextStyle(fontFamily: 'Sora', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 1))),
                ...open.map(_buildTicketTile),
              ],
              if (closed.isNotEmpty) ...[
                Padding(padding: const EdgeInsets.fromLTRB(14, 12, 14, 4), child: Text('CLOSED', style: const TextStyle(fontFamily: 'Sora', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 1))),
                ...closed.map(_buildTicketTile),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTicketTile(SupportTicket ticket) {
    final isSelected = _selected?.id == ticket.id;
    return InkWell(
      onTap: () { HapticFeedback.selectionClick(); setState(() => _selected = ticket); },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        color: isSelected ? AppColors.primarySurface : Colors.white,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(ticket.id, style: const TextStyle(fontFamily: 'Sora', fontSize: 10, color: AppColors.textMuted))),
            AdminStatusChip(label: ticket.statusLabel, color: ticket.statusColor),
          ]),
          const SizedBox(height: 4),
          Text(ticket.subject, style: const TextStyle(fontFamily: 'Sora', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Row(children: [
            Text(ticket.userName, style: const TextStyle(fontFamily: 'Sora', fontSize: 11, color: AppColors.textSecondary)),
            const Spacer(),
            AdminStatusChip(label: ticket.priorityLabel, color: ticket.priorityColor),
          ]),
        ]),
      ),
    );
  }

  Widget _buildTicketDetail(SupportTicket ticket) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          color: Colors.white,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(ticket.subject, style: const TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
              AdminStatusChip(label: ticket.statusLabel, color: ticket.statusColor),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              Text('${ticket.userName} · ${ticket.id}', style: const TextStyle(fontFamily: 'Sora', fontSize: 11, color: AppColors.textSecondary)),
              const Spacer(),
              AdminStatusChip(label: ticket.priorityLabel, color: ticket.priorityColor),
            ]),
          ]),
        ),
        Container(height: 1, color: AppColors.border),
        // Messages
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ...ticket.messages.map(_buildMessage),
            ],
          ),
        ),
        Container(height: 1, color: AppColors.border),
        // Reply bar
        Container(
          padding: const EdgeInsets.all(14),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _replyCtrl,
                  style: const TextStyle(fontFamily: 'Sora', fontSize: 13, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Type a reply…',
                    hintStyle: const TextStyle(fontFamily: 'Sora', fontSize: 13, color: AppColors.textMuted),
                    filled: true, fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _sending ? null : _reply,
                child: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                  child: _sending ? const Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))) : const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(width: 8),
              if (ticket.status != TicketStatus.resolved && ticket.status != TicketStatus.closed)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text('Ticket resolved ✓', style: TextStyle(fontFamily: 'Sora')),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(color: const Color(0xFFE6FAF4), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF00B37E).withValues(alpha: 0.3))),
                    child: const Text('Resolve', style: TextStyle(fontFamily: 'Sora', fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF00B37E))),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessage(SupportMessage msg) {
    final isAdmin = msg.sender == 'admin';
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isAdmin ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isAdmin) ...[
            CircleAvatar(radius: 16, backgroundColor: AppColors.primarySurface, child: Text(msg.senderName.substring(0, 1), style: const TextStyle(fontFamily: 'Sora', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary))),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isAdmin ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(14),
                  topRight: const Radius.circular(14),
                  bottomLeft: Radius.circular(isAdmin ? 14 : 4),
                  bottomRight: Radius.circular(isAdmin ? 4 : 14),
                ),
                border: isAdmin ? null : Border.all(color: AppColors.border),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(msg.message, style: TextStyle(fontFamily: 'Sora', fontSize: 13, color: isAdmin ? Colors.white : AppColors.textPrimary, height: 1.5)),
                const SizedBox(height: 4),
                Text('${msg.timestamp.hour}:${msg.timestamp.minute.toString().padLeft(2, '0')}', style: TextStyle(fontFamily: 'Sora', fontSize: 10, color: isAdmin ? Colors.white54 : AppColors.textMuted)),
              ]),
            ),
          ),
          if (isAdmin) ...[
            const SizedBox(width: 10),
            CircleAvatar(radius: 16, backgroundColor: AppColors.primary, child: const Text('A', style: TextStyle(fontFamily: 'Sora', fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white))),
          ],
        ],
      ),
    );
  }
}

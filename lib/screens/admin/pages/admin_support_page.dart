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
    if (_replyCtrl.text.isEmpty || _selected == null) return;
    final ticketId = _selected!.id;
    setState(() => _sending = true);
    await AdminService.replyToTicket(ticketId, _replyCtrl.text);
    await _load();
    if (!mounted) return;
    setState(() {
      _sending = false;
      _selected = _findTicket(ticketId);
    });
    _replyCtrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Reply sent ✓', style: TextStyle(fontFamily: 'Sora')),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _selected == null
          ? Container(key: const ValueKey('list'), color: Colors.white, child: _buildTicketList())
          : Container(key: const ValueKey('detail'), color: AppColors.background, child: _buildTicketDetail(_selected!)),
    );
  }

  Widget _buildTicketList() {
    final open = _tickets.where((t) => t.status == TicketStatus.open || t.status == TicketStatus.inProgress).toList();
    final closed = _tickets.where((t) => t.status == TicketStatus.resolved || t.status == TicketStatus.closed).toList();
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          color: Colors.white,
          child: Row(children: [
            Text('${open.length} Open', style: const TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(width: 8),
            Text('· ${closed.length} Closed', style: const TextStyle(fontFamily: 'Sora', fontSize: 14, color: AppColors.textSecondary)),
          ]),
        ),
        Container(height: 1, color: AppColors.border),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              if (open.isNotEmpty) ...[
                const Padding(padding: EdgeInsets.fromLTRB(20, 12, 20, 8), child: Text('OPEN', style: TextStyle(fontFamily: 'Sora', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 1.2))),
                ...open.map(_buildTicketTile),
              ],
              if (closed.isNotEmpty) ...[
                const Padding(padding: EdgeInsets.fromLTRB(20, 20, 20, 8), child: Text('CLOSED', style: TextStyle(fontFamily: 'Sora', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 1.2))),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () { HapticFeedback.selectionClick(); setState(() => _selected = ticket); },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primarySurface : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: isSelected ? Border.all(color: AppColors.primary.withValues(alpha: 0.2)) : Border.all(color: Colors.transparent),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(ticket.id, style: const TextStyle(fontFamily: 'Sora', fontSize: 11, color: AppColors.textMuted))),
              AdminStatusChip(label: ticket.statusLabel, color: ticket.statusColor),
            ]),
            const SizedBox(height: 10),
            Text(ticket.subject, style: TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: Text(ticket.userName, style: const TextStyle(fontFamily: 'Sora', fontSize: 12, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 8),
              AdminStatusChip(label: ticket.priorityLabel, color: ticket.priorityColor),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _buildTicketDetail(SupportTicket ticket) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          color: Colors.white,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              GestureDetector(
                onTap: () { HapticFeedback.selectionClick(); setState(() => _selected = null); },
                child: Container(
                  padding: const EdgeInsets.only(right: 16, top: 4, bottom: 4),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.textPrimary),
                ),
              ),
              Expanded(child: Text(ticket.subject, style: const TextStyle(fontFamily: 'Sora', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis)),
              AdminStatusChip(label: ticket.statusLabel, color: ticket.statusColor),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Text('${ticket.userName} · ${ticket.id}', style: const TextStyle(fontFamily: 'Sora', fontSize: 13, color: AppColors.textSecondary)),
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
          padding: const EdgeInsets.all(20),
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
                  onTap: () => _resolveTicket(ticket),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isAdmin ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isAdmin ? 16 : 4),
                  bottomRight: Radius.circular(isAdmin ? 4 : 16),
                ),
                border: isAdmin ? null : Border.all(color: AppColors.border),
                boxShadow: isAdmin ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(msg.message, style: TextStyle(fontFamily: 'Sora', fontSize: 14, color: isAdmin ? Colors.white : AppColors.textPrimary, height: 1.5)),
                const SizedBox(height: 6),
                Text('${msg.timestamp.hour}:${msg.timestamp.minute.toString().padLeft(2, '0')}', style: TextStyle(fontFamily: 'Sora', fontSize: 11, color: isAdmin ? Colors.white54 : AppColors.textMuted)),
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

  Future<void> _resolveTicket(SupportTicket ticket) async {
    HapticFeedback.lightImpact();
    await AdminService.resolveTicket(ticket.id);
    await _load();
    if (!mounted) return;
    setState(() {
      _selected = _findTicket(ticket.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Ticket resolved ✓', style: TextStyle(fontFamily: 'Sora')),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  SupportTicket? _findTicket(String id) {
    for (final ticket in _tickets) {
      if (ticket.id == id) return ticket;
    }
    return null;
  }
}

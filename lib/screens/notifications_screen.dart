import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../models/notification_model.dart';
import '../../widgets/notifications/notification_list_item.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<NotificationModel> _notifications;
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', 'Transactions', 'System', 'Promos'];

  @override
  void initState() {
    super.initState();
    // Clone dummy data so we can modify it
    _notifications = List.of(sampleNotifications);
  }

  void _markAllRead() {
    setState(() {
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    });
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'All notifications marked as read',
          style: TextStyle(fontFamily: 'Sora', fontSize: 13),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _markRead(String id) {
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1 && !_notifications[index].isRead) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
      }
    });
  }

  void _removeNotification(String id) {
    setState(() {
      _notifications.removeWhere((n) => n.id == id);
    });
    HapticFeedback.lightImpact();
  }

  List<NotificationModel> get _filteredNotifications {
    if (_selectedFilter == 'All') return _notifications;
    
    NotificationType targetType;
    switch (_selectedFilter) {
      case 'Transactions':
        targetType = NotificationType.transaction;
        break;
      case 'System':
        targetType = NotificationType.system;
        break;
      case 'Promos':
        targetType = NotificationType.promo;
        break;
      default:
        targetType = NotificationType.system;
    }
    
    return _notifications.where((n) => n.type == targetType).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredNotifications;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          scrolledUnderElevation: 2,
          shadowColor: AppColors.primary.withOpacity(0.1),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: AppColors.textPrimary,
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Notifications',
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          actions: [
            if (_notifications.any((n) => !n.isRead))
              IconButton(
                icon: const Icon(Icons.done_all_rounded, size: 22),
                color: AppColors.primary,
                tooltip: 'Mark all as read',
                onPressed: _markAllRead,
              ),
            const SizedBox(width: 8),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  bottom: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = _selectedFilter == filter;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = filter),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          filter,
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        body: filtered.isEmpty
            ? _EmptyState(filterName: _selectedFilter)
            : ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: filtered.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.border.withOpacity(0.5),
                  indent: 78,
                ),
                itemBuilder: (context, index) {
                  // We need the original class because we defined `_formatTime` etc manually there
                  // actually no we abstracted it to `NotificationListItem`. Excellent!
                  return NotificationListItem(
                    notification: filtered[index],
                    onTap: () => _markRead(filtered[index].id),
                    onDismiss: () => _removeNotification(filtered[index].id),
                  );
                },
              ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String filterName;

  const _EmptyState({required this.filterName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border, width: 2),
            ),
            child: const Icon(
              Icons.notifications_off_outlined,
              size: 40,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            filterName == 'All' ? 'No notifications yet' : 'No $filterName notifications',
            style: const TextStyle(
              fontFamily: 'Sora',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'We\'ll let you know when something\nimportant happens.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

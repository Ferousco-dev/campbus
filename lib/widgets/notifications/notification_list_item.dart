import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/notification_model.dart';
import 'package:intl/intl.dart';

class NotificationListItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const NotificationListItem({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    if (difference.inDays == 0) {
      if (difference.inHours < 1) {
        if (difference.inMinutes < 5) return 'Just now';
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    }
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return DateFormat('MMM d').format(time);
  }

  Widget _buildIcon() {
    IconData iconData;
    Color iconColor;
    Color bgColor;

    switch (notification.type) {
      case NotificationType.transaction:
        final bCredit = notification.isCredit ?? true;
        iconData = bCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;
        iconColor = bCredit ? AppColors.success : AppColors.error;
        bgColor = bCredit ? AppColors.successBg : AppColors.errorBg;
        break;
      case NotificationType.system:
        iconData = Icons.info_outline_rounded;
        iconColor = AppColors.primary;
        bgColor = AppColors.primarySurface;
        break;
      case NotificationType.promo:
        iconData = Icons.card_giftcard_rounded;
        iconColor = const Color(0xFFF4A200);
        bgColor = const Color(0xFFFFF8E6);
        break;
      case NotificationType.trip:
        iconData = Icons.directions_bus_rounded;
        iconColor = const Color(0xFF9B5CF6);
        bgColor = const Color(0xFFF3EEFF);
        break;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          iconData,
          color: iconColor,
          size: 20,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        color: AppColors.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
      child: Material(
        color: notification.isRead ? AppColors.surface : AppColors.primarySurface.withOpacity(0.5),
        child: InkWell(
          onTap: onTap,
          splashColor: AppColors.primarySurface,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIcon(),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 14,
                                fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatTime(notification.timestamp),
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: notification.isRead ? AppColors.textMuted : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification.message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: notification.isRead ? AppColors.textSecondary : AppColors.textPrimary.withOpacity(0.85),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!notification.isRead) ...[
                  const SizedBox(width: 12),
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

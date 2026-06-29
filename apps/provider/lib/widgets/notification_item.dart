import 'package:flutter/material.dart';
import 'package:provider/models/notification.dart';

class NotificationItem extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const NotificationItem({
    super.key,
    required this.notification,
    required this.onTap,
  });

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays >= 1) return 'há ${diff.inDays}d';
    if (diff.inHours >= 1) return 'há ${diff.inHours}h';
    return 'há ${diff.inMinutes}min';
  }

  @override
  Widget build(BuildContext context) {
    final isUnread = notification.readedAt == null;
    final isNewApplication = notification.event == 'application.created';

    return InkWell(
      onTap: onTap,
      child: Container(
        color: isUnread
            ? const Color(0xFF3730A3).withOpacity(0.05)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.indigo.shade50,
              child: Icon(
                isNewApplication
                    ? Icons.person_add_alt_1_rounded
                    : Icons.notifications_rounded,
                color: const Color(0xFF3730A3),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isNewApplication
                        ? 'Nova candidatura recebida'
                        : notification.event,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isNewApplication
                        ? 'Um estudante se candidatou a uma das suas vagas. Toque para ver.'
                        : 'Você tem uma nova notificação.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),
            Text(
              _timeAgo(notification.createdAt),
              style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

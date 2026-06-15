import 'package:flutter/material.dart';
import 'package:client/models/notification.dart';

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
    final status = notification.data['status'] as String?;
    final isAccepted = status == 'accepted';

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
              backgroundColor: isAccepted
                  ? Colors.green.shade100
                  : Colors.red.shade100,
              child: Icon(
                isAccepted ? Icons.check_circle_outline : Icons.cancel_outlined,
                color: isAccepted ? Colors.green.shade700 : Colors.red.shade700,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAccepted ? 'Candidatura aceita!' : 'Candidatura recusada',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Sua candidatura foi ${isAccepted ? 'aceita' : 'recusada'}.',
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

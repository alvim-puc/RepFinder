import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/domain/notification_controller.dart';
import 'package:client/widgets/notification_item.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationControllerProvider.notifier).startListening();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    ref.read(notificationControllerProvider.notifier).stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationControllerProvider);
    final unreadCount =
        notificationsAsync.value?.where((n) => n.readedAt == null).length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notificações',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            const Tab(text: 'Todas'),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Não lidas'),
                  if (unreadCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          final unread = notifications
              .where((n) => n.readedAt == null)
              .toList();

          Widget buildList(List list) {
            if (list.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Nenhuma notificação aqui.',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              itemCount: list.length,
              itemBuilder: (ctx, i) {
                final notification = list[i];
                return NotificationItem(
                  notification: notification,
                  onTap: () {
                    if (notification.readedAt == null) {
                      ref
                          .read(notificationControllerProvider.notifier)
                          .markRead(notification.id);
                    }
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(notification.event),
                        content: Text(notification.data.toString()),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Fechar'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [buildList(notifications), buildList(unread)],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text('Erro ao carregar notificações: $e')),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/domain/vacancy_controller.dart';
import 'package:client/domain/application_controller.dart';
import 'package:client/domain/notification_controller.dart';
import 'package:client/widgets/vacancy_card.dart';
import 'package:client/models/vacancy.dart';
import 'package:client/core/connectivity.dart';

class VacanciesScreen extends ConsumerWidget {
  const VacanciesScreen({super.key});

  static const Color _primary = Color(0xFF3730A3);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vacanciesAsync = ref.watch(vacancyControllerProvider);
    final notificationsAsync = ref.watch(notificationControllerProvider);

    final unreadNotifications =
        notificationsAsync.value?.where((n) => n.readedAt == null).length ?? 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Rep',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E1B4B),
                ),
              ),
              TextSpan(
                text: 'Finder',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: _primary,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Color(0xFF1E1B4B),
                  size: 28,
                ),
                onPressed: () => Navigator.pushNamed(context, '/notifications'),
              ),
              if (unreadNotifications > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle, // CORRIGIDO: Era BoxType.circle
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$unreadNotifications',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar vagas...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.tune_rounded, color: _primary),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: vacanciesAsync.when(
              data: (vacancies) {
                if (vacancies.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () =>
                        ref.read(vacancyControllerProvider.notifier).refresh(),
                    child: ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.2,
                        ),
                        const Icon(
                          Icons.search_off_rounded,
                          size: 80,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Nenhuma vaga disponível no momento',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(vacancyControllerProvider.notifier).refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: vacancies.length,
                    itemBuilder: (context, index) {
                      final vacancy = vacancies[index];
                      return VacancyCard(
                        vacancy: vacancy,
                        onTap: () => _showVacancyDetails(context, ref, vacancy),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: _primary),
              ),
              error: (err, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Erro ao carregar vagas'),
                    TextButton(
                      onPressed: () => ref
                          .read(vacancyControllerProvider.notifier)
                          .refresh(),
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showVacancyDetails(
    BuildContext context,
    WidgetRef ref,
    Vacancy vacancy,
  ) {
    final applications = ref.read(applicationControllerProvider).value ?? [];
    final alreadyApplied = applications.any(
      (app) => app.vacancyId == vacancy.id,
    );
    final isOnline = ref.read(connectivityProvider).value ?? true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              vacancy.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1B4B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Publicada em ${vacancy.createdAt.day}/${vacancy.createdAt.month}/${vacancy.createdAt.year}',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
            const SizedBox(height: 20),
            const Text(
              'Descrição',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              vacancy.description,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: alreadyApplied
                    ? null
                    : () async {
                        Navigator.pop(context);
                        await ref
                            .read(applicationControllerProvider.notifier)
                            .apply(vacancy.id);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  alreadyApplied
                      ? 'Já candidatado'
                      : (isOnline ? 'Me candidatar' : 'Candidatar (offline)'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

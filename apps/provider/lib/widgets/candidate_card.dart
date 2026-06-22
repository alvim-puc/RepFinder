import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/models/application.dart';
import 'package:provider/domain/application_controller.dart';

class CandidateCard extends ConsumerWidget {
  final Application application;
  final String vacancyId;

  const CandidateCard({
    super.key,
    required this.application,
    required this.vacancyId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPending = application.status == 'pending';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.indigo.shade50,
                  child: Text(
                    application.applicantName?[0] ?? 'U',
                    style: const TextStyle(color: Color(0xFF3730A3)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application.applicantName ?? 'Candidato',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Inscrito em ${application.createdAt.day}/${application.createdAt.month}',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (!isPending)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: application.status == 'accepted'
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      application.status == 'accepted' ? 'Aceito' : 'Recusado',
                      style: TextStyle(
                        color: application.status == 'accepted'
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            if (isPending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => ref
                          .read(applicationControllerProvider.notifier)
                          .updateStatus(application.id, 'rejected', vacancyId),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text('Recusar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => ref
                          .read(applicationControllerProvider.notifier)
                          .updateStatus(application.id, 'accepted', vacancyId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9488),
                      ),
                      child: const Text('Aceitar'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

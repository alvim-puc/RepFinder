import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/domain/application_controller.dart';
import 'package:provider/widgets/candidate_card.dart';

class ManageCandidatesScreen extends ConsumerWidget {
  final String vacancyId;
  const ManageCandidatesScreen({super.key, required this.vacancyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Usamos um FutureBuilder simples aqui pois o controller é por demanda
    final applicationsFuture = ref
        .read(applicationControllerProvider.notifier)
        .getApplicationsForVacancy(vacancyId);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gestão de Candidatos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder(
        future: applicationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          final applications = snapshot.data ?? [];
          if (applications.isEmpty) {
            return const Center(
              child: Text('Nenhuma candidatura recebida ainda.'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: applications.length,
            itemBuilder: (context, index) => CandidateCard(
              application: applications[index],
              vacancyId: vacancyId,
            ),
          );
        },
      ),
    );
  }
}

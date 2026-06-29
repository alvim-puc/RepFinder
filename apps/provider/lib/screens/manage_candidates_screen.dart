import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/domain/application_controller.dart';
import 'package:provider/widgets/candidate_card.dart';
import 'package:provider/models/application.dart';

class ManageCandidatesScreen extends ConsumerStatefulWidget {
  final String vacancyId;
  const ManageCandidatesScreen({super.key, required this.vacancyId});

  @override
  ConsumerState<ManageCandidatesScreen> createState() =>
      _ManageCandidatesScreenState();
}

class _ManageCandidatesScreenState
    extends ConsumerState<ManageCandidatesScreen> {
  late Future<List<Application>> _applicationsFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // Recarrega a lista a partir do servidor. Chamado na entrada da tela
  // e novamente após cada aceite/recusa, para que a UI reflita o status real.
  void _load() {
    setState(() {
      _applicationsFuture = ref
          .read(applicationControllerProvider.notifier)
          .getApplicationsForVacancy(widget.vacancyId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gestão de Candidatos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _load(),
        child: FutureBuilder(
          future: _applicationsFuture,
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
                vacancyId: widget.vacancyId,
                onChanged: _load,
              ),
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/models/application.dart';
import 'package:provider/models/candidate_profile.dart';
import 'package:provider/domain/application_controller.dart';
import 'package:provider/datasources/user_datasource.dart';

class CandidateCard extends ConsumerStatefulWidget {
  final Application application;
  final String vacancyId;
  final VoidCallback onChanged;

  const CandidateCard({
    super.key,
    required this.application,
    required this.vacancyId,
    required this.onChanged,
  });

  @override
  ConsumerState<CandidateCard> createState() => _CandidateCardState();
}

class _CandidateCardState extends ConsumerState<CandidateCard> {
  bool _isSubmitting = false;

  Future<void> _updateStatus(String status) async {
    // Evita cliques duplicados/em rajada enquanto a requisição está em voo.
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      await ref
          .read(applicationControllerProvider.notifier)
          .updateStatus(widget.application.id, status, widget.vacancyId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Não foi possível atualizar. Esta candidatura pode já ter sido avaliada.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
      // Recarrega a lista a partir do servidor em qualquer caso (sucesso ou erro),
      // para que a tela sempre reflita o status real e os botões não fiquem presos.
      widget.onChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final application = widget.application;
    final isPending = application.status == 'pending';
    // Busca nome, sexo, foto e bio do candidato via perfil público (/users/:id).
    final profileAsync = ref.watch(
      candidateProfileProvider(application.userId),
    );
    final profile = profileAsync.valueOrNull;

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CandidateAvatar(profile: profile),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              profile?.name ?? 'Candidato',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!isPending) ...[
                            const SizedBox(width: 8),
                            _StatusBadge(status: application.status),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Inscrito em ${application.createdAt.day}/${application.createdAt.month}',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      if (profile?.gender != null) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            profile!.genderLabel,
                            style: const TextStyle(
                              color: Color(0xFF3730A3),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                      if ((profile?.bio ?? '').isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          profile!.bio!,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 13,
                            height: 1.4,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
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
                      onPressed: _isSubmitting
                          ? null
                          : () => _updateStatus('rejected'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Recusar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => _updateStatus('accepted'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9488),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Aceitar'),
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

class _CandidateAvatar extends StatelessWidget {
  final CandidateProfile? profile;

  const _CandidateAvatar({required this.profile});

  @override
  Widget build(BuildContext context) {
    final avatarUrl = profile?.avatarUrl;
    final name = profile?.name;

    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 24,
        backgroundColor: Colors.indigo.shade50,
        backgroundImage: NetworkImage(avatarUrl),
        // Se a imagem falhar ao carregar, cai para as iniciais.
        onBackgroundImageError: (_, __) {},
        child: null,
      );
    }

    return CircleAvatar(
      radius: 24,
      backgroundColor: Colors.indigo.shade50,
      child: Text(
        (name != null && name.isNotEmpty) ? name[0].toUpperCase() : 'U',
        style: const TextStyle(
          color: Color(0xFF3730A3),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isAccepted = status == 'accepted';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isAccepted ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isAccepted ? 'Aceito' : 'Recusado',
        style: TextStyle(
          color: isAccepted ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

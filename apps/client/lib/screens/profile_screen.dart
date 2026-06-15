import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:client/domain/auth_controller.dart';
import 'package:client/domain/application_controller.dart';
import 'package:client/domain/vacancy_controller.dart';
import 'package:client/models/user.dart';
import 'package:client/widgets/application_status_chip.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const Color _primary = Color(0xFF3730A3);

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0][0].toUpperCase();
  }

  String _genderLabel(String gender) {
    switch (gender) {
      case 'female':
        return 'Feminino';
      case 'male':
        return 'Masculino';
      case 'non_binary':
        return 'Não-binário';
      case 'other':
        return 'Outro';
      default:
        return gender;
    }
  }

  Future<void> _pickAndUploadAvatar(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image == null) return;

    try {
      await ref.read(authControllerProvider.notifier).updateAvatar(image);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao atualizar foto: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final applicationsAsync = ref.watch(applicationControllerProvider);
    final vacanciesAsync = ref.watch(vacancyControllerProvider);

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0D9488), Color(0xFF3730A3)],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            backgroundImage: user.avatarUrl != null
                                ? NetworkImage(user.avatarUrl!)
                                : null,
                            child: user.avatarUrl == null
                                ? Text(
                                    _initials(user.name),
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => _pickAndUploadAvatar(context, ref),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: _primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Estudante',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                onPressed: () => _showEditProfileSheet(context, ref, user),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Card
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Colors.grey.shade50,
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(
                            Icons.mail_outline,
                            color: _primary,
                          ),
                          title: const Text(
                            'E-mail',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          subtitle: Text(
                            user.email,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Divider(
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                          color: Colors.grey.shade200,
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.school_outlined,
                            color: _primary,
                          ),
                          title: const Text(
                            'Tipo de conta',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          subtitle: const Text(
                            'Estudante',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (user.bio != null && user.bio!.isNotEmpty) ...[
                          Divider(
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                            color: Colors.grey.shade200,
                          ),
                          ListTile(
                            leading: const Icon(
                              Icons.info_outline,
                              color: _primary,
                            ),
                            title: const Text(
                              'Bio',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            subtitle: Text(
                              user.bio!,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                        if (user.gender != null) ...[
                          Divider(
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                            color: Colors.grey.shade200,
                          ),
                          ListTile(
                            leading: const Icon(
                              Icons.person_outline,
                              color: _primary,
                            ),
                            title: const Text(
                              'Gênero',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            subtitle: Text(
                              _genderLabel(user.gender!),
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Candidaturas Section
                  const Text(
                    'Minhas Candidaturas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1B4B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  applicationsAsync.when(
                    data: (applications) {
                      if (applications.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'Você ainda não se candidatou a nenhuma vaga.',
                              style: TextStyle(color: Colors.grey.shade600),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: Colors.grey.shade50,
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: applications.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                            color: Colors.grey.shade200,
                          ),
                          itemBuilder: (context, index) {
                            final app = applications[index];
                            final vacancy = vacanciesAsync.value?.firstWhere(
                              (v) => v.id == app.vacancyId,
                              orElse: () =>
                                  throw Exception('Vaga não encontrada'),
                            );
                            return ListTile(
                              title: Text(
                                vacancy?.title ??
                                    'Vaga #${app.vacancyId.substring(0, 8)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                'Candidatura enviada em ${app.createdAt.day}/${app.createdAt.month}/${app.createdAt.year}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ApplicationStatusChip(status: app.status),
                                  if (app.status == 'pending')
                                    IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      onPressed: () => ref
                                          .read(
                                            applicationControllerProvider
                                                .notifier,
                                          )
                                          .remove(app.id),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Erro ao carregar candidaturas: $e'),
                  ),
                  const SizedBox(height: 32),
                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await ref
                            .read(authControllerProvider.notifier)
                            .logout();
                        if (context.mounted) {
                          Navigator.pushReplacementNamed(context, '/login');
                        }
                      },
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text(
                        'Sair',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileSheet(BuildContext context, WidgetRef ref, User user) {
    final nameCtrl = TextEditingController(text: user.name);
    final emailCtrl = TextEditingController(text: user.email);
    final passwordCtrl = TextEditingController();
    final bioCtrl = TextEditingController(text: user.bio ?? '');
    String? selectedGender = user.gender;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Editar Perfil',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bioCtrl,
                  maxLength: 500,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Bio',
                    hintText: 'Conte um pouco sobre você...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedGender,
                  decoration: const InputDecoration(
                    labelText: 'Gênero',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'female', child: Text('Feminino')),
                    DropdownMenuItem(value: 'male', child: Text('Masculino')),
                    DropdownMenuItem(
                      value: 'non_binary',
                      child: Text('Não-binário'),
                    ),
                    DropdownMenuItem(value: 'other', child: Text('Outro')),
                  ],
                  onChanged: (value) => setState(() => selectedGender = value),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Nova senha (opcional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3730A3),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      await ref
                          .read(authControllerProvider.notifier)
                          .updateMe(
                            name: nameCtrl.text.isNotEmpty
                                ? nameCtrl.text
                                : null,
                            email: emailCtrl.text.isNotEmpty
                                ? emailCtrl.text
                                : null,
                            password: passwordCtrl.text.isNotEmpty
                                ? passwordCtrl.text
                                : null,
                            bio: bioCtrl.text.isNotEmpty ? bioCtrl.text : null,
                            gender: selectedGender,
                          );
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: const Text('Salvar alterações'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

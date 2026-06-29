import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/domain/vacancy_controller.dart';

class CreateVacancyScreen extends ConsumerStatefulWidget {
  const CreateVacancyScreen({super.key});

  @override
  ConsumerState<CreateVacancyScreen> createState() =>
      _CreateVacancyScreenState();
}

class _CreateVacancyScreenState extends ConsumerState<CreateVacancyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Nova Vaga')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Título da Vaga',
                  hintText: 'Ex: Desenvolvedor Full Stack',
                ),
                validator: (v) =>
                    v?.isEmpty ?? true ? 'Informe o título' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descCtrl,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  hintText: 'Descreva os requisitos e benefícios...',
                ),
                validator: (v) =>
                    v?.isEmpty ?? true ? 'Informe a descrição' : null,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    await ref
                        .read(vacancyControllerProvider.notifier)
                        .createVacancy(_titleCtrl.text, _descCtrl.text);
                    if (mounted) Navigator.pop(context);
                  }
                },
                child: const Text('Publicar Vaga'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

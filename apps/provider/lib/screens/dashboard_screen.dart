import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/domain/vacancy_controller.dart';
import 'package:provider/widgets/vacancy_card_rep.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  static const Color _primary = Color(0xFF3730A3);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vacanciesAsync = ref.watch(vacancyControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF1E1B4B),
              size: 28,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Minhas Vagas',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1B4B),
                  ),
                ),
                Text(
                  'Gerencie as vagas criadas por você',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          Expanded(
            child: vacanciesAsync.when(
              data: (vacancies) {
                if (vacancies.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.work_off_outlined,
                          size: 80,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Você ainda não criou nenhuma vaga',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/create-vacancy'),
                          child: const Text('Criar minha primeira vaga'),
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(vacancyControllerProvider.notifier).refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: vacancies.length,
                    itemBuilder: (context, index) =>
                        VacancyCardRep(vacancy: vacancies[index]),
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: _primary),
              ),
              error: (err, _) =>
                  Center(child: Text('Erro ao carregar vagas: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/create-vacancy'),
        backgroundColor: _primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

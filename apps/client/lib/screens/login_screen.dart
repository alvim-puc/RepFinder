import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/core/errors.dart';
import 'package:client/domain/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();

  final _loginEmailCtrl = TextEditingController();
  final _loginPasswordCtrl = TextEditingController();
  final _signupNameCtrl = TextEditingController();
  final _signupEmailCtrl = TextEditingController();
  final _signupPasswordCtrl = TextEditingController();

  bool _loginPasswordVisible = false;
  bool _signupPasswordVisible = false;

  static const Color _primary = Color(0xFF3730A3); // Indigo-700

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailCtrl.dispose();
    _loginPasswordCtrl.dispose();
    _signupNameCtrl.dispose();
    _signupEmailCtrl.dispose();
    _signupPasswordCtrl.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade600),
    );
  }

  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;
    await ref
        .read(authControllerProvider.notifier)
        .login(_loginEmailCtrl.text.trim(), _loginPasswordCtrl.text);
    final state = ref.read(authControllerProvider);
    if (state.hasError) {
      final error = state.error;
      _showError(
        error is AppException
            ? error.message
            : 'Erro ao entrar. Tente novamente.',
      );
    } else if (state.hasValue && state.value != null) {
      if (mounted) Navigator.pushReplacementNamed(context, '/vacancies');
    }
  }

  Future<void> _handleSignup() async {
    if (!_signupFormKey.currentState!.validate()) return;
    await ref
        .read(authControllerProvider.notifier)
        .register(
          _signupNameCtrl.text.trim(),
          _signupEmailCtrl.text.trim(),
          _signupPasswordCtrl.text,
        );
    final state = ref.read(authControllerProvider);
    if (state.hasError) {
      final error = state.error;
      _showError(
        error is AppException
            ? error.message
            : 'Erro ao cadastrar. Tente novamente.',
      );
    } else if (state.hasValue && state.value != null) {
      if (mounted) Navigator.pushReplacementNamed(context, '/vacancies');
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey.shade600),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primary, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Logo
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.home_work_rounded,
                      color: _primary,
                      size: 40,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Rep',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1E1B4B),
                              ),
                            ),
                            TextSpan(
                              text: 'Finder',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: _primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        'Encontre sua república',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),
              // Tab Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: _primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey.shade600,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  tabs: const [
                    Tab(text: 'Entrar'),
                    Tab(text: 'Cadastrar'),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              // Tab Views
              SizedBox(
                height: 420,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Login Form
                    Form(
                      key: _loginFormKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _loginEmailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _inputDecoration(
                              'E-mail',
                              Icons.mail_outline,
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return 'Informe seu e-mail';
                              if (!v.contains('@')) return 'E-mail inválido';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _loginPasswordCtrl,
                            obscureText: !_loginPasswordVisible,
                            decoration:
                                _inputDecoration(
                                  'Senha',
                                  Icons.lock_outline,
                                ).copyWith(
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _loginPasswordVisible
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () => setState(
                                      () => _loginPasswordVisible =
                                          !_loginPasswordVisible,
                                    ),
                                  ),
                                ),
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return 'Informe sua senha';
                              if (v.length < 6)
                                return 'Senha deve ter no mínimo 6 caracteres';
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Entrar',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Esqueci minha senha',
                              style: TextStyle(color: _primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Signup Form
                    Form(
                      key: _signupFormKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _signupNameCtrl,
                            decoration: _inputDecoration(
                              'Nome completo',
                              Icons.person_outline,
                            ),
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Informe seu nome'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _signupEmailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _inputDecoration(
                              'E-mail',
                              Icons.mail_outline,
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return 'Informe seu e-mail';
                              if (!v.contains('@')) return 'E-mail inválido';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _signupPasswordCtrl,
                            obscureText: !_signupPasswordVisible,
                            decoration:
                                _inputDecoration(
                                  'Senha',
                                  Icons.lock_outline,
                                ).copyWith(
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _signupPasswordVisible
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () => setState(
                                      () => _signupPasswordVisible =
                                          !_signupPasswordVisible,
                                    ),
                                  ),
                                ),
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return 'Informe sua senha';
                              if (v.length < 6)
                                return 'Senha deve ter no mínimo 6 caracteres';
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _handleSignup,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Cadastrar',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

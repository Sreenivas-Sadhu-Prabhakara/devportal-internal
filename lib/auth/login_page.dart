import 'package:devportal_shared/devportal_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'auth_cubit.dart';
import 'auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    context.read<AuthCubit>().signIn(_username.text, _password.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: BlocListener<AuthCubit, AuthState>(
        listenWhen: (p, c) => !p.signedIn && c.signedIn,
        listener: (context, state) => context.go('/'),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Container(
                padding: const EdgeInsets.all(36),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  border: Border.all(color: AppColors.line),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const PortalMark(size: 36),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('DEVPORTAL',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 2)),
                            const Text('Admin console',
                                style: TextStyle(
                                    color: AppColors.accentSoft,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Text('Sign in',
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 20),
                    _label('Username'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _username,
                      autofocus: true,
                      onSubmitted: (_) => _submit(),
                      decoration: const InputDecoration(hintText: 'admin'),
                    ),
                    const SizedBox(height: 16),
                    _label('Password'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _password,
                      obscureText: _obscure,
                      onSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => _obscure = !_obscure),
                          icon: Icon(
                              _obscure
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded,
                              size: 18,
                              color: AppColors.textFaint),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (state.error.isNotEmpty) ...[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.error_outline_rounded,
                                      size: 16, color: AppColors.danger),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(state.error,
                                        style: const TextStyle(
                                            color: AppColors.danger,
                                            fontSize: 13)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                            ],
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: state.signingIn ? null : _submit,
                                child: state.signingIn
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white))
                                    : const Text('Sign in'),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    _DemoHint(
                      onFill: () {
                        _username.text = kAdminUsername;
                        _password.text = kAdminPassword;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String t) => Text(t,
      style: const TextStyle(
          color: AppColors.textHi, fontSize: 13, fontWeight: FontWeight.w700));
}

class _DemoHint extends StatelessWidget {
  const _DemoHint({required this.onFill});
  final VoidCallback onFill;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.canvasAlt,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 15, color: AppColors.textFaint),
          const SizedBox(width: 10),
          const Expanded(
            child: SelectableText(
              'Demo: admin / passWORD1234#',
              style: TextStyle(color: AppColors.textLo, fontSize: 12.5),
            ),
          ),
          TextButton(
            onPressed: onFill,
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: const Text('Fill', style: TextStyle(fontSize: 12.5)),
          ),
          IconButton(
            tooltip: 'Copy password',
            visualDensity: VisualDensity.compact,
            onPressed: () => Clipboard.setData(
                const ClipboardData(text: kAdminPassword)),
            icon: const Icon(Icons.copy_rounded,
                size: 14, color: AppColors.textFaint),
          ),
        ],
      ),
    );
  }
}

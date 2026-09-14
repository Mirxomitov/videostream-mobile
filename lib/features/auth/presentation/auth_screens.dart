import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/router/app_router.dart';
import 'auth_bloc.dart';

@RoutePage()
class PhonePage extends StatelessWidget {
  const PhonePage({super.key});
  @override
  Widget build(BuildContext context) => AuthForm(
    title: 'Welcome back',
    label: 'Phone number',
    button: 'Send code',
    keyboard: TextInputType.phone,
    onSubmit: (value) async {
      await context.read<AuthCubit>().requestOtp(value);
      if (context.mounted && context.read<AuthCubit>().state is AuthCodeSent) {
        context.router.push(OtpRoute(phone: value));
      }
    },
  );
}

@RoutePage()
class OtpPage extends StatelessWidget {
  const OtpPage({super.key, required this.phone});
  final String phone;
  @override
  Widget build(BuildContext context) => AuthForm(
    title: 'Verify phone',
    label: '6-digit code',
    button: 'Continue',
    keyboard: TextInputType.number,
    hint: 'Dev code: 123123',
    onSubmit: (value) async {
      await context.read<AuthCubit>().login(phone, value);
      if (context.mounted &&
          context.read<AuthCubit>().state is AuthAuthenticated) {
        context.router.replace(const FeedRoute());
      }
    },
  );
}

class AuthForm extends StatefulWidget {
  const AuthForm({
    super.key,
    required this.title,
    required this.label,
    required this.button,
    required this.keyboard,
    required this.onSubmit,
    this.hint,
  });
  final String title, label, button;
  final TextInputType keyboard;
  final String? hint;
  final Future<void> Function(String) onSubmit;
  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final controller = TextEditingController();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.play_circle_fill_rounded,
                  size: 72,
                  color: Colors.indigo,
                ),
                const SizedBox(height: 24),
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                const Text('VideoStream'),
                const SizedBox(height: 32),
                TextField(
                  controller: controller,
                  keyboardType: widget.keyboard,
                  decoration: InputDecoration(
                    labelText: widget.label,
                    hintText: widget.hint,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                if (state is AuthFailure)
                  Text(
                    state.message,
                    style: const TextStyle(color: Colors.red),
                  ),
                FilledButton(
                  onPressed: state is AuthLoading
                      ? null
                      : () => widget.onSubmit(controller.text.trim()),
                  child: state is AuthLoading
                      ? const CircularProgressIndicator()
                      : Text(widget.button),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

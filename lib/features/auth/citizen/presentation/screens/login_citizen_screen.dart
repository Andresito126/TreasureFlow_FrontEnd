import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:treasureflow/features/auth/citizen/presentation/widgets/auth_feature_item_widget.dart';
import 'package:treasureflow/features/auth/citizen/presentation/providers/auth_provider.dart';
import 'package:treasureflow/features/auth/citizen/presentation/providers/auth_ui_state.dart';
import 'package:treasureflow/shared/widgets/input_field_widget.dart';
import 'package:treasureflow/shared/widgets/primary_button_blue_widget.dart';

class LoginCitizenScreen extends StatefulWidget {
  const LoginCitizenScreen({super.key});

  @override
  State<LoginCitizenScreen> createState() => _LoginCitizenScreenState();
}

class _LoginCitizenScreenState extends State<LoginCitizenScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    authProvider.addListener(_onAuthStatusChanged);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onAuthStatusChanged() {
    final authProvider = context.read<AuthProvider>();

    if (authProvider.status == AuthUiState.success) {
      final route = authProvider.userType == 'establishment'
          ? '/homeLocal'
          : '/homeCitizen';
      context.go(route);
    }

    if (authProvider.status == AuthUiState.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage ?? 'Error al iniciar sesión')),
      );
    }
  }

  void _onLoginPressed() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    context.read<AuthProvider>().login(email: email, password: password);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          // EL PADDINGSSITO DE COLORCITO
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Center(
              //   child: Padding(
              //     padding: const EdgeInsets.only(
              //       right: 40.0,
              //     ), 
              //     child: AuthBasurini(
              //       mood: BasuriniMood.welcome,
              //       speechText: '¡Vamos a\nhacer cosas\ngrandes hoy!',
              //       highlightText:
              //           'grandes', 
              //       bubbleType: BasuriniBubbleType.neutral,
              //     ),
              //   ),
              // ),

              const SizedBox(height: 40),

              RichText(
                text: TextSpan(
                  text: '¡Bienvenido\nde ',
                  style: textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                  children: [
                    TextSpan(
                      text: 'vuelta!',
                      style: textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Nos alegra verte de nuevo.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(24.0),
                  border: Border.all(
                    color: colors.outline.withOpacity(0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      offset: const Offset(0, 1),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    InputFieldWidget(
                      hTPlaceHolder: 'Correo electrónico',
                      iconInput: Icons.mail_outline_rounded,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,

                    ),
                    const SizedBox(height: 16),
                    InputFieldWidget(
                      hTPlaceHolder: 'Contraseña',
                      iconInput: Icons.lock_outline_rounded,
                      isPassword: true,
                      controller: _passwordController,
                    ),
                    const SizedBox(height: 12),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          '¿Olvidaste tu contraseña?',
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        return PrimaryButtonBlueWidget(
                          text: 'Iniciar sesión',
                          isLoading: auth.status == AuthUiState.loading,
                          onPressed: _onLoginPressed,
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '¿No tienes cuenta? ',
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.onSurface.withOpacity(0.6),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            context.push('/onboardingStep5');
                          },
                          child: Text(
                            'Regístrate',
                            style: textTheme.bodySmall?.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 72),

                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AuthFeatureItemWidget(
                          icon: Icons.verified_user_outlined,
                          title: 'Seguro',
                          subtitle: 'Tus datos\nprotegidos',
                        ),
                        AuthFeatureItemWidget(
                          icon: Icons.eco_outlined,
                          title: 'Sostenible',
                          subtitle: 'Cuidamos del\nplaneta',
                        ),
                        AuthFeatureItemWidget(
                          icon: Icons.bolt_outlined,
                          title: 'Rápido',
                          subtitle: 'Accede en\nsegundos',
                        ),
                      ],
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

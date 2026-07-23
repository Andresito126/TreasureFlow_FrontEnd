import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:treasureflow/core/di/app_container.dart';
import 'package:treasureflow/features/auth/di/auth_module.dart';
import 'package:treasureflow/features/auth/presentation/providers/change_password_provider.dart';
import 'package:treasureflow/shared/layouts/app_card_container.dart';
import 'package:treasureflow/shared/widgets/app_toast.dart';
import 'package:treasureflow/shared/widgets/input_field_widget.dart';
import 'package:treasureflow/shared/widgets/primary_button_blue_widget.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  late final ChangePasswordProvider _provider;
  final _formKey = GlobalKey<FormState>();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    final container = context.read<AppContainer>();
    _provider = AuthModule(container).provideChangePasswordProvider();
    _provider.addListener(_onProviderChanged);
  }

  @override
  void dispose() {
    _provider.removeListener(_onProviderChanged);
    _provider.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onProviderChanged() {
    if (!mounted) return;

    switch (_provider.status) {
      case ChangePasswordStatus.success:
        if (!_navigated) {
          _navigated = true;
          AppToast.show(
            context,
            'Contraseña actualizada, inicia sesión',
            type: ToastType.success,
          );
          context.go('/login');
          return;
        }
      case ChangePasswordStatus.error:
        AppToast.show(
          context,
          _provider.errorMessage ?? 'No se pudo cambiar la contraseña',
          type: ToastType.error,
        );
      case ChangePasswordStatus.idle:
      case ChangePasswordStatus.loading:
        break;
    }

    setState(() {});
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    if (_newPasswordController.text != _confirmPasswordController.text) {
      AppToast.show(
        context,
        'Las contraseñas no coinciden',
        type: ToastType.warning,
      );
      return;
    }

    _provider.changePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isLoading = _provider.status == ChangePasswordStatus.loading;
    final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$');

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  BackButton(color: colors.primary),
                  const SizedBox(width: 4),
                  Text(
                    'Cambiar contraseña',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Ingresa tu contraseña actual y la nueva contraseña.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 24),
              AppCardContainer(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      InputFieldWidget(
                        controller: _currentPasswordController,
                        hTPlaceHolder: 'Contraseña actual',
                        iconInput: Icons.lock_outline_rounded,
                        isPassword: true,
                        validator: (v) => v == null || v.isEmpty
                            ? 'Ingresa tu contraseña actual'
                            : null,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => context.push('/forgotPassword'),
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
                      const SizedBox(height: 4),
                      InputFieldWidget(
                        controller: _newPasswordController,
                        hTPlaceHolder: 'Nueva contraseña',
                        iconInput: Icons.lock_reset_rounded,
                        isPassword: true,
                        validator: (v) {
                          if (v == null || v.length < 8)
                            return 'Mínimo 8 caracteres';
                          if (!passwordRegex.hasMatch(v)) {
                            return 'Necesita mayúscula, minúscula y número';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      InputFieldWidget(
                        controller: _confirmPasswordController,
                        hTPlaceHolder: 'Confirmar nueva contraseña',
                        iconInput: Icons.lock_outline_rounded,
                        isPassword: true,
                        validator: (v) => v == null || v.isEmpty
                            ? 'Confirma tu nueva contraseña'
                            : null,
                      ),
                      const SizedBox(height: 24),
                      PrimaryButtonBlueWidget(
                        text: 'Guardar',
                        isLoading: isLoading,
                        onPressed: _onSubmit,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

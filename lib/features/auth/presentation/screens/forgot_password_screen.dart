import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:treasureflow/core/di/app_container.dart';
import 'package:treasureflow/features/auth/di/auth_module.dart';
import 'package:treasureflow/features/auth/presentation/providers/forgot_password_provider.dart';
import 'package:treasureflow/shared/layouts/app_card_container.dart';
import 'package:treasureflow/shared/widgets/app_toast.dart';
import 'package:treasureflow/shared/widgets/input_field_widget.dart';
import 'package:treasureflow/shared/widgets/primary_button_blue_widget.dart';
import 'package:treasureflow/shared/utils/form_validators.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final ForgotPasswordProvider _provider;

  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    final container = context.read<AppContainer>();
    _provider = AuthModule(container).provideForgotPasswordProvider();
    _provider.addListener(_onProviderChanged);
  }

  @override
  void dispose() {
    _provider.removeListener(_onProviderChanged);
    _provider.dispose();
    _phoneController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onProviderChanged() {
    if (!mounted) return;

    switch (_provider.requestStatus) {
      case RequestCodeStatus.sent:
        AppToast.show(
          context,
          'Te enviamos un código por SMS',
          type: ToastType.success,
        );
      case RequestCodeStatus.error:
        AppToast.show(
          context,
          _provider.errorMessage ?? 'No se pudo enviar el código',
          type: ToastType.error,
        );
      case RequestCodeStatus.idle:
      case RequestCodeStatus.loading:
        break;
    }

    switch (_provider.resetStatus) {
      case ResetPasswordStatus.success:
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
      case ResetPasswordStatus.error:
        AppToast.show(
          context,
          _provider.errorMessage ?? 'No se pudo cambiar la contraseña',
          type: ToastType.error,
        );
      case ResetPasswordStatus.idle:
      case ResetPasswordStatus.loading:
        break;
    }

    setState(() {});
  }

  void _onSendCode() {
    final digits = _phoneController.text.trim();
    if (digits.length != 10) {
      AppToast.show(
        context,
        'Ingresa un número de 10 dígitos',
        type: ToastType.warning,
      );
      return;
    }
    _provider.requestCode('+52$digits');
  }

  void _onResetPassword() {
    final code = _codeController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (code.length != 6) {
      AppToast.show(
        context,
        'El código debe tener 6 dígitos',
        type: ToastType.warning,
      );
      return;
    }
    if (!FormValidators.isStrongPassword(password)) {
      AppToast.show(
        context,
        'La contraseña necesita al menos 8 caracteres, una mayúscula, una minúscula y un número',
        type: ToastType.warning,
      );
      return;
    }
    if (password != confirm) {
      AppToast.show(
        context,
        'Las contraseñas no coinciden',
        type: ToastType.warning,
      );
      return;
    }

    _provider.confirm(code: code, newPassword: password);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isStep2 = _provider.phone != null;

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
                    'Recuperar contraseña',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                isStep2
                    ? 'Escribe el código que te llegó por SMS y tu nueva contraseña.'
                    : 'Ingresa tu número y te enviaremos un código por SMS para restablecerla.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 24),
              AppCardContainer(
                child: isStep2 ? _buildStep2(colors, textTheme) : _buildStep1(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    final isLoading = _provider.requestStatus == RequestCodeStatus.loading;
    return Column(
      children: [
        InputFieldWidget(
          controller: _phoneController,
          hTPlaceHolder: 'Número telefónico',
          iconInput: Icons.phone_android_outlined,
          prefixText: '+52',
          keyboardType: TextInputType.phone,
          maxLength: 10,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 24),
        PrimaryButtonBlueWidget(
          text: 'Enviar código',
          isLoading: isLoading,
          onPressed: _onSendCode,
        ),
      ],
    );
  }

  Widget _buildStep2(ColorScheme colors, TextTheme textTheme) {
    final isLoading = _provider.resetStatus == ResetPasswordStatus.loading;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.sms_outlined, size: 18, color: colors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Código enviado a ${_provider.phone}',
                style: textTheme.bodySmall?.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        InputFieldWidget(
          controller: _codeController,
          hTPlaceHolder: 'Código de 6 dígitos',
          iconInput: Icons.pin_outlined,
          keyboardType: TextInputType.number,
          maxLength: 6,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 16),
        InputFieldWidget(
          controller: _passwordController,
          hTPlaceHolder: 'Nueva contraseña',
          iconInput: Icons.lock_outline_rounded,
          isPassword: true,
        ),
        const SizedBox(height: 16),
        InputFieldWidget(
          controller: _confirmPasswordController,
          hTPlaceHolder: 'Confirmar contraseña',
          iconInput: Icons.lock_outline_rounded,
          isPassword: true,
        ),
        const SizedBox(height: 24),
        PrimaryButtonBlueWidget(
          text: 'Cambiar contraseña',
          isLoading: isLoading,
          onPressed: _onResetPassword,
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: isLoading
                ? null
                : () {
                    _codeController.clear();
                    _passwordController.clear();
                    _confirmPasswordController.clear();
                    _provider.resetToPhoneStep();
                  },
            child: Text(
              'Usar otro número',
              style: textTheme.bodySmall?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:treasureflow/core/di/app_container.dart';
import 'package:treasureflow/features/collections/local/domain/entities/payment.dart';
import 'package:treasureflow/features/collections/local/presentation/widgets/card_payment_form_widget.dart';
import 'package:treasureflow/features/collections/local/presentation/widgets/conekta_method_selector_widget.dart';
import 'package:treasureflow/features/collections/local/presentation/widgets/payment_voucher_widget.dart';
import 'package:treasureflow/features/premium/di/premium_module.dart';
import 'package:treasureflow/features/premium/shared/presentation/providers/premium_provider.dart';
import 'package:treasureflow/shared/widgets/app_toast.dart';
import 'package:treasureflow/shared/widgets/primary_button_blue_widget.dart';
import 'package:treasureflow/shared/widgets/primary_button_green_widget.dart';

const premiumPriceMxn = 16.0;
const _goldAccent = Color(0xFFF5A623);

class PremiumFeature {
  final String label;
  final String? freeLabel;
  final String? premiumLabel;
  final bool freeIncluded;

  const PremiumFeature(
    this.label, {
    this.freeIncluded = true,
    this.freeLabel,
    this.premiumLabel,
  });
}

class PremiumScreenBase extends StatefulWidget {
  final String subtitle;
  final List<PremiumFeature> features;

  const PremiumScreenBase({
    super.key,
    required this.subtitle,
    required this.features,
  });

  @override
  State<PremiumScreenBase> createState() => _PremiumScreenBaseState();
}

class _PremiumScreenBaseState extends State<PremiumScreenBase> {
  late final PremiumProvider _provider;

  bool _showPaymentSection = false;
  PaymentMethodType? _selectedMethod;
  bool _showCardForm = false;

  @override
  void initState() {
    super.initState();
    _provider =
        PremiumModule(context.read<AppContainer>()).providePremiumProvider();
    _provider.addListener(_onProviderChanged);
    _provider.load();
  }

  @override
  void dispose() {
    _provider.removeListener(_onProviderChanged);
    _provider.dispose();
    super.dispose();
  }

  void _onProviderChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _onPayWithCard(String tokenId) async {
    final success = await _provider.payWithCard(tokenId);
    if (!mounted) return;
    if (success && _provider.isPremium) {
      AppToast.show(context, '¡Ya eres Premium! 🎉', type: ToastType.success);
    } else if (!success) {
      AppToast.show(
        context,
        _provider.actionError ?? 'No se pudo procesar el pago',
        type: ToastType.error,
      );
    }
  }

  Future<void> _onGenerateVoucher() async {
    final method = _selectedMethod;
    if (method == null) return;
    final success = await _provider.payWithVoucher(method);
    if (!mounted) return;
    if (!success) {
      AppToast.show(
        context,
        _provider.actionError ?? 'No se pudo generar la referencia',
        type: ToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(colors, textTheme),
            Expanded(child: _buildBody(colors, textTheme)),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(ColorScheme colors, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: colors.primary,
              child: Icon(Icons.arrow_back, size: 18, color: colors.onPrimary),
            ),
          ),
          const SizedBox(width: 14),
          Text(
            'TreasureFlow Premium',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ColorScheme colors, TextTheme textTheme) {
    switch (_provider.status) {
      case PremiumLoadStatus.idle:
      case PremiumLoadStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case PremiumLoadStatus.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline_rounded, size: 48, color: colors.error),
                const SizedBox(height: 16),
                Text(
                  _provider.errorMessage ?? 'No se pudo cargar tu plan',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                PrimaryButtonBlueWidget(
                  text: 'Reintentar',
                  onPressed: _provider.load,
                ),
              ],
            ),
          ),
        );
      case PremiumLoadStatus.success:
        if (_provider.isPremium) return _buildPremiumActive(colors, textTheme);
        return _buildSaleView(colors, textTheme);
    }
  }

  Widget _buildPremiumActive(ColorScheme colors, TextTheme textTheme) {
    final expiresAt = _provider.premiumStatus?.premiumExpiresAt;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 34,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.workspace_premium_rounded,
                    size: 38,
                    color: _goldAccent,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '¡Ya eres Premium!',
                  style: textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (expiresAt != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Tu plan está activo hasta el ${_formatDate(expiresAt)}',
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildFeaturesTable(colors, textTheme),
          const SizedBox(height: 24),
          Text(
            '¿Quieres extender tu plan? Cada pago suma 30 días más.',
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: colors.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 12),
          PrimaryButtonGreenWidget(
            text: 'Extender 30 días — \$${premiumPriceMxn.toStringAsFixed(2)} MXN',
            onPressed: () => setState(() => _showPaymentSection = true),
          ),
          if (_showPaymentSection) ...[
            const SizedBox(height: 20),
            _buildPaymentSection(colors, textTheme),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSaleView(ColorScheme colors, TextTheme textTheme) {
    final voucher = _provider.paymentResult;
    final hasActiveVoucher = voucher != null &&
        voucher.method != PaymentMethodType.card &&
        _provider.pollingStatus != PaymentPollingStatus.idle;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeroCard(colors, textTheme),
          const SizedBox(height: 16),
          _buildFeaturesTable(colors, textTheme),
          const SizedBox(height: 24),
          if (hasActiveVoucher)
            PaymentVoucherWidget(
              result: voucher,
              pollingStatus: _provider.pollingStatus,
              onRetry: () {
                _provider.resetPaymentFlow();
                setState(() {
                  _selectedMethod = null;
                  _showCardForm = false;
                });
              },
              onCheckNow: _provider.checkPaymentNow,
            )
          else ...[
            _buildPriceSection(colors, textTheme),
            const SizedBox(height: 16),
            if (!_showPaymentSection)
              PrimaryButtonGreenWidget(
                text: 'Hazte Premium',
                onPressed: () => setState(() => _showPaymentSection = true),
              )
            else
              _buildPaymentSection(colors, textTheme),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: Text(
                  'Continuar con el plan gratis',
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeroCard(ColorScheme colors, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 26),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.workspace_premium_rounded,
              size: 34,
              color: _goldAccent,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'TreasureFlow Premium',
            style: textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.subtitle,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesTable(ColorScheme colors, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outline.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Funciones',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                width: 52,
                child: Text(
                  'Gratis',
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.workspace_premium_rounded,
                      size: 13,
                      color: _goldAccent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Premium',
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          for (var i = 0; i < widget.features.length; i++)
            _buildFeatureRow(
              widget.features[i],
              showDivider: i < widget.features.length - 1,
              colors: colors,
              textTheme: textTheme,
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(
    PremiumFeature feature, {
    required bool showDivider,
    required ColorScheme colors,
    required TextTheme textTheme,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  feature.label,
                  style: textTheme.bodySmall?.copyWith(fontSize: 12.5),
                ),
              ),
              SizedBox(
                width: 52,
                child: Center(
                  child: feature.freeLabel != null
                      ? Text(
                          feature.freeLabel!,
                          style: textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : feature.freeIncluded
                          ? Icon(
                              Icons.check_rounded,
                              size: 17,
                              color: colors.onSurface.withValues(alpha: 0.35),
                            )
                          : Text(
                              '—',
                              style: textTheme.bodySmall?.copyWith(
                                color: colors.onSurface.withValues(alpha: 0.3),
                              ),
                            ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 72,
                padding: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: feature.premiumLabel != null
                      ? Text(
                          feature.premiumLabel!,
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : Icon(
                          Icons.check_rounded,
                          size: 17,
                          color: colors.primary,
                        ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(height: 1, color: colors.outline.withValues(alpha: 0.12)),
      ],
    );
  }

  Widget _buildPriceSection(ColorScheme colors, TextTheme textTheme) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '\$${premiumPriceMxn.toStringAsFixed(2)}',
              style: textTheme.headlineMedium?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'MXN / mes',
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Cada pago activa 30 días · sin renovación automática',
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(
            fontSize: 11,
            color: colors.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSection(ColorScheme colors, TextTheme textTheme) {
    final isWorking = _provider.isPaying;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Elige tu método de pago',
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ConektaMethodSelectorWidget(
          selected: _selectedMethod,
          onChanged: isWorking
              ? (_) {}
              : (method) => setState(() {
                    _selectedMethod = method;
                    _showCardForm = method == PaymentMethodType.card;
                  }),
        ),
        const SizedBox(height: 16),
        if (_showCardForm)
          CardPaymentFormWidget(
            amount: premiumPriceMxn,
            isLoading: isWorking,
            onSubmit: _onPayWithCard,
          )
        else if (_selectedMethod != null)
          PrimaryButtonGreenWidget(
            text: _selectedMethod == PaymentMethodType.cash
                ? 'Generar referencia OXXO'
                : 'Generar CLABE SPEI',
            isLoading: isWorking,
            onPressed: _onGenerateVoucher,
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }
}

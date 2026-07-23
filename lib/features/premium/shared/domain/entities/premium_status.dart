import 'package:treasureflow/features/collections/local/domain/entities/payment.dart';

class PremiumPendingPayment {
  final String paymentId;
  final PaymentMethodType method;
  final String? reference;
  final DateTime? expiresAt;

  const PremiumPendingPayment({
    required this.paymentId,
    required this.method,
    this.reference,
    this.expiresAt,
  });

  factory PremiumPendingPayment.fromJson(Map<String, dynamic> json) =>
      PremiumPendingPayment(
        paymentId: json['paymentId'] as String,
        method: PaymentMethodType.fromApi(json['method'] as String?),
        reference: json['reference'] as String?,
        expiresAt: json['expiresAt'] != null
            ? DateTime.tryParse(json['expiresAt'].toString())
            : null,
      );
}

class PremiumStatus {
  final bool isPremium;
  final DateTime? premiumExpiresAt;
  final PremiumPendingPayment? pendingPayment;

  const PremiumStatus({
    required this.isPremium,
    this.premiumExpiresAt,
    this.pendingPayment,
  });

  factory PremiumStatus.fromJson(Map<String, dynamic> json) => PremiumStatus(
        isPremium: json['isPremium'] as bool? ?? false,
        premiumExpiresAt: json['premiumExpiresAt'] != null
            ? DateTime.tryParse(json['premiumExpiresAt'].toString())
            : null,
        pendingPayment: json['pendingPayment'] != null
            ? PremiumPendingPayment.fromJson(
                json['pendingPayment'] as Map<String, dynamic>)
            : null,
      );
}

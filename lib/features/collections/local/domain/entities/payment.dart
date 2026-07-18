enum PaymentMethodType {
  card,
  cash,
  transfer,
  unknown;

  static PaymentMethodType fromApi(String? raw) => switch (raw) {
        'card' => card,
        'cash' => cash,
        'transfer' => transfer,
        _ => unknown,
      };

  String get apiValue => switch (this) {
        card => 'card',
        cash => 'cash',
        transfer => 'transfer',
        unknown => 'card',
      };

  String get label => switch (this) {
        card => 'Tarjeta',
        cash => 'Efectivo (OXXO)',
        transfer => 'Transferencia (SPEI)',
        unknown => 'Desconocido',
      };
}

enum PaymentStatusType {
  pending,
  paidHeld,
  released,
  failed,
  unknown;

  static PaymentStatusType fromApi(String? raw) => switch (raw) {
        'pending' => pending,
        'paid_held' => paidHeld,
        'released' => released,
        'failed' => failed,
        _ => unknown,
      };
}

class Payment {
  final String paymentId;
  final PaymentMethodType method;
  final PaymentStatusType status;
  final double grossAmount;
  final double treasureflowFee;
  final double receiverNetAmount;
  final String? reference;
  final DateTime? paymentDate;

  const Payment({
    required this.paymentId,
    required this.method,
    required this.status,
    required this.grossAmount,
    required this.treasureflowFee,
    required this.receiverNetAmount,
    this.reference,
    this.paymentDate,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      paymentId: json['paymentId'] as String,
      method: PaymentMethodType.fromApi(json['method'] as String?),
      status: PaymentStatusType.fromApi(json['status'] as String?),
      grossAmount: (json['grossAmount'] as num?)?.toDouble() ?? 0,
      treasureflowFee: (json['treasureflowFee'] as num?)?.toDouble() ?? 0,
      receiverNetAmount: (json['receiverNetAmount'] as num?)?.toDouble() ?? 0,
      reference: json['reference'] as String?,
      paymentDate: json['paymentDate'] != null
          ? DateTime.tryParse(json['paymentDate'].toString())
          : null,
    );
  }
}

import 'package:treasureflow/features/collections/local/domain/entities/payment.dart';

class CreatePaymentResult {
  final String paymentId;
  final PaymentStatusType status;
  final PaymentMethodType method;
  final double amount;
  final String? reference;
  final String? barcodeUrl;
  final DateTime? expiresAt;

  const CreatePaymentResult({
    required this.paymentId,
    required this.status,
    required this.method,
    required this.amount,
    this.reference,
    this.barcodeUrl,
    this.expiresAt,
  });

  factory CreatePaymentResult.fromJson(Map<String, dynamic> json) {
    return CreatePaymentResult(
      paymentId: json['paymentId'] as String,
      status: PaymentStatusType.fromApi(json['status'] as String?),
      method: PaymentMethodType.fromApi(json['method'] as String?),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      reference: json['reference'] as String?,
      barcodeUrl: json['barcodeUrl'] as String?,
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'].toString())
          : null,
    );
  }
}

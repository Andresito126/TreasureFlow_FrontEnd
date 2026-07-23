import 'package:treasureflow/features/collections/local/domain/entities/collection.dart';
import 'package:treasureflow/features/collections/local/domain/entities/payment.dart';

class CheckPaymentStatusResult {
  final PaymentStatusType paymentStatus;

  /// 'paid' | 'pending_payment' | 'expired' | 'declined' | 'unknown'
  final String gatewayStatus;
  final CollectionStatus collectionStatus;

  const CheckPaymentStatusResult({
    required this.paymentStatus,
    required this.gatewayStatus,
    required this.collectionStatus,
  });

  factory CheckPaymentStatusResult.fromJson(Map<String, dynamic> json) {
    return CheckPaymentStatusResult(
      paymentStatus: PaymentStatusType.fromApi(json['paymentStatus'] as String?),
      gatewayStatus: json['gatewayStatus'] as String? ?? 'unknown',
      collectionStatus:
          CollectionStatus.fromApi(json['collectionStatus'] as String?),
    );
  }
}

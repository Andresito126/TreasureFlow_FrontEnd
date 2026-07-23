import 'package:treasureflow/features/collections/local/domain/entities/create_payment_result.dart';
import 'package:treasureflow/features/collections/local/domain/entities/payment.dart';
import 'package:treasureflow/features/premium/shared/domain/entities/premium_status.dart';

abstract class PremiumRepository {
  Future<PremiumStatus> getStatus();

  Future<CreatePaymentResult> pay({
    required PaymentMethodType method,
    String? tokenId,
  });
}

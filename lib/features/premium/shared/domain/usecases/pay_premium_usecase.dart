import 'package:treasureflow/features/collections/local/domain/entities/create_payment_result.dart';
import 'package:treasureflow/features/collections/local/domain/entities/payment.dart';
import 'package:treasureflow/features/premium/shared/domain/repositories/premium_repository.dart';

class PayPremiumUseCase {
  final PremiumRepository _repository;

  const PayPremiumUseCase(this._repository);

  Future<CreatePaymentResult> call({
    required PaymentMethodType method,
    String? tokenId,
  }) =>
      _repository.pay(method: method, tokenId: tokenId);
}

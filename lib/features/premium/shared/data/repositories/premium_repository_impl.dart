import 'package:treasureflow/features/collections/local/domain/entities/create_payment_result.dart';
import 'package:treasureflow/features/collections/local/domain/entities/payment.dart';
import 'package:treasureflow/features/premium/shared/data/datasources/premium_remote_datasource.dart';
import 'package:treasureflow/features/premium/shared/domain/entities/premium_status.dart';
import 'package:treasureflow/features/premium/shared/domain/repositories/premium_repository.dart';

class PremiumRepositoryImpl implements PremiumRepository {
  final PremiumRemoteDatasource _datasource;

  const PremiumRepositoryImpl(this._datasource);

  @override
  Future<PremiumStatus> getStatus() => _datasource.getStatus();

  @override
  Future<CreatePaymentResult> pay({
    required PaymentMethodType method,
    String? tokenId,
  }) =>
      _datasource.pay(method: method, tokenId: tokenId);
}

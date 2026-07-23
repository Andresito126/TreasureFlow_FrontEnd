import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/features/collections/local/domain/entities/create_payment_result.dart';
import 'package:treasureflow/features/collections/local/domain/entities/payment.dart';
import 'package:treasureflow/features/premium/shared/domain/entities/premium_status.dart';

class PremiumRemoteDatasource {
  final ApiClient _apiClient;

  const PremiumRemoteDatasource(this._apiClient);

  Future<PremiumStatus> getStatus() async {
    final data = await _apiClient.get('/premium/status');
    return PremiumStatus.fromJson(data);
  }

  Future<CreatePaymentResult> pay({
    required PaymentMethodType method,
    String? tokenId,
  }) async {
    final data = await _apiClient.post(
      '/premium/payment',
      body: {
        'method': method.apiValue,
        if (tokenId != null) 'tokenId': tokenId,
      },
    );
    return CreatePaymentResult.fromJson(data);
  }
}

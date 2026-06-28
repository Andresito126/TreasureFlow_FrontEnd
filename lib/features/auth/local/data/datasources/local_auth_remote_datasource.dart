import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/features/auth/local/data/models/local_register_request_model.dart';

class LocalAuthRemoteDatasource {
  final ApiClient _apiClient;

  const LocalAuthRemoteDatasource(this._apiClient);

  Future<String> signUp(LocalRegisterRequestModel model) async {
    final response = await _apiClient.post(
      '/establishments',
      body: model.toJson(),
    );
    return response['id'] as String;
  }
}

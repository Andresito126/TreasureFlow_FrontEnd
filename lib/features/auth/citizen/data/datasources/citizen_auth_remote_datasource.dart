import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/features/auth/citizen/data/models/citizen_register_request_model.dart';

class CitizenAuthRemoteDatasource {
  final ApiClient _apiClient;

  const CitizenAuthRemoteDatasource(this._apiClient);

  Future<String> signUp(CitizenRegisterRequestModel model) async {
    final response = await _apiClient.post(
      '/citizens',
      body: model.toJson(),
    );
    return response['id'] as String;
  }
}

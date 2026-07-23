import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/features/profile/citizen/domain/entities/citizen_full_profile.dart';

class CitizenProfileRemoteDatasource {
  final ApiClient _apiClient;

  const CitizenProfileRemoteDatasource(this._apiClient);

  Future<CitizenFullProfile> getProfile() async {
    final response = await _apiClient.get('/citizens/me');

    return CitizenFullProfile(
      email: response['email'] as String,
      firstName: response['firstName'] as String,
      paternalLastName: response['paternalLastName'] as String,
      maternalLastName: response['maternalLastName'] as String,
      phone: response['phone'] as String,
      profilePictureUrl: response['profilePictureUrl'] as String?,
    );
  }

  Future<void> updateProfile({
    String? firstName,
    String? paternalLastName,
    String? maternalLastName,
    String? phone,
    String? profilePictureUrl,
  }) {
    return _apiClient.patch(
      '/citizens/me',
      body: {
        if (firstName != null) 'firstName': firstName,
        if (paternalLastName != null) 'paternalLastName': paternalLastName,
        if (maternalLastName != null) 'maternalLastName': maternalLastName,
        if (phone != null) 'phone': phone,
        if (profilePictureUrl != null) 'profilePictureUrl': profilePictureUrl,
      },
    );
  }
}

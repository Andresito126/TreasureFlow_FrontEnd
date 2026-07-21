import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/features/profile/local/domain/entities/establishment_profile.dart';

class LocalProfileRemoteDatasource {
  final ApiClient _apiClient;

  const LocalProfileRemoteDatasource(this._apiClient);

  Future<EstablishmentProfile> getProfile() async {
    final response = await _apiClient.get('/establishments/me');

    return EstablishmentProfile(
      email: response['email'] as String,
      phone: response['phone'] as String,
      profilePictureUrl: response['profilePictureUrl'] as String?,
      storeName: response['storeName'] as String,
      latitude: (response['latitude'] as num).toDouble(),
      longitude: (response['longitude'] as num).toDouble(),
      addressText: response['addressText'] as String?,
      hasVehicle: response['hasVehicle'] as bool,
      materialTypeIds: (response['materialTypeIds'] as List).cast<String>(),
      schedules: (response['schedules'] as List)
          .map((s) => EstablishmentSchedule(
                dayOfWeek: (s['dayOfWeek'] as num).toInt(),
                startTime: s['startTime'] as String,
                endTime: s['endTime'] as String,
              ))
          .toList(),
      photoUrls: (response['photoUrls'] as List).cast<String>(),
    );
  }
}

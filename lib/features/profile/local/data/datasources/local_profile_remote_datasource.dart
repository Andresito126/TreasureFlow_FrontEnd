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
          .map(
            (s) => EstablishmentSchedule(
              dayOfWeek: (s['dayOfWeek'] as num).toInt(),
              startTime: s['startTime'] as String,
              endTime: s['endTime'] as String,
            ),
          )
          .toList(),
      photoUrls: (response['photoUrls'] as List).cast<String>(),
      isPremium: response['isPremium'] as bool? ?? false,
    );
  }

  Future<void> updateProfile({
    String? storeName,
    String? phone,
    String? addressText,
    bool? hasVehicle,
    String? profilePictureUrl,
    List<EstablishmentSchedule>? schedules,
    List<String>? photoUrls,
  }) {
    return _apiClient.patch(
      '/establishments/me',
      body: {
        if (storeName != null) 'storeName': storeName,
        if (phone != null) 'phone': phone,
        if (addressText != null) 'addressText': addressText,
        if (hasVehicle != null) 'hasVehicle': hasVehicle,
        if (profilePictureUrl != null) 'profilePictureUrl': profilePictureUrl,
        if (schedules != null)
          'schedules': schedules
              .map(
                (s) => {
                  'dayOfWeek': s.dayOfWeek,
                  'startTime': s.startTime,
                  'endTime': s.endTime,
                },
              )
              .toList(),
        if (photoUrls != null) 'photoUrls': photoUrls,
      },
    );
  }
}

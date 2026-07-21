import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/features/home/local/domain/entities/local_home_feed_item.dart';

class LocalHomeFeedRemoteDatasource {
  final ApiClient _apiClient;

  const LocalHomeFeedRemoteDatasource(this._apiClient);

  Future<LocalHomeFeedPage> getFeed({int limit = 20, int offset = 0}) async {
    final response = await _apiClient.get('/posts/waste/feed?limit=$limit&offset=$offset');

    final results = (response['results'] as List)
        .map((item) => _fromJson(item as Map<String, dynamic>))
        .toList();

    return LocalHomeFeedPage(
      total: response['total'] as int,
      results: results,
    );
  }

  LocalHomeFeedItem _fromJson(Map<String, dynamic> json) {
    return LocalHomeFeedItem(
      id: json['id'] as String,
      description: json['description'] as String?,
      mainPhotoUrl: json['mainPhotoUrl'] as String?,
      citizenId: json['citizenId'] as String,
      citizenName: json['citizenName'] as String,
      citizenProfilePictureUrl: json['citizenProfilePictureUrl'] as String,
      publishedAt: json['publishedAt'] as String,
      isFeatured: json['isFeatured'] as bool,
      zoneId: (json['zoneId'] as num?)?.toInt(),
      materialTypeId: json['materialTypeId'] as String,
      materialTypeName: json['materialTypeName'] as String,
      distanceMeters: (json['distanceMeters'] as num).toInt(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}

import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/features/profile/citizen/domain/entities/post_summary.dart';
import 'package:treasureflow/features/feed/domain/entities/recommended_post.dart';
// import 'package:treasureflow/features/profile/domain/entities/post_summary.dart';

class FeedRemoteDatasource {
  final ApiClient _apiClient;

  const FeedRemoteDatasource(this._apiClient);

  Future<PaginatedPosts> getFeedPosts({int limit = 10, String? cursor}) async {
    final queryParams = <String>[
      'limit=$limit',
      if (cursor != null) 'cursor=$cursor',
    ];

    final response = await _apiClient.get(
      '/posts/feed?${queryParams.join('&')}',
    );

    final items = (response['items'] as List)
        .map((item) => _fromJson(item as Map<String, dynamic>))
        .toList();

    return PaginatedPosts(
      items: items,
      nextCursor: response['nextCursor'] as String?,
    );
  }

  PostSummary _fromJson(Map<String, dynamic> json) {
    return PostSummary(
      id: json['id'] as String,
      publicationType: json['publicationType'] as String,
      mainPhotoUrl: json['mainPhotoUrl'] as String?,
      status: json['status'] as String,
      offerCount: json['offerCount'] as int,
      viewsCount: json['viewsCount'] as int,
      publishedAt: json['publishedAt'] as String,
    );
  }

  Future<PaginatedRecommendedPosts> getRecommendedFeed({
    int limit = 10,
    int offset = 0,
  }) async {
    final path = '/posts/waste/feed?limit=$limit&offset=$offset';
    // debugPrint('[FeedRemoteDatasource] GET $path');

    final response = await _apiClient.get(path);
    // debugPrint('[FeedRemoteDatasource] response: $response');

    final items = (response['results'] as List)
        .map((item) => _recommendedFromJson(item as Map<String, dynamic>))
        .toList();

    return PaginatedRecommendedPosts(
      total: response['total'] as int,
      items: items,
    );
  }

  RecommendedPost _recommendedFromJson(Map<String, dynamic> json) {
    try {
      return RecommendedPost(
        id: json['id'] as String,
        description: json['description'] as String,
        mainPhotoUrl: json['mainPhotoUrl'] as String?,
        publishedAt: json['publishedAt'] as String,
        isFeatured: json['isFeatured'] as bool? ?? false,
        zoneId: json['zoneId'] as int,
        materialTypeId: json['materialTypeId'] as String,
        materialTypeName: json['materialTypeName'] as String,
        distanceMeters: (json['distanceMeters'] as num).toDouble(),
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
      );
    } catch (e) {
      // debugPrint('[FeedRemoteDatasource] error parsing item: $json');
      // debugPrint('[FeedRemoteDatasource] parse error: $e');
      rethrow;
    }
  }
}

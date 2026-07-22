import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/features/profile/citizen/domain/entities/post_summary.dart';

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
}

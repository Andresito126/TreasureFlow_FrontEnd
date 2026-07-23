import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/features/reviews/domain/entities/review.dart';

class ReviewsRemoteDatasource {
  final ApiClient _apiClient;

  const ReviewsRemoteDatasource(this._apiClient);

  Future<ReviewsPage> listForEstablishment({
    required String establishmentId,
    required int limit,
    required int offset,
  }) async {
    final response = await _apiClient.get(
      '/reviews/establishment/$establishmentId?limit=$limit&offset=$offset',
    );
    return _pageFromJson(response);
  }

  Future<ReviewsPage> listMine({required int limit, required int offset}) async {
    final response = await _apiClient.get('/reviews/me?limit=$limit&offset=$offset');
    return _pageFromJson(response);
  }

  Future<List<EligibleCollection>> getEligibility(String establishmentId) async {
    final response = await _apiClient.getList('/reviews/eligibility/$establishmentId');
    return response
        .map(
          (e) => EligibleCollection(
            collectionId: e['collectionId'] as String,
            wasteTitle: e['wasteTitle'] as String,
          ),
        )
        .toList();
  }

  Future<String> submitReview({
    required String collectionId,
    required int rating,
    String? comment,
  }) async {
    final response = await _apiClient.post(
      '/reviews',
      body: {
        'collectionId': collectionId,
        'rating': rating,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      },
    );
    return response['id'] as String;
  }

  Future<void> updateReview({
    required String reviewId,
    required int rating,
    String? comment,
  }) async {
    await _apiClient.patch(
      '/reviews/$reviewId',
      body: {
        'rating': rating,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      },
    );
  }

  Future<void> deleteReview(String reviewId) async {
    await _apiClient.delete('/reviews/$reviewId');
  }

  ReviewsPage _pageFromJson(Map<String, dynamic> response) {
    return ReviewsPage(
      total: response['total'] as int,
      items: (response['items'] as List)
          .map(
            (r) => Review(
              id: r['id'] as String,
              citizenId: r['citizenId'] as String,
              citizenName: r['citizenName'] as String,
              rating: (r['rating'] as num).toInt(),
              comment: r['comment'] as String?,
              createdAt: DateTime.parse(r['createdAt'] as String),
            ),
          )
          .toList(),
    );
  }
}

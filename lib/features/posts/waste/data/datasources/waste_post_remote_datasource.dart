import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/features/posts/waste/data/models/create_waste_request_model.dart';
import 'package:treasureflow/features/posts/waste/domain/entities/my_offer.dart';
import 'package:treasureflow/features/posts/waste/domain/entities/offer_summary.dart';
import 'package:treasureflow/features/posts/waste/domain/entities/waste_availability.dart';
import 'package:treasureflow/features/posts/waste/domain/entities/waste_post_detail.dart';

class WastePostRemoteDatasource {
  final ApiClient _apiClient;

  const WastePostRemoteDatasource(this._apiClient);

  Future<String> create(CreateWasteRequestModel model) async {
    final response = await _apiClient.post(
      '/posts/waste',
      body: model.toJson(),
    );
    return response['id'] as String;
  }

  Future<void> acceptOffer({
    required String postId,
    required String offerId,
  }) async {
    await _apiClient.patch(
      '/posts/waste/$postId/offers/$offerId/accept',
      body: {},
    );
  }

  Future<String> createOffer({
    required String postId,
    required double pricePerUnit,
    required String unit,
  }) async {
    final response = await _apiClient.post(
      '/posts/waste/$postId/offers',
      body: {'pricePerUnit': pricePerUnit, 'unit': unit},
    );
    return response['offerId'] as String;
  }

  Future<WastePostDetail> getDetail(String id) async {
    final response = await _apiClient.get('/posts/$id');

    return WastePostDetail(
      id: response['id'] as String,
      title: response['title'] as String,
      description: response['description'] as String,
      photoUrls: (response['photoUrls'] as List).cast<String>(),
      publishedAt: response['publishedAt'] as String,
      status: response['status'] as String,
      materialTypeName: response['materialTypeName'] as String,
      deliveryMode: response['deliveryMode'] as String,
      schedules: (response['schedules'] as List)
          .map((s) => WasteAvailability(
                dayOfWeek: s['dayOfWeek'] as int,
                startTime: s['startTime'] as String,
                endTime: s['endTime'] as String,
              ))
          .toList(),
      offers: (response['offers'] as List)
          .map((o) => OfferSummary(
                offerId: o['offerId'] as String,
                establishmentName: o['establishmentName'] as String,
                pricePerUnit: (o['pricePerUnit'] as num).toDouble(),
                unit: o['unit'] as String,
                status: o['status'] as String,
                distance: o['distance'] as String,
              ))
          .toList(),
      myOffer: response['myOffer'] != null
          ? MyOffer(
              offerId: response['myOffer']['offerId'] as String,
              pricePerUnit: (response['myOffer']['pricePerUnit'] as num).toDouble(),
              unit: response['myOffer']['unit'] as String,
              status: response['myOffer']['status'] as String,
            )
          : null,
      viewsCount: response['viewsCount'] as int,
      distance: response['distance'] as String?,
    );
  }
}
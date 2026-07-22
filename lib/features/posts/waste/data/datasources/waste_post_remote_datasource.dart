import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/features/posts/waste/data/models/create_waste_request_model.dart';
import 'package:treasureflow/features/posts/waste/domain/entities/available_slot.dart';
import 'package:treasureflow/features/posts/waste/domain/entities/my_offer.dart';
import 'package:treasureflow/features/posts/waste/domain/entities/offer_summary.dart';
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

  Future<void> rejectOffer({
    required String postId,
    required String offerId,
  }) async {
    await _apiClient.patch(
      '/posts/waste/$postId/offers/$offerId/reject',
      body: {},
    );
  }

  Future<String> createOffer({
    required String postId,
    required double pricePerUnit,
    required String unit,
    required String proposedPickupDate,
    required String proposedPickupStart,
    required String proposedPickupEnd,
  }) async {
    final response = await _apiClient.post(
      '/posts/waste/$postId/offers',
      body: {
        'pricePerUnit': pricePerUnit,
        'unit': unit,
        'proposedPickupDate': proposedPickupDate,
        'proposedPickupStart': proposedPickupStart,
        'proposedPickupEnd': proposedPickupEnd,
      },
    );
    return response['offerId'] as String;
  }

  Future<List<AvailableSlot>> getAvailableSlots(String establishmentId) async {
    final now = DateTime.now();
    final from =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';

    final response = await _apiClient.getList(
      '/establishments/$establishmentId/available-slots?from=$from&days=14',
    );

    return response
        .map(
          (s) => AvailableSlot(
            date: s['date'] as String,
            dayLabel: s['dayLabel'] as String,
            start: s['start'] as String,
            end: s['end'] as String,
            slotsUsed: s['slotsUsed'] as int,
            maxSlots: s['maxSlots'] as int,
          ),
        )
        .toList();
  }

  Future<void> updatePost({
    required String postId,
    required String description,
    required double latitude,
    required double longitude,
    required String addressText,
    required List<String> photoUrls,
    required String materialTypeId,
    required String deliveryMode,
  }) async {
    await _apiClient.put(
      '/posts/waste/$postId',
      body: {
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'addressText': addressText,
        'photoUrls': photoUrls,
        'materialTypeId': materialTypeId,
        'deliveryMode': deliveryMode,
      },
    );
  }

  Future<void> deletePost(String postId) async {
    await _apiClient.delete('/posts/waste/$postId');
  }

  Future<WastePostDetail> getDetail(String id) async {
    final response = await _apiClient.get('/posts/$id');

    return WastePostDetail(
      id: response['id'] as String,
      title: response['title'] as String,
      citizenName: response['citizenName'] as String? ?? '',
      citizenProfilePictureUrl:
          response['citizenProfilePictureUrl'] as String? ?? '',
      description: response['description'] as String,
      photoUrls: (response['photoUrls'] as List).cast<String>(),
      publishedAt: response['publishedAt'] as String,
      status: response['status'] as String,
      materialTypeName: response['materialTypeName'] as String,
      materialTypeId: response['materialTypeId'] as String?,
      deliveryMode: response['deliveryMode'] as String,
      addressText: response['addressText'] as String?,
      latitude: response['latitude'] != null
          ? (response['latitude'] as num).toDouble()
          : null,
      longitude: response['longitude'] != null
          ? (response['longitude'] as num).toDouble()
          : null,
      offers: (response['offers'] as List)
          .map(
            (o) => OfferSummary(
              offerId: o['offerId'] as String,
              establishmentName: o['establishmentName'] as String,
              pricePerUnit: (o['pricePerUnit'] as num).toDouble(),
              unit: o['unit'] as String,
              status: o['status'] as String,
              distance: o['distance'] as String,
              proposedPickupDate: o['proposedPickupDate'] as String? ?? '',
              proposedPickupStart: o['proposedPickupStart'] as String? ?? '',
              proposedPickupEnd: o['proposedPickupEnd'] as String? ?? '',
            ),
          )
          .toList(),
      myOffer: response['myOffer'] != null
          ? MyOffer(
              offerId: response['myOffer']['offerId'] as String,
              pricePerUnit: (response['myOffer']['pricePerUnit'] as num)
                  .toDouble(),
              unit: response['myOffer']['unit'] as String,
              status: response['myOffer']['status'] as String,
              proposedPickupDate:
                  response['myOffer']['proposedPickupDate'] as String? ?? '',
              proposedPickupStart:
                  response['myOffer']['proposedPickupStart'] as String? ?? '',
              proposedPickupEnd:
                  response['myOffer']['proposedPickupEnd'] as String? ?? '',
            )
          : null,
      viewsCount: response['viewsCount'] as int,
      distance: response['distance'] as String?,
    );
  }
}

import 'package:treasureflow/features/posts/waste/data/datasources/waste_post_remote_datasource.dart';
import 'package:treasureflow/features/posts/waste/data/models/create_waste_request_model.dart';
import 'package:treasureflow/features/posts/waste/domain/entities/available_slot.dart';
import 'package:treasureflow/features/posts/waste/domain/entities/waste_post_detail.dart';
import 'package:treasureflow/features/posts/waste/domain/repositories/waste_post_repository.dart';

class WastePostRepositoryImpl implements WastePostRepository {
  final WastePostRemoteDatasource _datasource;

  const WastePostRepositoryImpl(this._datasource);

  @override
  Future<String> create({
    required String description,
    required double latitude,
    required double longitude,
    required String addressText,
    required List<String> photoUrls,
    required String materialTypeId,
    required String deliveryMode,
  }) {
    final model = CreateWasteRequestModel(
      description: description,
      latitude: latitude,
      longitude: longitude,
      addressText: addressText,
      photoUrls: photoUrls,
      materialTypeId: materialTypeId,
      deliveryMode: deliveryMode,
    );
    return _datasource.create(model);
  }

  @override
  Future<WastePostDetail> getDetail(String id) {
    return _datasource.getDetail(id);
  }

  @override
  Future<List<AvailableSlot>> getAvailableSlots(String establishmentId) {
    return _datasource.getAvailableSlots(establishmentId);
  }

  @override
  Future<void> acceptOffer({
    required String postId,
    required String offerId,
  }) {
    return _datasource.acceptOffer(postId: postId, offerId: offerId);
  }

  @override
  Future<void> rejectOffer({
    required String postId,
    required String offerId,
  }) {
    return _datasource.rejectOffer(postId: postId, offerId: offerId);
  }

  @override
  Future<void> deletePost(String postId) {
    return _datasource.deletePost(postId);
  }

  @override
  Future<String> createOffer({
    required String postId,
    required double pricePerUnit,
    required String unit,
    required String proposedPickupDate,
    required String proposedPickupStart,
    required String proposedPickupEnd,
  }) {
    return _datasource.createOffer(
      postId: postId,
      pricePerUnit: pricePerUnit,
      unit: unit,
      proposedPickupDate: proposedPickupDate,
      proposedPickupStart: proposedPickupStart,
      proposedPickupEnd: proposedPickupEnd,
    );
  }
}

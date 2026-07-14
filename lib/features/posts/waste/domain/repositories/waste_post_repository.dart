import 'package:treasureflow/features/posts/waste/domain/entities/available_slot.dart';
import 'package:treasureflow/features/posts/waste/domain/entities/waste_post_detail.dart';

abstract class WastePostRepository {
  Future<String> create({
    required String description,
    required double latitude,
    required double longitude,
    required String addressText,
    required List<String> photoUrls,
    required String materialTypeId,
    required String deliveryMode,
  });

  Future<WastePostDetail> getDetail(String id);

  Future<List<AvailableSlot>> getAvailableSlots(String establishmentId);

  Future<String> createOffer({
    required String postId,
    required double pricePerUnit,
    required String unit,
    required String proposedPickupDate,
    required String proposedPickupStart,
    required String proposedPickupEnd,
  });

  Future<void> acceptOffer({
    required String postId,
    required String offerId,
  });

  Future<void> rejectOffer({
    required String postId,
    required String offerId,
  });

  Future<void> deletePost(String postId);
}

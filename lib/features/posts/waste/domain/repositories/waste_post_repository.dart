import 'package:treasureflow/features/posts/waste/domain/entities/waste_availability.dart';
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
    required List<WasteAvailability> schedules,
  });

  Future<WastePostDetail> getDetail(String id);

  Future<String> createOffer({
    required String postId,
    required double pricePerUnit,
    required String unit,
  });

  Future<void> acceptOffer({
    required String postId,
    required String offerId,
  });
}
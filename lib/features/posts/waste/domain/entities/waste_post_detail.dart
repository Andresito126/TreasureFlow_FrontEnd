import 'package:treasureflow/features/posts/waste/domain/entities/offer_summary.dart';
import 'package:treasureflow/features/posts/waste/domain/entities/waste_availability.dart';

class WastePostDetail {
  final String id;
  final String title;
  final String description;
  final List<String> photoUrls;
  final String publishedAt;
  final String status;
  final String materialTypeName;
  final String deliveryMode;
  final List<WasteAvailability> schedules;
  final List<OfferSummary> offers;
  final int viewsCount;
  final String? distance;

  const WastePostDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.photoUrls,
    required this.publishedAt,
    required this.status,
    required this.materialTypeName,
    required this.deliveryMode,
    required this.schedules,
    required this.offers,
    required this.viewsCount,
    this.distance,
  });
}

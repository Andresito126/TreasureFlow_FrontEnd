import 'package:treasureflow/features/posts/waste/domain/entities/my_offer.dart';
import 'package:treasureflow/features/posts/waste/domain/entities/offer_summary.dart';
import 'package:treasureflow/features/posts/waste/domain/entities/viewer_summary.dart';

class WastePostDetail {
  final String id;
  final String title;
  final String citizenName;
  final String citizenProfilePictureUrl;
  final bool citizenIsPremium;
  final String description;
  final List<String> photoUrls;
  final String publishedAt;
  final String status;
  final String materialTypeName;
  final String? materialTypeId;
  final String deliveryMode;
  final String? addressText;
  final double? latitude;
  final double? longitude;
  final List<OfferSummary> offers;
  final MyOffer? myOffer;
  final int viewsCount;
  final String? distance;
  final List<ViewerSummary>? viewers;

  const WastePostDetail({
    required this.id,
    required this.title,
    required this.citizenName,
    required this.citizenProfilePictureUrl,
    required this.citizenIsPremium,
    required this.description,
    required this.photoUrls,
    required this.publishedAt,
    required this.status,
    required this.materialTypeName,
    this.materialTypeId,
    required this.deliveryMode,
    this.addressText,
    this.latitude,
    this.longitude,
    required this.offers,
    this.myOffer,
    required this.viewsCount,
    this.distance,
    this.viewers,
  });
}

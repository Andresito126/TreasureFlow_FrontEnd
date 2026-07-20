import 'package:treasureflow/features/collections/local/domain/entities/collection.dart';
import 'package:treasureflow/features/collections/local/domain/entities/collection_offer_info.dart';
import 'package:treasureflow/features/collections/local/domain/entities/payment.dart';

class CollectionDetail {
  final Collection collection;
  final Payment? payment;
  final CollectionOfferInfo offer;

  const CollectionDetail({
    required this.collection,
    required this.offer,
    this.payment,
  });

  factory CollectionDetail.fromJson(Map<String, dynamic> json) {
    return CollectionDetail(
      collection:
          Collection.fromJson(json['collection'] as Map<String, dynamic>),
      payment: json['payment'] != null
          ? Payment.fromJson(json['payment'] as Map<String, dynamic>)
          : null,
      offer:
          CollectionOfferInfo.fromJson(json['offer'] as Map<String, dynamic>),
    );
  }
}

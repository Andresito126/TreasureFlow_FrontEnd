import 'package:treasureflow/features/collections/citizen/domain/entities/collection.dart';
import 'package:treasureflow/features/collections/citizen/domain/entities/collection_offer_info.dart';

class CollectionListItem {
  final Collection collection;
  final CollectionOfferInfo? offer;

  const CollectionListItem({required this.collection, this.offer});

  factory CollectionListItem.fromJson(Map<String, dynamic> json) {
    return CollectionListItem(
      collection: Collection.fromJson(json),
      offer: json['offer'] != null
          ? CollectionOfferInfo.fromJson(json['offer'] as Map<String, dynamic>)
          : null,
    );
  }
}

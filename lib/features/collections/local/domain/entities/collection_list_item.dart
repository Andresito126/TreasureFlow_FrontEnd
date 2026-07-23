import 'package:treasureflow/features/collections/local/domain/entities/collection.dart';
import 'package:treasureflow/features/collections/local/domain/entities/collection_offer_info.dart';

/// Item de `GET /collections`: la collection + los datos de la oferta embebidos.
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

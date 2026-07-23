class NearbyEstablishment {
  final String id;
  final String storeName;
  final String? photoUrl;
  final String distance;
  final double averageRating;
  final List<String> materials;
  final bool isOpen;
  final bool isPremium;

  const NearbyEstablishment({
    required this.id,
    required this.storeName,
    this.photoUrl,
    required this.distance,
    required this.averageRating,
    required this.materials,
    required this.isOpen,
    required this.isPremium,
  });
}

class NearbyItem {
  final String id;
  final String? mainPhotoUrl;
  final String description;
  final String distance;
  final String publishedAt;

  const NearbyItem({
    required this.id,
    this.mainPhotoUrl,
    required this.description,
    required this.distance,
    required this.publishedAt,
  });
}

class ReceivedOffer {
  final String offerId;
  final String publicationId;
  final String? publicationPhotoUrl;
  final String establishmentName;
  final double pricePerUnit;
  final String unit;
  final String offeredAt;

  const ReceivedOffer({
    required this.offerId,
    required this.publicationId,
    this.publicationPhotoUrl,
    required this.establishmentName,
    required this.pricePerUnit,
    required this.unit,
    required this.offeredAt,
  });
}

class CitizenHome {
  final String fullName;
  final String? profilePictureUrl;
  final bool isPremium;
  final double monthlyEarnings;
  final int totalPublications;
  final int itemsObtained;
  final List<NearbyEstablishment> nearbyEstablishments;
  final List<NearbyItem> nearbyItems;
  final List<ReceivedOffer> receivedOffers;

  const CitizenHome({
    required this.fullName,
    this.profilePictureUrl,
    required this.isPremium,
    required this.monthlyEarnings,
    required this.totalPublications,
    required this.itemsObtained,
    required this.nearbyEstablishments,
    required this.nearbyItems,
    required this.receivedOffers,
  });
}

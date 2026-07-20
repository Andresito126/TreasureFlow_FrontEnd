class CollectionOfferInfo {
  final String offerId;
  final String citizenId;
  final String establishmentId;
  final String wastePublicationId;
  final double pricePerUnit;
  final String unit;
  final String? wastePublicationTitle;
  final String? wastePublicationPhotoUrl;
  final String? citizenName;
  final String? establishmentName;

  const CollectionOfferInfo({
    required this.offerId,
    required this.citizenId,
    required this.establishmentId,
    required this.wastePublicationId,
    required this.pricePerUnit,
    required this.unit,
    this.wastePublicationTitle,
    this.wastePublicationPhotoUrl,
    this.citizenName,
    this.establishmentName,
  });

  factory CollectionOfferInfo.fromJson(Map<String, dynamic> json) {
    return CollectionOfferInfo(
      offerId: json['offerId'] as String,
      citizenId: json['citizenId'] as String,
      establishmentId: json['establishmentId'] as String,
      wastePublicationId: json['wastePublicationId'] as String,
      pricePerUnit: (json['pricePerUnit'] as num?)?.toDouble() ?? 0,
      unit: json['unit'] as String? ?? 'kg',
      wastePublicationTitle: json['wastePublicationTitle'] as String?,
      wastePublicationPhotoUrl: json['wastePublicationPhotoUrl'] as String?,
      citizenName: json['citizenName'] as String?,
      establishmentName: json['establishmentName'] as String?,
    );
  }
}

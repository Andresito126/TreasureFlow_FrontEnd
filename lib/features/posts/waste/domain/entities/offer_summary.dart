class OfferSummary {
  final String offerId;
  final String establishmentName;
  final double pricePerUnit;
  final String unit;
  final String status;
  final String distance;

  const OfferSummary({
    required this.offerId,
    required this.establishmentName,
    required this.pricePerUnit,
    required this.unit,
    required this.status,
    required this.distance,
  });
}

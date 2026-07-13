import 'package:treasureflow/shared/utils/pickup_label_formatter.dart';

class OfferSummary {
  final String offerId;
  final String establishmentName;
  final double pricePerUnit;
  final String unit;
  final String status;
  final String distance;
  final String proposedPickupDate;
  final String proposedPickupStart;
  final String proposedPickupEnd;

  const OfferSummary({
    required this.offerId,
    required this.establishmentName,
    required this.pricePerUnit,
    required this.unit,
    required this.status,
    required this.distance,
    required this.proposedPickupDate,
    required this.proposedPickupStart,
    required this.proposedPickupEnd,
  });

  String get pickupLabel => formatPickupLabel(
    proposedPickupDate,
    proposedPickupStart,
    proposedPickupEnd,
  );
}

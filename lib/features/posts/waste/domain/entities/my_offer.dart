import 'package:treasureflow/shared/utils/pickup_label_formatter.dart';

class MyOffer {
  final String offerId;
  final double pricePerUnit;
  final String unit;
  final String status;
  final String proposedPickupDate;
  final String proposedPickupStart;
  final String proposedPickupEnd;

  const MyOffer({
    required this.offerId,
    required this.pricePerUnit,
    required this.unit,
    required this.status,
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

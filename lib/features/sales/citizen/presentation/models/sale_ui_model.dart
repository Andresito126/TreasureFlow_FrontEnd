import 'package:treasureflow/features/sales/citizen/presentation/ui_states/sale_status.dart';
// MOCKKKKKKKKKKKKKKKKKKKKKKKKK
class SaleUiModel {
  final String id;
  final String wasteTitle;
  final String materialTypeName;
  final String? photoUrl;
  final String establishmentName;
  final double establishmentRating;
  final String establishmentDistance;
  final String addressText;
  final String deliveryMode; 
  final double pricePerUnit;
  final String unit;
  final double estimatedQuantity;
  final double? finalWeight;
  final SaleStatus status;
  final String dateLabel;

  const SaleUiModel({
    required this.id,
    required this.wasteTitle,
    required this.materialTypeName,
    this.photoUrl,
    required this.establishmentName,
    required this.establishmentRating,
    required this.establishmentDistance,
    required this.addressText,
    required this.deliveryMode,
    required this.pricePerUnit,
    required this.unit,
    required this.estimatedQuantity,
    this.finalWeight,
    required this.status,
    required this.dateLabel,
  });

  double get estimatedAmount => pricePerUnit * estimatedQuantity;
  double? get finalAmount =>
      finalWeight == null ? null : pricePerUnit * finalWeight!;

  SaleUiModel copyWith({SaleStatus? status, double? finalWeight}) {
    return SaleUiModel(
      id: id,
      wasteTitle: wasteTitle,
      materialTypeName: materialTypeName,
      photoUrl: photoUrl,
      establishmentName: establishmentName,
      establishmentRating: establishmentRating,
      establishmentDistance: establishmentDistance,
      addressText: addressText,
      deliveryMode: deliveryMode,
      pricePerUnit: pricePerUnit,
      unit: unit,
      estimatedQuantity: estimatedQuantity,
      finalWeight: finalWeight ?? this.finalWeight,
      status: status ?? this.status,
      dateLabel: dateLabel,
    );
  }
}


final List<SaleUiModel> mockSales = [
  const SaleUiModel(
    id: 'sale-001',
    wasteTitle: '50 botellas PET',
    materialTypeName: 'Plástico',
    establishmentName: 'EcoPoint Centro',
    establishmentRating: 4.8,
    establishmentDistance: 'a 1.2 km',
    addressText: 'Av. Central #245, Tuxtla Gutiérrez, Chiapas',
    deliveryMode: 'drop_off',
    pricePerUnit: 8.0,
    unit: 'kg',
    estimatedQuantity: 10,
    status: SaleStatus.accepted,
    dateLabel: 'Dom 22 jun · 11:00 hrs',
  ),
  const SaleUiModel(
    id: 'sale-002',
    wasteTitle: 'Latas de aluminio',
    materialTypeName: 'Aluminio',
    establishmentName: 'Green Hub',
    establishmentRating: 4.5,
    establishmentDistance: 'a 2.4 km',
    addressText: 'Calle 5a Norte #120, Tuxtla Gutiérrez, Chiapas',
    deliveryMode: 'home_delivery',
    pricePerUnit: 22.0,
    unit: 'kg',
    estimatedQuantity: 5,
    finalWeight: 4.2,
    status: SaleStatus.amountReview,
    dateLabel: 'Lun 23 jun · 16:30 hrs',
  ),
  const SaleUiModel(
    id: 'sale-003',
    wasteTitle: 'Cartón y papel',
    materialTypeName: 'Papel/Cartón',
    establishmentName: 'ReciclaYa Norte',
    establishmentRating: 4.2,
    establishmentDistance: 'a 3.1 km',
    addressText: 'Blvd. Belisario Domínguez #890, Tuxtla Gutiérrez, Chiapas',
    deliveryMode: 'drop_off',
    pricePerUnit: 2.5,
    unit: 'kg',
    estimatedQuantity: 12,
    finalWeight: 12.4,
    status: SaleStatus.paymentPending,
    dateLabel: 'Mar 24 jun · 09:00 hrs',
  ),
];

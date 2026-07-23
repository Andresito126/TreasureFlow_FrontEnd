import 'package:treasureflow/features/sales/local/presentation/ui_states/purchase_status.dart';

//MOCK
const bool mockLocalHasVehicle = true;

class PurchaseUiModel {
  final String id;
  final String wasteTitle;
  final String materialTypeName;
  final String citizenName;
  final String addressText;
  final double latitude;
  final double longitude;
  final double pricePerUnit;
  final String unit;
  final double estimatedQuantity;
  final double? finalWeight;

  final double? manualFinalAmount;
  final PurchaseStatus status;
  final String dateLabel;
  final bool isToday;

  const PurchaseUiModel({
    required this.id,
    required this.wasteTitle,
    required this.materialTypeName,
    required this.citizenName,
    required this.addressText,
    required this.latitude,
    required this.longitude,
    required this.pricePerUnit,
    required this.unit,
    required this.estimatedQuantity,
    this.finalWeight,
    this.manualFinalAmount,
    required this.status,
    required this.dateLabel,
    required this.isToday,
  });

  double get estimatedAmount => pricePerUnit * estimatedQuantity;
  double? get finalAmount =>
      manualFinalAmount ??
      (finalWeight == null ? null : pricePerUnit * finalWeight!);

  PurchaseUiModel copyWith({
    PurchaseStatus? status,
    double? finalWeight,
    double? manualFinalAmount,
    String? dateLabel,
    bool? isToday,
  }) {
    return PurchaseUiModel(
      id: id,
      wasteTitle: wasteTitle,
      materialTypeName: materialTypeName,
      citizenName: citizenName,
      addressText: addressText,
      latitude: latitude,
      longitude: longitude,
      pricePerUnit: pricePerUnit,
      unit: unit,
      estimatedQuantity: estimatedQuantity,
      finalWeight: finalWeight ?? this.finalWeight,
      manualFinalAmount: manualFinalAmount ?? this.manualFinalAmount,
      status: status ?? this.status,
      dateLabel: dateLabel ?? this.dateLabel,
      isToday: isToday ?? this.isToday,
    );
  }
}

final List<PurchaseUiModel> mockPurchases = [
  const PurchaseUiModel(
    id: 'purchase-001',
    wasteTitle: '50 botellas PET',
    materialTypeName: 'Plástico',
    citizenName: 'María Fernanda',
    addressText: 'Olivo Sur 503, Patria Nueva, Tuxtla Gutiérrez',
    latitude: 16.7569,
    longitude: -93.1292,
    pricePerUnit: 8.0,
    unit: 'kg',
    estimatedQuantity: 10,
    status: PurchaseStatus.accepted,
    dateLabel: 'Hoy',
    isToday: true,
  ),
  const PurchaseUiModel(
    id: 'purchase-002',
    wasteTitle: 'Latas de aluminio',
    materialTypeName: 'Aluminio',
    citizenName: 'Carlos Pérez',
    addressText: 'Calle 5a Norte #120, Centro, Tuxtla Gutiérrez',
    latitude: 16.7539,
    longitude: -93.1187,
    pricePerUnit: 22.0,
    unit: 'kg',
    estimatedQuantity: 5,
    status: PurchaseStatus.accepted,
    dateLabel: 'Hoy',
    isToday: true,
  ),
  const PurchaseUiModel(
    id: 'purchase-003',
    wasteTitle: 'Cartón y papel',
    materialTypeName: 'Papel/Cartón',
    citizenName: 'Ana López',
    addressText: 'Blvd. Belisario Domínguez #890, Tuxtla Gutiérrez',
    latitude: 16.7625,
    longitude: -93.1441,
    pricePerUnit: 2.5,
    unit: 'kg',
    estimatedQuantity: 12,
    finalWeight: 12.4,
    status: PurchaseStatus.paymentPending,
    dateLabel: 'Hoy',
    isToday: true,
  ),
  const PurchaseUiModel(
    id: 'purchase-004',
    wasteTitle: 'Botellas de vidrio',
    materialTypeName: 'Vidrio',
    citizenName: 'Jorge Ramírez',
    addressText: 'Av. Central Poniente #445, Tuxtla Gutiérrez',
    latitude: 16.7530,
    longitude: -93.1330,
    pricePerUnit: 1.8,
    unit: 'kg',
    estimatedQuantity: 20,
    status: PurchaseStatus.accepted,
    dateLabel: 'Sáb 12 jul',
    isToday: false,
  ),
  const PurchaseUiModel(
    id: 'purchase-005',
    wasteTitle: 'Aceite usado de cocina',
    materialTypeName: 'Aceite',
    citizenName: 'Lucía Hernández',
    addressText: '2a Oriente Sur #310, San Roque, Tuxtla Gutiérrez',
    latitude: 16.7502,
    longitude: -93.1145,
    pricePerUnit: 6.0,
    unit: 'litro',
    estimatedQuantity: 8,
    status: PurchaseStatus.accepted,
    dateLabel: 'Dom 13 jul',
    isToday: false,
  ),
];

enum CollectionStatus {
  pendingDelivery,
  pendingWeighing,
  pendingConfirmation,
  pendingPayment,
  completed,
  cancelledByEstablishment,
  cancelledByCitizen,
  unknown;

  static CollectionStatus fromApi(String? raw) => switch (raw) {
        'pending_delivery' => pendingDelivery,
        'pending_weighing' => pendingWeighing,
        'pending_confirmation' => pendingConfirmation,
        'pending_payment' => pendingPayment,
        'completed' => completed,
        'cancelled_by_establishment' => cancelledByEstablishment,
        'cancelled_by_citizen' => cancelledByCitizen,
        _ => unknown,
      };

  /// Paso del stepper (1..3): Pesaje / Confirmación / Pago
  int get stepNumber => switch (this) {
        pendingDelivery || pendingWeighing => 1,
        pendingConfirmation => 2,
        pendingPayment || completed => 3,
        _ => 1,
      };

  bool get isCancelled =>
      this == cancelledByCitizen || this == cancelledByEstablishment;

  bool get isActive => !isCancelled && this != completed && this != unknown;
}

class Collection {
  final String collectionId;
  final String offerId;
  final CollectionStatus status;
  final String statusRaw;
  final double? actualQuantity;
  final double? finalAmount;
  final bool citizenConfirmedAmount;
  final DateTime? amountConfirmationDate;
  final DateTime? receivedAt;
  final DateTime? createdAt;

  const Collection({
    required this.collectionId,
    required this.offerId,
    required this.status,
    this.statusRaw = '',
    this.actualQuantity,
    this.finalAmount,
    this.citizenConfirmedAmount = false,
    this.amountConfirmationDate,
    this.receivedAt,
    this.createdAt,
  });

  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      collectionId: json['collectionId'] as String,
      offerId: json['offerId'] as String,
      status: CollectionStatus.fromApi(json['status'] as String?),
      statusRaw: json['status'] as String? ?? '',
      actualQuantity: (json['actualQuantity'] as num?)?.toDouble(),
      finalAmount: (json['finalAmount'] as num?)?.toDouble(),
      citizenConfirmedAmount: json['citizenConfirmedAmount'] == true,
      amountConfirmationDate: json['amountConfirmationDate'] != null
          ? DateTime.tryParse(json['amountConfirmationDate'].toString())
          : null,
      receivedAt: json['receivedAt'] != null
          ? DateTime.tryParse(json['receivedAt'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}

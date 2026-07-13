enum PurchaseStatus {
  accepted,
  weighing,
  awaitingAcceptance,
  paymentPending,
  completed,
}

extension PurchaseStatusX on PurchaseStatus {
  int get stepNumber => switch (this) {
    PurchaseStatus.accepted => 1,
    PurchaseStatus.weighing || PurchaseStatus.awaitingAcceptance => 3,
    PurchaseStatus.paymentPending || PurchaseStatus.completed => 4,
  };

  String get label => switch (this) {
    PurchaseStatus.accepted => 'Por recolectar',
    PurchaseStatus.weighing => 'Registrar pesaje',
    PurchaseStatus.awaitingAcceptance => 'Esperando al ciudadano',
    PurchaseStatus.paymentPending => 'Pago pendiente',
    PurchaseStatus.completed => 'Completada',
  };
}

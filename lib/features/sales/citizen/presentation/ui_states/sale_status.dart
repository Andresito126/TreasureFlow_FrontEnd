enum SaleStatus {
  accepted,
  awaitingHandoff,
  weighing,
  amountReview,
  paymentPending,
  completed,
}

extension SaleStatusX on SaleStatus {
  int get stepNumber => switch (this) {
        SaleStatus.accepted => 1,
        SaleStatus.awaitingHandoff => 2,
        SaleStatus.weighing || SaleStatus.amountReview => 3,
        SaleStatus.paymentPending || SaleStatus.completed => 4,
      };

  String get label => switch (this) {
        SaleStatus.accepted => 'Oferta aceptada',
        SaleStatus.awaitingHandoff => 'Esperando entrega',
        SaleStatus.weighing => 'Pesando material',
        SaleStatus.amountReview => 'Revisar monto',
        SaleStatus.paymentPending => 'Pago pendiente',
        SaleStatus.completed => 'Completada',
      };
}

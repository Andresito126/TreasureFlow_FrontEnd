import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class CollectionReceiptData {
  final String collectionId;
  final String materialTitle;
  final String counterpartLabel; // "Establecimiento" o "Ciudadano"
  final String counterpartName;
  final double actualQuantity;
  final String unit;
  final double pricePerUnit;
  final double finalAmount;
  final String? paymentMethodLabel;
  final double? treasureflowFee;
  final double netAmount;
  final DateTime date;

  const CollectionReceiptData({
    required this.collectionId,
    required this.materialTitle,
    required this.counterpartLabel,
    required this.counterpartName,
    required this.actualQuantity,
    required this.unit,
    required this.pricePerUnit,
    required this.finalAmount,
    required this.netAmount,
    required this.date,
    this.paymentMethodLabel,
    this.treasureflowFee,
  });
}

Future<void> shareCollectionReceipt(CollectionReceiptData data) async {
  final doc = pw.Document();
  final date =
      '${data.date.day.toString().padLeft(2, '0')}/${data.date.month.toString().padLeft(2, '0')}/${data.date.year} '
      '${data.date.hour.toString().padLeft(2, '0')}:${data.date.minute.toString().padLeft(2, '0')}';

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'TreasureFlow',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#2D7D46'),
                  ),
                ),
                pw.Text(
                  'Comprobante de recolección',
                  style: const pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Folio: ${data.collectionId}',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
            ),
            pw.Text(
              'Fecha: $date',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
            ),
            pw.Divider(height: 28),
            _receiptRow('Material', data.materialTitle),
            _receiptRow(data.counterpartLabel, data.counterpartName),
            _receiptRow(
              'Peso registrado',
              '${data.actualQuantity.toStringAsFixed(2)} ${data.unit}',
            ),
            _receiptRow('Precio por ${data.unit}', _money(data.pricePerUnit)),
            if (data.paymentMethodLabel != null)
              _receiptRow('Método de pago', data.paymentMethodLabel!),
            pw.Divider(height: 24),
            _receiptRow('Monto total', _money(data.finalAmount), bold: true),
            if (data.treasureflowFee != null)
              _receiptRow(
                'Comisión TreasureFlow',
                '- ${_money(data.treasureflowFee!)}',
              ),
            _receiptRow('Monto neto', _money(data.netAmount), bold: true),
            pw.SizedBox(height: 32),
            pw.Center(
              child: pw.Text(
                'Gracias por usar TreasureFlow — juntos reciclamos mejor.',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                ),
              ),
            ),
          ],
        );
      },
    ),
  );

  await Printing.sharePdf(
    bytes: await doc.save(),
    filename: 'comprobante-${data.collectionId}.pdf',
  );
}

pw.Widget _receiptRow(String label, String value, {bool bold = false}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 8),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 11,
            color: bold ? PdfColors.black : PdfColors.grey700,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      ],
    ),
  );
}

String _money(double value) => '\$${value.toStringAsFixed(2)}';

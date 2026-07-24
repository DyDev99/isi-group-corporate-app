class QuotationLine {
  final int quantity;
  final double price;

  const QuotationLine({required this.quantity, required this.price});
}

class Quotation {
  final String id;
  final String? customerId;
  final String? shopName;
  final String? leadDisplayName;
  final List<QuotationLine> lines;
  final DateTime updatedAt;

  const Quotation({
    required this.id,
    this.customerId,
    this.shopName,
    this.leadDisplayName,
    this.lines = const [],
    required this.updatedAt,
  });
}

import 'package:flutter/material.dart';
import 'package:isi_group_corporate_app/features/order/domain/entities/quotation.dart';

class QuotationDetailScreen extends StatelessWidget {
  const QuotationDetailScreen({super.key, required this.quotation});

  static const routeName = '/quotation-detail';

  final Quotation quotation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quotation Detail')),
      body: Center(
        child: Text('Quotation ${quotation.id}'),
      ),
    );
  }
}

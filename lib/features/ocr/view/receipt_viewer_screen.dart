import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:spendly/core/models/receipt.dart';
import 'package:spendly/features/ocr/repository/receipt_repository.dart';
import 'package:spendly/shared/themes/app_theme.dart';
import 'package:intl/intl.dart';

final receiptDetailProvider = FutureProvider.family<Receipt?, String>((ref, id) async {
  final repo = ref.read(receiptRepositoryProvider);
  return await repo.getReceiptById(id);
});

class ReceiptViewerScreen extends ConsumerWidget {
  final String imageUrl;
  final String? merchantName;
  final String? receiptId;

  const ReceiptViewerScreen({
    super.key,
    required this.imageUrl,
    this.merchantName,
    this.receiptId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receiptAsync = receiptId != null ? ref.watch(receiptDetailProvider(receiptId!)) : const AsyncValue.data(null);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          merchantName ?? 'Receipt',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              SharePlus.instance.share(
                ShareParams(
                  text: 'Check out this receipt from ${merchantName ?? 'Spendly'}: $imageUrl',
                  subject: 'Spendly Receipt',
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Image Viewer
          Center(
            child: InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4.0,
              child: Hero(
                tag: imageUrl,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          
          // Details Panel (Draggable)
          if (receiptId != null)
            receiptAsync.when(
              data: (receipt) {
                if (receipt == null) return const SizedBox.shrink();
                return DraggableScrollableSheet(
                  initialChildSize: 0.1,
                  minChildSize: 0.1,
                  maxChildSize: 0.6,
                  builder: (context, scrollController) {
                    return Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'RECEIPT DETAILS',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              letterSpacing: 1.2,
                              color: AppColors.textLight,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: ListView(
                              controller: scrollController,
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              children: [
                                _buildDetailRow(Icons.store, 'Merchant', receipt.merchant ?? 'Unknown'),
                                _buildDetailRow(Icons.calendar_today, 'Date', receipt.date != null ? DateFormat('MMM dd, yyyy').format(receipt.date!) : 'Unknown'),
                                _buildDetailRow(Icons.payments, 'Total', receipt.total != null ? '${(receipt.total! / 100).toStringAsFixed(2)} HTG' : 'N/A'),
                                if (receipt.subtotal != null)
                                  _buildDetailRow(Icons.summarize_outlined, 'Subtotal', '${(receipt.subtotal! / 100).toStringAsFixed(2)} HTG'),
                                if (receipt.tax != null)
                                  _buildDetailRow(Icons.receipt_outlined, 'Tax', '${(receipt.tax! / 100).toStringAsFixed(2)} HTG'),
                                
                                const Divider(height: 32),
                                
                                if (receipt.address != null)
                                  _buildDetailRow(Icons.location_on_outlined, 'Address', receipt.address!),
                                if (receipt.phone != null)
                                  _buildDetailRow(Icons.phone_outlined, 'Phone', receipt.phone!),
                                if (receipt.receiptNumber != null)
                                  _buildDetailRow(Icons.tag, 'Receipt #', receipt.receiptNumber!),
                                
                                if (receipt.items != null && receipt.items!.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  const Text('ITEMS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textLight)),
                                  const SizedBox(height: 8),
                                  ...receipt.items!.map((item) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      children: [
                                        Expanded(child: Text(item.description, style: const TextStyle(fontSize: 13))),
                                        Text('${(item.amount / 100).toStringAsFixed(2)} G', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      ],
                                    ),
                                  )),
                                ],
                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (e, s) => const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppColors.textLight, fontSize: 10, fontWeight: FontWeight.bold)),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  overflow: TextOverflow.visible,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

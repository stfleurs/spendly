import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:spendly/shared/themes/app_theme.dart';
import 'package:spendly/features/ocr/services/ocr_service.dart';
import 'package:spendly/features/ocr/services/receipt_parser.dart';
import 'package:spendly/features/ocr/repository/receipt_repository.dart';
import 'package:spendly/features/ocr/view/receipt_confirmation_screen.dart';
import 'package:spendly/features/auth/repository/auth_repository.dart';
import 'package:spendly/core/models/receipt.dart';
import 'package:uuid/uuid.dart';

class ReceiptScannerScreen extends ConsumerStatefulWidget {
  const ReceiptScannerScreen({super.key});

  @override
  ConsumerState<ReceiptScannerScreen> createState() => _ReceiptScannerScreenState();
}

class _ReceiptScannerScreenState extends ConsumerState<ReceiptScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;
  String _status = '';

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) return;

      setState(() {
        _isProcessing = true;
        _status = 'Compressing image...';
      });

      final compressedFile = await _compressImage(File(image.path));
      if (compressedFile == null) throw Exception('Compression failed');

      setState(() => _status = 'Extracting text...');
      final ocrService = ref.read(ocrServiceProvider);
      final recognizedText = await ocrService.processImage(compressedFile);
      
      final parsed = ReceiptParser.parse(recognizedText);

      setState(() => _status = 'Uploading to secure storage...');
      final userId = ref.read(authRepositoryProvider).currentUser?.uid ?? '';
      final repository = ref.read(receiptRepositoryProvider);
      final imageUrl = await repository.uploadReceiptImage(userId, compressedFile);

      final receipt = Receipt(
        id: const Uuid().v4(),
        userId: userId,
        imageUrl: imageUrl,
        extractedText: recognizedText.text,
        rawLines: parsed.rawLines,
        merchant: parsed.merchant,
        total: parsed.total,
        date: parsed.date,
        confidence: parsed.confidence,
        createdAt: DateTime.now(),
      );

      await repository.saveReceipt(receipt);

      if (!mounted) return;
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ReceiptConfirmationScreen(receipt: receipt),
        ),
      );

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.expense),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<File?> _compressImage(File file) async {
    final dir = await path_provider.getTemporaryDirectory();
    final targetPath = '${dir.absolute.path}/temp_receipt_${DateTime.now().millisecondsSinceEpoch}.jpg';

    return await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70,
      minWidth: 1024,
      minHeight: 1024,
      format: CompressFormat.jpeg,
    ).then((xFile) => xFile != null ? File(xFile.path) : null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Scan Receipt', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: _isProcessing
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppColors.primary),
                  const SizedBox(height: 24),
                  Text(_status, style: const TextStyle(color: AppColors.textLight)),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.receipt_long, size: 64, color: AppColors.primary),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Snap a photo of your receipt',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'We\'ll automatically extract the details for you.',
                    style: TextStyle(color: AppColors.textLight),
                  ),
                  const SizedBox(height: 48),
                  _buildActionButton(
                    icon: Icons.camera_alt,
                    label: 'Take Photo',
                    onPressed: () => _pickImage(ImageSource.camera),
                  ),
                  const SizedBox(height: 16),
                  _buildActionButton(
                    icon: Icons.photo_library,
                    label: 'Choose from Gallery',
                    onPressed: () => _pickImage(ImageSource.gallery),
                    isSecondary: true,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isSecondary = false,
  }) {
    return SizedBox(
      width: 250,
      child: ElevatedButton.icon(
        icon: Icon(icon, color: isSecondary ? AppColors.primary : Colors.white),
        label: Text(label),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSecondary ? Colors.white : AppColors.primary,
          foregroundColor: isSecondary ? AppColors.primary : Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isSecondary ? const BorderSide(color: AppColors.primary) : BorderSide.none,
          ),
          elevation: isSecondary ? 0 : 4,
        ),
      ),
    );
  }
}

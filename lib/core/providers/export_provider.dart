import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/core/services/data_export_service.dart';

final dataExportServiceProvider = Provider((ref) => DataExportService());

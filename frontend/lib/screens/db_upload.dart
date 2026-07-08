import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../widgets/data_drop.dart';
import '../widgets/upload_dataset.dart';
import '../services/upload_services.dart';

class DatasetUploadPage extends StatefulWidget {
  const DatasetUploadPage({super.key});

  @override
  State<DatasetUploadPage> createState() => _DatasetUploadPageState();
}

class _DatasetUploadPageState extends State<DatasetUploadPage> {
  DatasetType _selectedType = DatasetType.customers;

  // Per-dataset state, keyed by DatasetType.
  final Map<DatasetType, PlatformFile?> _selectedFiles = {
    for (final t in DatasetType.values) t: null,
  };
  final Map<DatasetType, UploadStatus> _statuses = {
    for (final t in DatasetType.values) t: UploadStatus.notUploaded,
  };
  final Map<DatasetType, int?> _rowCounts = {
    for (final t in DatasetType.values) t: null,
  };

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      withData: true,
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx'],
    );
    if (result == null) return;

    setState(() {
      _selectedFiles[_selectedType] = result.files.single;
    });
  }

  Future<void> _uploadSelected() async {
    final file = _selectedFiles[_selectedType];
    if (file == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please choose a file first")),
      );
      return;
    }

    setState(() => _statuses[_selectedType] = UploadStatus.uploading);

    final uploadFn = switch (_selectedType) {
      DatasetType.customers => UploadService.uploadCustomers,
      DatasetType.products => UploadService.uploadProducts,
      DatasetType.orders => UploadService.uploadOrders,
      DatasetType.orderItems => UploadService.uploadOrderItems,
    };

    final result = await uploadFn(file);
    if (!mounted) return;

    setState(() {
      _statuses[_selectedType] = result.success
          ? UploadStatus.uploaded
          : UploadStatus.failed;
      // This is the fix: store the row count from the backend response so
      // the table can actually display it instead of staying null forever.
      _rowCounts[_selectedType] = result.rows;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.success
              ? "${_selectedType.label} uploaded successfully"
              : (result.error ?? "${_selectedType.label} upload failed"),
        ),
        backgroundColor: result.success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tableRows = DatasetType.values
        .map(
          (t) => DatasetRowData(
            type: t,
            fileName: _selectedFiles[t]?.name ?? "",
            status: _statuses[t]!,
            rows: _rowCounts[t],
          ),
        )
        .toList();

    return Padding(
      padding: const EdgeInsets.all(28),
      child: ListView(
        children: [
          const Text(
            "Dataset Upload Page",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Upload Customers and Products first, then Orders, then Order Items — "
            "later files reference the earlier ones.",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13.5),
          ),
          const SizedBox(height: 24),
          DatasetDropzone(
            selected: _selectedType,
            onTypeChanged: (t) => setState(() => _selectedType = t),
            onChooseFile: _pickFile,
            fileName: _selectedFiles[_selectedType]?.name ?? "",
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _uploadSelected,
              icon: const Icon(Icons.cloud_upload),
              label: Text("Upload ${_selectedType.label}"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          UploadedDatasetsTable(rows: tableRows),
        ],
      ),
    );
  }
}

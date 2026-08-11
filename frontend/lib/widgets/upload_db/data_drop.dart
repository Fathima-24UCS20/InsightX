import 'package:flutter/material.dart';

enum DatasetType { customers, products, orders, orderItems }

extension DatasetTypeLabel on DatasetType {
  String get label {
    switch (this) {
      case DatasetType.customers:
        return "Customers";
      case DatasetType.products:
        return "Products";
      case DatasetType.orders:
        return "Orders";
      case DatasetType.orderItems:
        return "Order Items";
    }
  }
}

class DatasetDropzone extends StatefulWidget {
  final DatasetType selected;
  final ValueChanged<DatasetType> onTypeChanged;
  final VoidCallback onChooseFile;
  final String fileName;

  const DatasetDropzone({
    super.key,
    required this.selected,
    required this.onTypeChanged,
    required this.onChooseFile,
    required this.fileName,
  });

  @override
  State<DatasetDropzone> createState() => _DatasetDropzoneState();
}

class _DatasetDropzoneState extends State<DatasetDropzone> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Dataset Upload",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            "Choose a dataset type, then upload a CSV or XLSX file.",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 20),

          // Dataset type selector
          Wrap(
            spacing: 10,
            children: DatasetType.values.map((type) {
              final isSelected = type == widget.selected;
              return ChoiceChip(
                label: Text(type.label),
                selected: isSelected,
                onSelected: (_) => widget.onTypeChanged(type),
                selectedColor: Colors.deepPurple,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
                backgroundColor: Colors.grey.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide.none,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 22),

          // Drop / browse zone
          MouseRegion(
            onEnter: (_) => setState(() => _hovering = true),
            onExit: (_) => setState(() => _hovering = false),
            child: GestureDetector(
              onTap: widget.onChooseFile,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                decoration: BoxDecoration(
                  color: _hovering ? Colors.deepPurple.shade50 : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _hovering ? Colors.deepPurple : Colors.grey.shade300,
                    width: 1.5,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(Icons.cloud_upload_outlined,
                        size: 42, color: Colors.deepPurple.shade300),
                    const SizedBox(height: 12),
                    Text(
                      widget.fileName.isEmpty
                          ? "Drag & drop your file here"
                          : widget.fileName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "or click to browse — CSV, XLSX (max 25MB)",
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
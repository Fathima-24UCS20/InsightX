import 'package:flutter/material.dart';
import 'data_drop.dart';

enum UploadStatus { notUploaded, uploading, uploaded, failed }

class DatasetRowData {
  final DatasetType type;
  final String fileName;
  final UploadStatus status;
  final int? rows;

  const DatasetRowData({
    required this.type,
    required this.fileName,
    required this.status,
    this.rows,
  });
}

class UploadedDatasetsTable extends StatelessWidget {
  final List<DatasetRowData> rows;

  const UploadedDatasetsTable({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
            "Uploaded Datasets",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(flex: 3, child: _HeaderCell("Dataset")),
              Expanded(flex: 4, child: _HeaderCell("File")),
              Expanded(flex: 2, child: _HeaderCell("Rows")),
              Expanded(flex: 2, child: _HeaderCell("Status")),
            ],
          ),
          const Divider(height: 24),
          for (final row in rows) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      row.type.label,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text(
                      row.fileName.isEmpty ? "—" : row.fileName,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      row.rows?.toString() ?? "—",
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                    ),
                  ),
                  Expanded(flex: 2, child: _StatusBadge(status: row.status)),
                ],
              ),
            ),
            if (row != rows.last) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.grey.shade500,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final UploadStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    late Color bg;
    late Color fg;
    late String label;

    switch (status) {
      case UploadStatus.uploaded:
        bg = const Color(0xFFE3F7EA);
        fg = const Color(0xFF1E9E5A);
        label = "Uploaded";
        break;
      case UploadStatus.uploading:
        bg = const Color(0xFFFFF6DE);
        fg = const Color(0xFFC8940A);
        label = "Uploading…";
        break;
      case UploadStatus.failed:
        bg = const Color(0xFFFDE7E7);
        fg = const Color(0xFFD64545);
        label = "Failed";
        break;
      case UploadStatus.notUploaded:
        bg = const Color(0xFFF1F2F6);
        fg = const Color(0xFF888C99);
        label = "Not uploaded";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
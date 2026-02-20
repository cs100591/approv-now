import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/utils/app_logger.dart';
import '../request/request_models.dart';
import '../workspace/workspace_models.dart';

/// PdfService - Handles PDF generation for approval requests
class PdfService {
  /// Generate PDF for approval request
  Future<Uint8List> generatePdf({
    required ApprovalRequest request,
    required Workspace workspace,
    String? hash,
    bool includeWatermark = false,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header with workspace info
              _buildHeader(workspace),
              pw.SizedBox(height: 20),

              // Request title
              pw.Text(
                request.templateName,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),

              // Request metadata
              pw.Text('Request ID: ${request.id}'),
              pw.Text('Revision: ${request.revisionNumber}'),
              pw.Text('Status: ${request.status.name.toUpperCase()}'),
              pw.Text('Submitted by: ${request.submittedByName}'),
              pw.Text('Date: ${_formatDate(request.submittedAt)}'),
              pw.SizedBox(height: 20),

              // Field values
              pw.Text(
                'Form Data',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              ...request.fieldValues.map((field) => _buildFieldRow(field)),

              pw.SizedBox(height: 20),

              // Approval history
              if (request.currentApprovalActions.isNotEmpty) ...[
                pw.Text(
                  'Approval History',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                ...request.currentApprovalActions
                    .map((action) => _buildActionRow(action)),
              ],

              pw.Spacer(),

              // Hash footer
              if (hash != null) ...[
                pw.Divider(),
                pw.Text(
                  'Verification Hash: $hash',
                  style: pw.TextStyle(fontSize: 8),
                ),
              ],

              // Workspace footer
              if (workspace.footerText != null) ...[
                pw.SizedBox(height: 10),
                pw.Text(
                  workspace.footerText!,
                  style: pw.TextStyle(
                      fontSize: 10, fontStyle: pw.FontStyle.italic),
                ),
              ],
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Build header section with workspace branding
  pw.Widget _buildHeader(Workspace workspace) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (workspace.companyName != null)
          pw.Text(
            workspace.companyName!,
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        if (workspace.address != null)
          pw.Text(
            workspace.address!,
            style: pw.TextStyle(fontSize: 10),
          ),
        pw.Divider(),
      ],
    );
  }

  /// Build field value row
  pw.Widget _buildFieldRow(FieldValue field) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 2,
            child: pw.Text(
              '${field.fieldName}:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(
            flex: 3,
            child: pw.Text(_formatValue(field.value)),
          ),
        ],
      ),
    );
  }

  /// Build approval action row
  pw.Widget _buildActionRow(ApprovalAction action) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Row(
        children: [
          pw.Icon(
            action.approved ? pw.IconData(0xe876) : pw.IconData(0xe5c9),
            size: 16,
            color: action.approved ? PdfColors.green : PdfColors.red,
          ),
          pw.SizedBox(width: 10),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  '${action.approverName} - Level ${action.level}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(_formatDate(action.timestamp)),
                if (action.comment != null)
                  pw.Text('Comment: ${action.comment}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Format value for display
  String _formatValue(dynamic value) {
    if (value == null) return 'N/A';
    if (value is bool) return value ? 'Yes' : 'No';
    if (value is DateTime) return _formatDate(value);
    return value.toString();
  }

  /// Save PDF to file
  Future<File> savePdf(Uint8List bytes, String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$filename');
    await file.writeAsBytes(bytes);
    return file;
  }

  /// Share PDF
  Future<void> sharePdf(Uint8List bytes, String filename) async {
    try {
      final file = await savePdf(bytes, filename);
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Approval Request PDF',
        text: 'Please find the approval request attached.',
      );
      AppLogger.info('PDF shared successfully: $filename');
    } catch (e) {
      AppLogger.error('Error sharing PDF', e);
      rethrow;
    }
  }
}

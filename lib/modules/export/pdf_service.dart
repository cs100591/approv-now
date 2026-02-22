import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../../core/utils/app_logger.dart';
import '../request/request_models.dart';
import '../workspace/workspace_models.dart';

// Platform-specific implementation
import 'pdf_service_native.dart' if (dart.library.html) 'pdf_service_web.dart';

// ── Colours ────────────────────────────────────────────────────────────────
const _kPrimary = PdfColor.fromInt(0xFF2563EB); // Blue 600
const _kSecondary = PdfColor.fromInt(0xFF475569); // Slate 600
const _kLight = PdfColor.fromInt(0xFFF1F5F9); // Slate 100
const _kBorder = PdfColor.fromInt(0xFFE2E8F0); // Slate 200

/// PdfService – Generates plan-aware PDFs for approval requests.
///
/// [pdfHeaderMode]:
///   'brand'      → Free plan  : compact "Approv Now" brand watermark
///   'workspace'  → Starter    : workspace name as header
///   'custom'     → Pro        : logo + workspace name + description
class PdfService {
  Future<Uint8List> generatePdf({
    required ApprovalRequest request,
    required Workspace workspace,
    String? hash,
    String pdfHeaderMode = 'brand', // 'brand' | 'workspace' | 'custom'
    bool includeWatermark = false,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (ctx) => _buildHeader(pdfHeaderMode, workspace),
        footer: (ctx) => _buildFooter(
            pdfHeaderMode, workspace, ctx.pageNumber, ctx.pagesCount, hash),
        build: (ctx) => [
          pw.SizedBox(height: 20),
          _buildTitleRow(request),
          pw.SizedBox(height: 20),
          _buildMetaBox(request),
          pw.SizedBox(height: 30),
          _sectionLabel('FORM DATA'),
          pw.SizedBox(height: 10),
          _buildFieldTable(request),
          pw.SizedBox(height: 30),
          if (request.currentApprovalActions.isNotEmpty) ...[
            _sectionLabel('APPROVAL HISTORY'),
            pw.SizedBox(height: 10),
            _buildActionTable(request),
          ],
          if (includeWatermark) _buildWatermark(),
        ],
      ),
    );

    return pdf.save();
  }

  // ── Header variants ────────────────────────────────────────────────────────

  pw.Widget _buildHeader(String mode, Workspace workspace) {
    switch (mode) {
      case 'custom':
        return _buildCustomHeader(workspace);
      case 'workspace':
        return _buildWorkspaceHeader(workspace);
      case 'brand':
      default:
        return _buildBrandHeader();
    }
  }

  /// Free plan – compact brand header (small, subtle)
  pw.Widget _buildBrandHeader() {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _kPrimary, width: 1.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          // Small brand pill
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: pw.BoxDecoration(
              color: _kPrimary,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.Text(
              'APPROV NOW',
              style: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 7,
                fontWeight: pw.FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ),
          pw.Text(
            'Approval Document',
            style: pw.TextStyle(
              fontSize: 9,
              color: _kSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Starter plan – workspace name as header
  pw.Widget _buildWorkspaceHeader(Workspace workspace) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _kPrimary, width: 2)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                workspace.name,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: _kPrimary,
                ),
              ),
              if (workspace.companyName != null)
                pw.Text(
                  workspace.companyName!,
                  style: pw.TextStyle(fontSize: 10, color: _kSecondary),
                ),
            ],
          ),
          if (workspace.address != null)
            pw.Text(
              workspace.address!,
              style: pw.TextStyle(fontSize: 9, color: _kSecondary),
              textAlign: pw.TextAlign.right,
            ),
        ],
      ),
    );
  }

  /// Pro plan – custom header: logo + workspace name + description
  pw.Widget _buildCustomHeader(Workspace workspace) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _kPrimary, width: 2.5)),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          // Logo placeholder (circular with initials if no image)
          pw.Container(
            width: 48,
            height: 48,
            decoration: pw.BoxDecoration(
              color: _kPrimary,
              shape: pw.BoxShape.circle,
            ),
            child: pw.Center(
              child: pw.Text(
                _initials(workspace.name),
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ),
          pw.SizedBox(width: 14),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  workspace.name,
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: _kPrimary,
                  ),
                ),
                if (workspace.description != null &&
                    workspace.description!.isNotEmpty)
                  pw.Text(
                    workspace.description!,
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: _kSecondary,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              if (workspace.companyName != null)
                pw.Text(workspace.companyName!,
                    style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: _kSecondary)),
              if (workspace.address != null)
                pw.Text(workspace.address!,
                    style: pw.TextStyle(fontSize: 9, color: _kSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Footer variants ────────────────────────────────────────────────────────

  pw.Widget _buildFooter(String mode, Workspace workspace, int pageNum,
      int pagesCount, String? hash) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 20),
      padding: const pw.EdgeInsets.only(top: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: _kBorder)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (workspace.footerText != null)
                  pw.Text(workspace.footerText!,
                      style: pw.TextStyle(
                          fontSize: 8,
                          color: _kSecondary,
                          fontStyle: pw.FontStyle.italic)),
                if (hash != null)
                  pw.Text(
                    'Hash: $hash',
                    style: const pw.TextStyle(
                        fontSize: 7, color: PdfColors.grey400),
                  ),
                // Only Free plan shows brand in footer
                if (mode == 'brand')
                  pw.Text(
                    'Generated by Approv Now',
                    style: pw.TextStyle(
                        fontSize: 7,
                        color: _kPrimary,
                        fontStyle: pw.FontStyle.italic),
                  ),
              ],
            ),
          ),
          pw.Text('Page $pageNum of $pagesCount',
              style: pw.TextStyle(fontSize: 9, color: _kSecondary)),
        ],
      ),
    );
  }

  // ── Body sections ──────────────────────────────────────────────────────────

  pw.Widget _buildTitleRow(ApprovalRequest request) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Text(
          request.templateName.toUpperCase(),
          style: pw.TextStyle(
            fontSize: 26,
            fontWeight: pw.FontWeight.bold,
            color: _kPrimary,
            letterSpacing: 1.2,
          ),
        ),
        _buildStatusBadge(request.status),
      ],
    );
  }

  pw.Widget _buildMetaBox(ApprovalRequest request) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: _kLight,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: _kBorder),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          _metaCol('REQUEST ID', _shortId(request.id)),
          _metaCol('REVISION', '${request.revisionNumber}'),
          _metaCol('SUBMITTED BY', request.submittedByName),
          _metaCol('DATE', _fmt(request.submittedAt)),
        ],
      ),
    );
  }

  pw.Widget _buildFieldTable(ApprovalRequest request) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _kBorder),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        children: request.fieldValues.asMap().entries.map((e) {
          final isEven = e.key % 2 == 0;
          return _fieldRow(e.value, isEven ? null : _kLight);
        }).toList(),
      ),
    );
  }

  pw.Widget _buildActionTable(ApprovalRequest request) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _kBorder),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        children: request.currentApprovalActions.asMap().entries.map((e) {
          final isEven = e.key % 2 == 0;
          return _actionRow(e.value, isEven ? null : _kLight);
        }).toList(),
      ),
    );
  }

  pw.Widget _buildWatermark() {
    return pw.Center(
      child: pw.Transform.rotate(
        angle: -0.785,
        child: pw.Text(
          'CONFIDENTIAL',
          style: pw.TextStyle(
            fontSize: 80,
            color: PdfColors.grey200,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ── Micro-widgets ──────────────────────────────────────────────────────────

  pw.Widget _sectionLabel(String text) {
    return pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: 13,
        fontWeight: pw.FontWeight.bold,
        color: _kSecondary,
        letterSpacing: 1.1,
      ),
    );
  }

  pw.Widget _metaCol(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label,
            style: pw.TextStyle(
                fontSize: 7,
                color: _kSecondary,
                fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
      ],
    );
  }

  pw.Widget _buildStatusBadge(RequestStatus status) {
    PdfColor bg;
    switch (status) {
      case RequestStatus.draft:
        bg = PdfColors.grey600;
        break;
      case RequestStatus.pending:
        bg = PdfColors.orange500;
        break;
      case RequestStatus.approved:
        bg = PdfColors.green600;
        break;
      case RequestStatus.rejected:
        bg = PdfColors.red600;
        break;
      case RequestStatus.revised:
        bg = PdfColors.blue500;
        break;
    }

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: pw.BoxDecoration(
        color: bg,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(20)),
      ),
      child: pw.Text(
        status.name.toUpperCase(),
        style: pw.TextStyle(
          color: PdfColors.white,
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  pw.Widget _fieldRow(FieldValue field, PdfColor? bg) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: bg,
        border: pw.Border(bottom: pw.BorderSide(color: _kBorder, width: 0.5)),
      ),
      padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 2,
            child: pw.Text(
              field.fieldName,
              style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: _kSecondary),
            ),
          ),
          pw.Expanded(
            flex: 3,
            child: pw.Text(
              _fmtValue(field.value, field.fieldType),
              style: const pw.TextStyle(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _actionRow(ApprovalAction action, PdfColor? bg) {
    final dot = action.approved ? PdfColors.green600 : PdfColors.red600;

    return pw.Container(
      decoration: pw.BoxDecoration(
        color: bg,
        border: pw.Border(bottom: pw.BorderSide(color: _kBorder, width: 0.5)),
      ),
      padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            margin: const pw.EdgeInsets.only(top: 3, right: 12),
            width: 8,
            height: 8,
            decoration: pw.BoxDecoration(shape: pw.BoxShape.circle, color: dot),
          ),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      action.approverName.toUpperCase(),
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: const PdfColor.fromInt(0xFF334155), // Slate 700
                      ),
                    ),
                    pw.Text(
                      _fmt(action.timestamp),
                      style: const pw.TextStyle(
                          fontSize: 9,
                          color: PdfColor.fromInt(0xFF94A3B8)), // Slate 400
                    ),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Level ${action.level} – ${action.approved ? 'Approved' : 'Rejected'}',
                  style: pw.TextStyle(
                    fontSize: 9,
                    color: dot,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                if (action.comment != null && action.comment!.isNotEmpty) ...[
                  pw.SizedBox(height: 6),
                  pw.Text(
                    '"${action.comment}"',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontStyle: pw.FontStyle.italic,
                      color: const PdfColor.fromInt(0xFF64748B), // Slate 500
                    ),
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Utility ────────────────────────────────────────────────────────────────

  String _fmt(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}  '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  String _fmtValue(dynamic value, [dynamic type]) {
    if (value == null || value.toString().isEmpty || value.toString() == 'null')
      return '-';
    if (value is bool ||
        value.toString() == 'true' ||
        value.toString() == 'false') {
      return value.toString() == 'true' ? 'Yes' : 'No';
    }
    if (value is DateTime) return _fmt(value);
    if (type?.toString().contains('date') == true && value is String) {
      try {
        return _fmt(DateTime.parse(value));
      } catch (_) {}
    }
    return value.toString();
  }

  String _shortId(String id) {
    if (id.length <= 8) return id;
    return '${id.substring(0, 8)}…';
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  // ── Save / Share ───────────────────────────────────────────────────────────

  Future<String?> savePdf(Uint8List bytes, String filename) async {
    try {
      return await savePdfPlatform(bytes, filename);
    } catch (e) {
      AppLogger.error('Failed to save PDF', e);
      return null;
    }
  }

  Future<void> sharePdf(Uint8List bytes, String filename,
      {Rect? sharePositionOrigin}) async {
    if (kIsWeb) {
      try {
        await Share.shareXFiles(
          [XFile.fromData(bytes, name: filename, mimeType: 'application/pdf')],
          subject: 'Approval Request PDF',
          sharePositionOrigin: sharePositionOrigin,
        );
      } catch (e) {
        AppLogger.error('Web share failed', e);
        await savePdf(bytes, filename);
      }
      return;
    }
    try {
      final path = await savePdf(bytes, filename);
      if (path != null) {
        await Share.shareXFiles(
          [XFile(path)],
          subject: 'Approval Request PDF',
          text: 'Please find the approval request attached.',
          sharePositionOrigin: sharePositionOrigin,
        );
      }
    } catch (e) {
      AppLogger.error('Error sharing PDF', e);
      rethrow;
    }
  }
}

import 'package:flutter/foundation.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../request/request_models.dart';
import '../workspace/workspace_models.dart';
import '../template/template_models.dart';
import '../verification/hash_service.dart';
import 'pdf_service.dart';
import 'excel_service.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

class ExportProvider extends ChangeNotifier {
  final PdfService _pdfService;
  final ExcelService _excelService;
  final HashService _hashService;

  ExportState _state = const ExportState();

  ExportProvider({
    required PdfService pdfService,
    required HashService hashService,
    ExcelService? excelService,
  })  : _pdfService = pdfService,
        _excelService = excelService ?? ExcelService(),
        _hashService = hashService;

  ExportState get state => _state;
  bool get isGenerating => _state.isGenerating;
  Uint8List? get pdfBytes => _state.pdfBytes;
  Uint8List? get excelBytes => _state.excelBytes;
  String? get exportedPath => _state.exportedPath;
  String? get error => _state.error;
  String? get lastHash => _state.hash;

  // ── PDF ────────────────────────────────────────────────────────────────────

  /// Generate PDF for approval request.
  /// [pdfHeaderMode] controls which header variant to render:
  ///   - 'brand'   → Free: small "Approv Now" header
  ///   - 'workspace' → Starter: workspace name as header
  ///   - 'custom'  → Pro: logo + name + description
  Future<void> generatePdf({
    required ApprovalRequest request,
    required Workspace workspace,
    String pdfHeaderMode = 'brand', // 'brand' | 'workspace' | 'custom'
    bool includeHash = true,
    bool includeWatermark = true,
  }) async {
    _setGenerating(true);
    _clearError();

    try {
      final hash = includeHash
          ? _hashService.generateHash(
              workspaceId: workspace.id,
              requestId: request.id,
              revisionNumber: request.revisionNumber,
              submittedBy: request.submittedBy,
              approvalActions: request.currentApprovalActions,
              fieldValues: request.fieldValues,
            )
          : null;

      pw.ImageProvider? logoImage;
      if (pdfHeaderMode == 'custom' &&
          workspace.logoUrl != null &&
          workspace.logoUrl!.isNotEmpty) {
        try {
          logoImage = await networkImage(workspace.logoUrl!);
        } catch (e) {
          // Ignore image load error if any and fallback to initials
        }
      }

      final pdfBytes = await _pdfService.generatePdf(
        request: request,
        workspace: workspace,
        hash: hash,
        pdfHeaderMode: pdfHeaderMode,
        includeWatermark: includeWatermark,
        logoImage: logoImage,
      );

      _state = _state.copyWith(pdfBytes: pdfBytes, hash: hash);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setGenerating(false);
    }
  }

  Future<void> exportPdfToFile(String filename) async {
    if (_state.pdfBytes == null) {
      _setError('No PDF generated');
      return;
    }
    _setGenerating(true);
    try {
      final path = await _pdfService.savePdf(_state.pdfBytes!, filename);
      if (path != null) _state = _state.copyWith(exportedPath: path);
    } catch (e) {
      _setError(e.toString());
    }
    _setGenerating(false);
  }

  Future<void> sharePdf(String filename, {Rect? sharePositionOrigin}) async {
    if (_state.pdfBytes == null) {
      _setError('No PDF generated');
      return;
    }
    _setGenerating(true);
    try {
      await _pdfService.sharePdf(_state.pdfBytes!, filename,
          sharePositionOrigin: sharePositionOrigin);
    } catch (e) {
      _setError(e.toString());
    }
    _setGenerating(false);
  }

  // ── Excel ──────────────────────────────────────────────────────────────────

  /// Generate Excel file for approval request.
  Future<void> generateExcel({
    required ApprovalRequest request,
    required Workspace workspace,
    bool includeHash = true,
  }) async {
    _setGenerating(true);
    _clearError();

    try {
      final hash = includeHash
          ? _hashService.generateHash(
              workspaceId: workspace.id,
              requestId: request.id,
              revisionNumber: request.revisionNumber,
              submittedBy: request.submittedBy,
              approvalActions: request.currentApprovalActions,
              fieldValues: request.fieldValues,
            )
          : null;

      final excelBytes = _excelService.generateExcel(
        request: request,
        workspace: workspace,
        hash: hash,
      );

      _state = _state.copyWith(excelBytes: excelBytes, hash: hash);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setGenerating(false);
    }
  }

  Future<void> shareExcel(String filename, {Rect? sharePositionOrigin}) async {
    if (_state.excelBytes == null) {
      _setError('No Excel generated. Call generateExcel() first.');
      return;
    }
    _setGenerating(true);
    try {
      await _excelService.shareExcel(
        _state.excelBytes!,
        filename,
        sharePositionOrigin: sharePositionOrigin,
      );
    } catch (e) {
      _setError(e.toString());
    }
    _setGenerating(false);
  }

  // ── Workspace Excel Report ────────────────────────────────────────────────

  /// Generate Excel report for workspace analytics.
  /// [requests] - filtered list of requests based on date range and permissions
  /// [workspace] - current workspace
  /// [dateRange] - optional date range filter
  /// [isAdmin] - whether user is owner/admin (determines data scope)
  Future<void> generateWorkspaceExcel({
    required List<ApprovalRequest> requests,
    required Workspace workspace,
    DateTimeRange? dateRange,
    required bool isAdmin,
    required String currentUserId,
  }) async {
    _setGenerating(true);
    _clearError();

    try {
      // Filter requests based on permissions
      List<ApprovalRequest> filteredRequests = requests;
      if (!isAdmin) {
        // Regular members can only see requests they submitted or approved
        filteredRequests = requests.where((r) {
          final isSubmitter = r.submittedBy == currentUserId;
          final isApprover = r.approvalActions.any(
            (a) => a.approverId == currentUserId,
          );
          return isSubmitter || isApprover;
        }).toList();
      }

      // Apply date range filter if provided
      if (dateRange != null) {
        filteredRequests = filteredRequests.where((r) {
          return r.submittedAt.isAfter(dateRange.start) &&
              r.submittedAt
                  .isBefore(dateRange.end.add(const Duration(days: 1)));
        }).toList();
      }

      final excelBytes = _excelService.generateWorkspaceExcel(
        requests: filteredRequests,
        workspace: workspace,
        dateRange: dateRange,
      );

      _state = _state.copyWith(excelBytes: excelBytes);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setGenerating(false);
    }
  }

  // ── Template Report ────────────────────────────────────────────────────────

  /// Generate Excel report for a specific template.
  Future<void> generateTemplateReport({
    required List<ApprovalRequest> requests,
    required Template template,
    required Workspace workspace,
    DateTimeRange? dateRange,
  }) async {
    _setGenerating(true);
    _clearError();

    try {
      final excelBytes = _excelService.generateTemplateExcel(
        requests: requests,
        template: template,
        workspace: workspace,
        dateRange: dateRange,
      );

      _state = _state.copyWith(excelBytes: excelBytes);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setGenerating(false);
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void clearPdf() {
    _state = _state.copyWith(
      pdfBytes: null,
      exportedPath: null,
      hash: null,
    );
    notifyListeners();
  }

  void clearExcel() {
    _state = _state.copyWith(excelBytes: null);
    notifyListeners();
  }

  void _setGenerating(bool generating) {
    _state = _state.copyWith(isGenerating: generating);
    notifyListeners();
  }

  void _setError(String error) {
    _state = _state.copyWith(error: error);
    notifyListeners();
  }

  void _clearError() {
    _state = _state.copyWith(error: null);
    notifyListeners();
  }
}

/// State for export provider
class ExportState {
  final bool isGenerating;
  final Uint8List? pdfBytes;
  final Uint8List? excelBytes;
  final String? exportedPath;
  final String? hash;
  final String? error;

  const ExportState({
    this.isGenerating = false,
    this.pdfBytes,
    this.excelBytes,
    this.exportedPath,
    this.hash,
    this.error,
  });

  ExportState copyWith({
    bool? isGenerating,
    Uint8List? pdfBytes,
    Uint8List? excelBytes,
    String? exportedPath,
    String? hash,
    String? error,
  }) {
    return ExportState(
      isGenerating: isGenerating ?? this.isGenerating,
      pdfBytes: pdfBytes ?? this.pdfBytes,
      excelBytes: excelBytes ?? this.excelBytes,
      exportedPath: exportedPath ?? this.exportedPath,
      hash: hash ?? this.hash,
      error: error ?? this.error,
    );
  }
}

import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../request/request_models.dart';
import '../workspace/workspace_models.dart';
import '../verification/hash_service.dart';
import 'pdf_service.dart';

class ExportProvider extends ChangeNotifier {
  final PdfService _pdfService;
  final HashService _hashService;

  ExportState _state = const ExportState();

  ExportProvider({
    required PdfService pdfService,
    required HashService hashService,
  })  : _pdfService = pdfService,
        _hashService = hashService;

  ExportState get state => _state;
  bool get isGenerating => _state.isGenerating;
  Uint8List? get pdfBytes => _state.pdfBytes;
  String? get exportedPath => _state.exportedPath;
  String? get error => _state.error;

  /// Generate PDF for approval request
  Future<void> generatePdf({
    required ApprovalRequest request,
    required Workspace workspace,
    bool includeWatermark = false,
  }) async {
    _setGenerating(true);
    _clearError();

    try {
      // Generate hash for verification
      final hash = _hashService.generateHash(
        workspaceId: workspace.id,
        requestId: request.id,
        revisionNumber: request.revisionNumber,
        submittedBy: request.submittedBy,
        approvalActions: request.currentApprovalActions,
        fieldValues: request.fieldValues,
      );

      // Generate PDF
      final pdfBytes = await _pdfService.generatePdf(
        request: request,
        workspace: workspace,
        hash: hash,
        includeWatermark: includeWatermark,
      );

      _state = _state.copyWith(
        pdfBytes: pdfBytes,
        hash: hash,
      );
    } catch (e) {
      _setError(e.toString());
    }

    _setGenerating(false);
  }

  /// Export PDF to file
  Future<void> exportToFile(String filename) async {
    if (_state.pdfBytes == null) {
      _setError('No PDF generated');
      return;
    }

    _setGenerating(true);

    try {
      final file = await _pdfService.savePdf(_state.pdfBytes!, filename);
      _state = _state.copyWith(exportedPath: file.path);
    } catch (e) {
      _setError(e.toString());
    }

    _setGenerating(false);
  }

  /// Share PDF
  Future<void> sharePdf(String filename) async {
    if (_state.pdfBytes == null) {
      _setError('No PDF generated');
      return;
    }

    _setGenerating(true);

    try {
      await _pdfService.sharePdf(_state.pdfBytes!, filename);
    } catch (e) {
      _setError(e.toString());
    }

    _setGenerating(false);
  }

  /// Clear generated PDF
  void clearPdf() {
    _state = _state.copyWith(
      pdfBytes: null,
      exportedPath: null,
      hash: null,
    );
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
  final String? exportedPath;
  final String? hash;
  final String? error;

  const ExportState({
    this.isGenerating = false,
    this.pdfBytes,
    this.exportedPath,
    this.hash,
    this.error,
  });

  ExportState copyWith({
    bool? isGenerating,
    Uint8List? pdfBytes,
    String? exportedPath,
    String? hash,
    String? error,
  }) {
    return ExportState(
      isGenerating: isGenerating ?? this.isGenerating,
      pdfBytes: pdfBytes ?? this.pdfBytes,
      exportedPath: exportedPath ?? this.exportedPath,
      hash: hash ?? this.hash,
      error: error ?? this.error,
    );
  }
}

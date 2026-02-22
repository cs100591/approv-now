import 'dart:typed_data';
import 'dart:ui' show Rect;
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../../core/utils/app_logger.dart';
import '../request/request_models.dart';
import '../workspace/workspace_models.dart';

/// ExcelService - Generates Excel exports for approval requests
class ExcelService {
  // ── Primary API ────────────────────────────────────────────────────────────

  /// Generate an Excel workbook containing request data.
  Uint8List generateExcel({
    required ApprovalRequest request,
    required Workspace workspace,
    String? hash,
  }) {
    final excel = Excel.createExcel();

    // Remove default sheet
    excel.delete('Sheet1');

    _buildSummarySheet(excel, request, workspace, hash);
    _buildFormDataSheet(excel, request);
    _buildApprovalHistorySheet(excel, request);

    final bytes = excel.encode();
    if (bytes == null) throw Exception('Failed to encode Excel file');
    return Uint8List.fromList(bytes);
  }

  // ── Sheet builders ─────────────────────────────────────────────────────────

  void _buildSummarySheet(
    Excel excel,
    ApprovalRequest request,
    Workspace workspace,
    String? hash,
  ) {
    final sheet = excel['Summary'];

    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#2563EB'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      fontSize: 12,
    );
    final labelStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#F1F5F9'),
    );
    final valueStyle = CellStyle();

    // ── Title ──────────────────────────────────────────────────────────────
    final titleCell = sheet.cell(CellIndex.indexByString('A1'));
    titleCell.value = TextCellValue(request.templateName.toUpperCase());
    titleCell.cellStyle = CellStyle(
      bold: true,
      fontSize: 16,
      fontColorHex: ExcelColor.fromHexString('#2563EB'),
    );

    sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('B1'));

    // ── Workspace ──────────────────────────────────────────────────────────
    _writeRow(sheet, 2, 'Workspace', workspace.name, labelStyle, valueStyle);
    _writeRow(sheet, 3, 'Request ID', request.id, labelStyle, valueStyle);
    _writeRow(sheet, 4, 'Revision', '${request.revisionNumber}', labelStyle,
        valueStyle);
    _writeRow(sheet, 5, 'Submitted By', request.submittedByName, labelStyle,
        valueStyle);
    _writeRow(sheet, 6, 'Submitted At', _fmt(request.submittedAt), labelStyle,
        valueStyle);
    _writeRow(
        sheet,
        7,
        'Status',
        request.status.name.toUpperCase(),
        CellStyle(
          bold: true,
          fontColorHex: _statusHex(request.status),
        ),
        valueStyle);

    if (hash != null) {
      _writeRow(sheet, 8, 'Verification Hash', hash, labelStyle, valueStyle);
    }

    // ── Header row styling ─────────────────────────────────────────────────
    final hCell = sheet.cell(CellIndex.indexByString('A10'));
    hCell.value = TextCellValue('SUMMARY');
    hCell.cellStyle = headerStyle;
    sheet.merge(CellIndex.indexByString('A10'), CellIndex.indexByString('B10'));

    // Column widths
    sheet.setColumnWidth(0, 30);
    sheet.setColumnWidth(1, 50);
  }

  void _buildFormDataSheet(Excel excel, ApprovalRequest request) {
    final sheet = excel['Form Data'];

    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#2563EB'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
    );

    // Header row
    final fieldHeader = sheet.cell(CellIndex.indexByString('A1'));
    fieldHeader.value = TextCellValue('Field');
    fieldHeader.cellStyle = headerStyle;

    final valueHeader = sheet.cell(CellIndex.indexByString('B1'));
    valueHeader.value = TextCellValue('Value');
    valueHeader.cellStyle = headerStyle;

    final typeHeader = sheet.cell(CellIndex.indexByString('C1'));
    typeHeader.value = TextCellValue('Type');
    typeHeader.cellStyle = headerStyle;

    // Data rows
    for (int i = 0; i < request.fieldValues.length; i++) {
      final fv = request.fieldValues[i];
      final row = i + 2;
      final bg = i % 2 == 0
          ? ExcelColor.fromHexString('#FFFFFF')
          : ExcelColor.fromHexString('#F8FAFC');

      final rowStyle = CellStyle(backgroundColorHex: bg);

      final c1 = sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row - 1));
      c1.value = TextCellValue(fv.fieldName);
      c1.cellStyle = CellStyle(bold: true, backgroundColorHex: bg);

      final c2 = sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row - 1));
      c2.value = TextCellValue(_fmtValue(fv.value, fv.fieldType));
      c2.cellStyle = rowStyle;

      final c3 = sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row - 1));
      c3.value = TextCellValue(fv.fieldType.toString());
      c3.cellStyle = rowStyle;
    }

    sheet.setColumnWidth(0, 30);
    sheet.setColumnWidth(1, 50);
    sheet.setColumnWidth(2, 20);
  }

  void _buildApprovalHistorySheet(Excel excel, ApprovalRequest request) {
    if (request.currentApprovalActions.isEmpty) return;

    final sheet = excel['Approval History'];

    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#2563EB'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
    );

    // Headers
    final headers = ['Approver', 'Level', 'Decision', 'Date', 'Comment'];
    for (int c = 0; c < headers.length; c++) {
      final cell =
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0));
      cell.value = TextCellValue(headers[c]);
      cell.cellStyle = headerStyle;
    }

    // Data rows
    for (int i = 0; i < request.currentApprovalActions.length; i++) {
      final action = request.currentApprovalActions[i];
      final row = i + 1;
      final bg = i % 2 == 0
          ? ExcelColor.fromHexString('#FFFFFF')
          : ExcelColor.fromHexString('#F8FAFC');
      final rowStyle = CellStyle(backgroundColorHex: bg);

      _rowCell(sheet, row, 0, action.approverName, rowStyle);
      _rowCell(sheet, row, 1, 'Level ${action.level}', rowStyle);
      _rowCell(
          sheet,
          row,
          2,
          action.approved ? 'APPROVED' : 'REJECTED',
          CellStyle(
            backgroundColorHex: bg,
            bold: true,
            fontColorHex: action.approved
                ? ExcelColor.fromHexString('#16A34A')
                : ExcelColor.fromHexString('#DC2626'),
          ));
      _rowCell(sheet, row, 3, _fmt(action.timestamp), rowStyle);
      _rowCell(sheet, row, 4, action.comment ?? '', rowStyle);
    }

    sheet.setColumnWidth(0, 30);
    sheet.setColumnWidth(1, 10);
    sheet.setColumnWidth(2, 12);
    sheet.setColumnWidth(3, 20);
    sheet.setColumnWidth(4, 40);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _writeRow(Sheet sheet, int rowNum, String label, String value,
      CellStyle labelStyle, CellStyle valueStyle) {
    final lCell = sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowNum - 1));
    lCell.value = TextCellValue(label);
    lCell.cellStyle = labelStyle;

    final vCell = sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowNum - 1));
    vCell.value = TextCellValue(value);
    vCell.cellStyle = valueStyle;
  }

  void _rowCell(Sheet sheet, int row, int col, String value, CellStyle style) {
    final cell =
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
    cell.value = TextCellValue(value);
    cell.cellStyle = style;
  }

  String _fmt(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year} '
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

  ExcelColor _statusHex(RequestStatus status) {
    switch (status) {
      case RequestStatus.approved:
        return ExcelColor.fromHexString('#16A34A');
      case RequestStatus.rejected:
        return ExcelColor.fromHexString('#DC2626');
      case RequestStatus.pending:
        return ExcelColor.fromHexString('#D97706');
      default:
        return ExcelColor.fromHexString('#64748B');
    }
  }

  // ── Save / Share ───────────────────────────────────────────────────────────

  Future<String?> saveExcel(Uint8List bytes, String filename) async {
    try {
      if (kIsWeb) {
        // Web: trigger download via share_plus
        await Share.shareXFiles([
          XFile.fromData(bytes,
              name: filename,
              mimeType:
                  'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'),
        ]);
        return null;
      }

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(bytes);
      AppLogger.info('Excel saved: ${file.path}');
      return file.path;
    } catch (e) {
      AppLogger.error('Failed to save Excel', e);
      return null;
    }
  }

  Future<void> shareExcel(Uint8List bytes, String filename,
      {Rect? sharePositionOrigin}) async {
    try {
      if (kIsWeb) {
        await Share.shareXFiles(
          [
            XFile.fromData(bytes,
                name: filename,
                mimeType:
                    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'),
          ],
          subject: 'Approval Request Export',
          sharePositionOrigin: sharePositionOrigin,
        );
        return;
      }
      final path = await saveExcel(bytes, filename);
      if (path != null) {
        await Share.shareXFiles(
          [XFile(path)],
          subject: 'Approval Request Export',
          text: 'Please find the approval request data attached.',
          sharePositionOrigin: sharePositionOrigin,
        );
      }
    } catch (e) {
      AppLogger.error('Error sharing Excel', e);
      rethrow;
    }
  }
}

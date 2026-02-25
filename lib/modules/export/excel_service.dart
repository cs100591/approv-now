import 'dart:typed_data';
import 'dart:ui' show Rect;
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../../core/utils/app_logger.dart';
import '../request/request_models.dart';
import '../workspace/workspace_models.dart';
import '../template/template_models.dart';

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
    _writeRow(
        sheet, 3, 'Request ID', request.displayId, labelStyle, valueStyle);
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
    if (value == null ||
        value.toString().isEmpty ||
        value.toString() == 'null') {
      return '-';
    }
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

  // ── Workspace Report ──────────────────────────────────────────────────────

  /// Generate workspace analytics Excel report
  Uint8List generateWorkspaceExcel({
    required List<ApprovalRequest> requests,
    required Workspace workspace,
    DateTimeRange? dateRange,
  }) {
    final excel = Excel.createExcel();

    // Remove default sheet
    excel.delete('Sheet1');

    // Build all sheets
    _buildWorkspaceSummarySheet(excel, requests, workspace, dateRange);
    _buildRequestsListSheet(excel, requests);
    _buildByTemplateSheet(excel, requests);
    _buildBySubmitterSheet(excel, requests);
    _buildApprovalPerformanceSheet(excel, requests);

    final bytes = excel.encode();
    if (bytes == null) throw Exception('Failed to encode Excel file');
    return Uint8List.fromList(bytes);
  }

  void _buildWorkspaceSummarySheet(
    Excel excel,
    List<ApprovalRequest> requests,
    Workspace workspace,
    DateTimeRange? dateRange,
  ) {
    final sheet = excel['Summary'];

    final titleStyle = CellStyle(
      bold: true,
      fontSize: 18,
      fontColorHex: ExcelColor.fromHexString('#2563EB'),
    );

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

    // Title
    final titleCell = sheet.cell(CellIndex.indexByString('A1'));
    titleCell.value = TextCellValue('WORKSPACE ANALYTICS REPORT');
    titleCell.cellStyle = titleStyle;
    sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('C1'));

    // Workspace Info
    _writeRow(
        sheet, 3, 'Workspace Name', workspace.name, labelStyle, valueStyle);
    _writeRow(sheet, 4, 'Report Generated', _fmt(DateTime.now()), labelStyle,
        valueStyle);

    if (dateRange != null) {
      _writeRow(
          sheet,
          5,
          'Date Range',
          '${_fmt(dateRange.start)} - ${_fmt(dateRange.end)}',
          labelStyle,
          valueStyle);
    }

    // Statistics Header
    final statsHeader = sheet.cell(CellIndex.indexByString('A7'));
    statsHeader.value = TextCellValue('OVERVIEW STATISTICS');
    statsHeader.cellStyle = headerStyle;
    sheet.merge(CellIndex.indexByString('A7'), CellIndex.indexByString('C7'));

    // Calculate statistics
    final totalCount = requests.length;
    final approvedCount =
        requests.where((r) => r.status == RequestStatus.approved).length;
    final rejectedCount =
        requests.where((r) => r.status == RequestStatus.rejected).length;
    final pendingCount =
        requests.where((r) => r.status == RequestStatus.pending).length;

    final approvalRate = totalCount > 0
        ? ((approvedCount / totalCount) * 100).toStringAsFixed(1)
        : '0.0';

    // Calculate average approval time
    double avgApprovalTime = 0;
    int completedCount = 0;
    for (final request in requests) {
      if (request.status == RequestStatus.approved ||
          request.status == RequestStatus.rejected) {
        final approvalAction = request.approvalActions.lastWhere(
          (a) => a.level == request.currentLevel,
          orElse: () => request.approvalActions.isNotEmpty
              ? request.approvalActions.last
              : null as ApprovalAction,
        );
        if (approvalAction != null) {
          final duration =
              approvalAction.timestamp.difference(request.submittedAt);
          avgApprovalTime += duration.inHours;
          completedCount++;
        }
      }
    }
    avgApprovalTime = completedCount > 0 ? avgApprovalTime / completedCount : 0;

    // Write statistics
    _writeRow(sheet, 9, 'Total Requests', totalCount.toString(), labelStyle,
        valueStyle);
    _writeRow(
        sheet,
        10,
        'Approved',
        approvedCount.toString(),
        labelStyle,
        CellStyle(
          fontColorHex: ExcelColor.fromHexString('#16A34A'),
          bold: true,
        ));
    _writeRow(
        sheet,
        11,
        'Rejected',
        rejectedCount.toString(),
        labelStyle,
        CellStyle(
          fontColorHex: ExcelColor.fromHexString('#DC2626'),
          bold: true,
        ));
    _writeRow(
        sheet,
        12,
        'Pending',
        pendingCount.toString(),
        labelStyle,
        CellStyle(
          fontColorHex: ExcelColor.fromHexString('#D97706'),
          bold: true,
        ));
    _writeRow(
        sheet, 13, 'Approval Rate', '$approvalRate%', labelStyle, valueStyle);
    _writeRow(sheet, 14, 'Avg. Approval Time',
        '${avgApprovalTime.toStringAsFixed(1)} hours', labelStyle, valueStyle);

    // Column widths
    sheet.setColumnWidth(0, 35);
    sheet.setColumnWidth(1, 30);
    sheet.setColumnWidth(2, 30);
  }

  void _buildRequestsListSheet(Excel excel, List<ApprovalRequest> requests) {
    final sheet = excel['Requests List'];

    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#2563EB'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
    );

    // Headers
    final headers = [
      'Request ID',
      'Template',
      'Submitted By',
      'Status',
      'Current Level',
      'Submitted At',
      'Completed At'
    ];
    for (int c = 0; c < headers.length; c++) {
      final cell =
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0));
      cell.value = TextCellValue(headers[c]);
      cell.cellStyle = headerStyle;
    }

    // Data rows
    for (int i = 0; i < requests.length; i++) {
      final request = requests[i];
      final row = i + 1;
      final bg = i % 2 == 0
          ? ExcelColor.fromHexString('#FFFFFF')
          : ExcelColor.fromHexString('#F8FAFC');
      final rowStyle = CellStyle(backgroundColorHex: bg);

      _rowCell(sheet, row, 0, request.displayId, rowStyle);
      _rowCell(sheet, row, 1, request.templateName, rowStyle);
      _rowCell(sheet, row, 2, request.submittedByName, rowStyle);
      _rowCell(
          sheet,
          row,
          3,
          request.status.name.toUpperCase(),
          CellStyle(
            backgroundColorHex: bg,
            bold: true,
            fontColorHex: _statusHex(request.status),
          ));
      _rowCell(sheet, row, 4, 'Level ${request.currentLevel}', rowStyle);
      _rowCell(sheet, row, 5, _fmt(request.submittedAt), rowStyle);

      String completedAt = '-';
      if (request.status == RequestStatus.approved ||
          request.status == RequestStatus.rejected) {
        if (request.approvalActions.isNotEmpty) {
          completedAt = _fmt(request.approvalActions.last.timestamp);
        }
      }
      _rowCell(sheet, row, 6, completedAt, rowStyle);
    }

    // Column widths
    sheet.setColumnWidth(0, 20);
    sheet.setColumnWidth(1, 25);
    sheet.setColumnWidth(2, 25);
    sheet.setColumnWidth(3, 15);
    sheet.setColumnWidth(4, 15);
    sheet.setColumnWidth(5, 20);
    sheet.setColumnWidth(6, 20);
  }

  void _buildByTemplateSheet(Excel excel, List<ApprovalRequest> requests) {
    final sheet = excel['By Template'];

    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#2563EB'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
    );

    // Group by template
    final Map<String, List<ApprovalRequest>> byTemplate = {};
    for (final request in requests) {
      byTemplate.putIfAbsent(request.templateName, () => []).add(request);
    }

    // Headers
    final headers = [
      'Template',
      'Total',
      'Approved',
      'Rejected',
      'Pending',
      'Approval Rate'
    ];
    for (int c = 0; c < headers.length; c++) {
      final cell =
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0));
      cell.value = TextCellValue(headers[c]);
      cell.cellStyle = headerStyle;
    }

    // Data rows
    int rowIndex = 1;
    byTemplate.forEach((templateName, templateRequests) {
      final bg = (rowIndex - 1) % 2 == 0
          ? ExcelColor.fromHexString('#FFFFFF')
          : ExcelColor.fromHexString('#F8FAFC');
      final rowStyle = CellStyle(backgroundColorHex: bg);

      final total = templateRequests.length;
      final approved = templateRequests
          .where((r) => r.status == RequestStatus.approved)
          .length;
      final rejected = templateRequests
          .where((r) => r.status == RequestStatus.rejected)
          .length;
      final pending = templateRequests
          .where((r) => r.status == RequestStatus.pending)
          .length;
      final rate =
          total > 0 ? ((approved / total) * 100).toStringAsFixed(1) : '0.0';

      _rowCell(sheet, rowIndex, 0, templateName, rowStyle);
      _rowCell(sheet, rowIndex, 1, total.toString(), rowStyle);
      _rowCell(
          sheet,
          rowIndex,
          2,
          approved.toString(),
          CellStyle(
            backgroundColorHex: bg,
            fontColorHex: ExcelColor.fromHexString('#16A34A'),
          ));
      _rowCell(
          sheet,
          rowIndex,
          3,
          rejected.toString(),
          CellStyle(
            backgroundColorHex: bg,
            fontColorHex: ExcelColor.fromHexString('#DC2626'),
          ));
      _rowCell(
          sheet,
          rowIndex,
          4,
          pending.toString(),
          CellStyle(
            backgroundColorHex: bg,
            fontColorHex: ExcelColor.fromHexString('#D97706'),
          ));
      _rowCell(sheet, rowIndex, 5, '$rate%', rowStyle);

      rowIndex++;
    });

    // Column widths
    sheet.setColumnWidth(0, 30);
    sheet.setColumnWidth(1, 12);
    sheet.setColumnWidth(2, 12);
    sheet.setColumnWidth(3, 12);
    sheet.setColumnWidth(4, 12);
    sheet.setColumnWidth(5, 15);
  }

  void _buildBySubmitterSheet(Excel excel, List<ApprovalRequest> requests) {
    final sheet = excel['By Submitter'];

    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#2563EB'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
    );

    // Group by submitter
    final Map<String, List<ApprovalRequest>> bySubmitter = {};
    for (final request in requests) {
      bySubmitter.putIfAbsent(request.submittedByName, () => []).add(request);
    }

    // Headers
    final headers = [
      'Submitter',
      'Submitted',
      'Approved',
      'Rejected',
      'Pending'
    ];
    for (int c = 0; c < headers.length; c++) {
      final cell =
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0));
      cell.value = TextCellValue(headers[c]);
      cell.cellStyle = headerStyle;
    }

    // Data rows
    int rowIndex = 1;
    bySubmitter.forEach((submitterName, submitterRequests) {
      final bg = (rowIndex - 1) % 2 == 0
          ? ExcelColor.fromHexString('#FFFFFF')
          : ExcelColor.fromHexString('#F8FAFC');
      final rowStyle = CellStyle(backgroundColorHex: bg);

      final total = submitterRequests.length;
      final approved = submitterRequests
          .where((r) => r.status == RequestStatus.approved)
          .length;
      final rejected = submitterRequests
          .where((r) => r.status == RequestStatus.rejected)
          .length;
      final pending = submitterRequests
          .where((r) => r.status == RequestStatus.pending)
          .length;

      _rowCell(sheet, rowIndex, 0, submitterName, rowStyle);
      _rowCell(sheet, rowIndex, 1, total.toString(), rowStyle);
      _rowCell(
          sheet,
          rowIndex,
          2,
          approved.toString(),
          CellStyle(
            backgroundColorHex: bg,
            fontColorHex: ExcelColor.fromHexString('#16A34A'),
          ));
      _rowCell(
          sheet,
          rowIndex,
          3,
          rejected.toString(),
          CellStyle(
            backgroundColorHex: bg,
            fontColorHex: ExcelColor.fromHexString('#DC2626'),
          ));
      _rowCell(
          sheet,
          rowIndex,
          4,
          pending.toString(),
          CellStyle(
            backgroundColorHex: bg,
            fontColorHex: ExcelColor.fromHexString('#D97706'),
          ));

      rowIndex++;
    });

    // Column widths
    sheet.setColumnWidth(0, 30);
    sheet.setColumnWidth(1, 15);
    sheet.setColumnWidth(2, 15);
    sheet.setColumnWidth(3, 15);
    sheet.setColumnWidth(4, 15);
  }

  void _buildApprovalPerformanceSheet(
      Excel excel, List<ApprovalRequest> requests) {
    final sheet = excel['Approval Performance'];

    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#2563EB'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
    );

    // Calculate approval stats per approver
    final Map<String, Map<String, dynamic>> approverStats = {};

    for (final request in requests) {
      for (final action in request.approvalActions) {
        if (!approverStats.containsKey(action.approverName)) {
          approverStats[action.approverName] = {
            'approvals': 0,
            'rejections': 0,
            'totalTime': 0,
            'count': 0,
          };
        }

        if (action.approved) {
          approverStats[action.approverName]!['approvals'] =
              (approverStats[action.approverName]!['approvals'] as int) + 1;
        } else {
          approverStats[action.approverName]!['rejections'] =
              (approverStats[action.approverName]!['rejections'] as int) + 1;
        }

        // Calculate time from submission to this approval
        final duration = action.timestamp.difference(request.submittedAt);
        approverStats[action.approverName]!['totalTime'] =
            (approverStats[action.approverName]!['totalTime'] as double) +
                duration.inHours;
        approverStats[action.approverName]!['count'] =
            (approverStats[action.approverName]!['count'] as int) + 1;
      }
    }

    // Headers
    final headers = [
      'Approver',
      'Total Actions',
      'Approvals',
      'Rejections',
      'Avg. Response Time (hrs)',
      'Approval Rate'
    ];
    for (int c = 0; c < headers.length; c++) {
      final cell =
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0));
      cell.value = TextCellValue(headers[c]);
      cell.cellStyle = headerStyle;
    }

    // Data rows
    int rowIndex = 1;
    approverStats.forEach((approverName, stats) {
      final bg = (rowIndex - 1) % 2 == 0
          ? ExcelColor.fromHexString('#FFFFFF')
          : ExcelColor.fromHexString('#F8FAFC');
      final rowStyle = CellStyle(backgroundColorHex: bg);

      final totalActions = stats['approvals'] + stats['rejections'];
      final avgTime = (stats['count'] as int) > 0
          ? (stats['totalTime'] as double) / (stats['count'] as int)
          : 0.0;
      final approvalRate = totalActions > 0
          ? ((stats['approvals'] / totalActions) * 100).toStringAsFixed(1)
          : '0.0';

      _rowCell(sheet, rowIndex, 0, approverName, rowStyle);
      _rowCell(sheet, rowIndex, 1, totalActions.toString(), rowStyle);
      _rowCell(
          sheet,
          rowIndex,
          2,
          stats['approvals'].toString(),
          CellStyle(
            backgroundColorHex: bg,
            fontColorHex: ExcelColor.fromHexString('#16A34A'),
          ));
      _rowCell(
          sheet,
          rowIndex,
          3,
          stats['rejections'].toString(),
          CellStyle(
            backgroundColorHex: bg,
            fontColorHex: ExcelColor.fromHexString('#DC2626'),
          ));
      _rowCell(sheet, rowIndex, 4, avgTime.toStringAsFixed(1), rowStyle);
      _rowCell(sheet, rowIndex, 5, '$approvalRate%', rowStyle);

      rowIndex++;
    });

    // Column widths
    sheet.setColumnWidth(0, 25);
    sheet.setColumnWidth(1, 15);
    sheet.setColumnWidth(2, 12);
    sheet.setColumnWidth(3, 12);
    sheet.setColumnWidth(4, 25);
    sheet.setColumnWidth(5, 15);
  }

  // ── Template Report ────────────────────────────────────────────────────────

  /// Generate Excel report for a specific template
  Uint8List generateTemplateExcel({
    required List<ApprovalRequest> requests,
    required dynamic template,
    required Workspace workspace,
    DateTimeRange? dateRange,
  }) {
    final excel = Excel.createExcel();
    excel.delete('Sheet1');

    _buildTemplateSummarySheet(excel, requests, template, workspace, dateRange);
    _buildTemplateRequestsListSheet(excel, requests);
    _buildTemplateApprovalHistorySheet(excel, requests);
    _buildTemplateBySubmitterSheet(excel, requests);

    final bytes = excel.encode();
    if (bytes == null) throw Exception('Failed to encode Excel file');
    return Uint8List.fromList(bytes);
  }

  void _buildTemplateSummarySheet(
    Excel excel,
    List<ApprovalRequest> requests,
    dynamic template,
    Workspace workspace,
    DateTimeRange? dateRange,
  ) {
    final sheet = excel['Summary'];

    final titleStyle = CellStyle(
      bold: true,
      fontSize: 18,
      fontColorHex: ExcelColor.fromHexString('#2563EB'),
    );

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

    // Title
    final titleCell = sheet.cell(CellIndex.indexByString('A1'));
    titleCell.value = TextCellValue('${template.name.toUpperCase()} REPORT');
    titleCell.cellStyle = titleStyle;
    sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('C1'));

    // Template Info
    _writeRow(sheet, 3, 'Template Name', template.name, labelStyle, valueStyle);
    _writeRow(sheet, 4, 'Workspace', workspace.name, labelStyle, valueStyle);
    _writeRow(sheet, 5, 'Report Generated', _fmt(DateTime.now()), labelStyle,
        valueStyle);

    if (dateRange != null) {
      _writeRow(
        sheet,
        6,
        'Date Range',
        '${_fmt(dateRange.start)} - ${_fmt(dateRange.end)}',
        labelStyle,
        valueStyle,
      );
    }

    // Statistics
    final statsHeader = sheet.cell(CellIndex.indexByString('A8'));
    statsHeader.value = TextCellValue('STATISTICS');
    statsHeader.cellStyle = headerStyle;
    sheet.merge(CellIndex.indexByString('A8'), CellIndex.indexByString('C8'));

    final totalCount = requests.length;
    final approvedCount =
        requests.where((r) => r.status == RequestStatus.approved).length;
    final rejectedCount =
        requests.where((r) => r.status == RequestStatus.rejected).length;
    final pendingCount =
        requests.where((r) => r.status == RequestStatus.pending).length;

    final approvalRate = totalCount > 0
        ? ((approvedCount / totalCount) * 100).toStringAsFixed(1)
        : '0.0';

    _writeRow(sheet, 10, 'Total Requests', totalCount.toString(), labelStyle,
        valueStyle);
    _writeRow(
      sheet,
      11,
      'Approved',
      approvedCount.toString(),
      labelStyle,
      CellStyle(
        fontColorHex: ExcelColor.fromHexString('#16A34A'),
        bold: true,
      ),
    );
    _writeRow(
      sheet,
      12,
      'Rejected',
      rejectedCount.toString(),
      labelStyle,
      CellStyle(
        fontColorHex: ExcelColor.fromHexString('#DC2626'),
        bold: true,
      ),
    );
    _writeRow(
      sheet,
      13,
      'Pending',
      pendingCount.toString(),
      labelStyle,
      CellStyle(
        fontColorHex: ExcelColor.fromHexString('#D97706'),
        bold: true,
      ),
    );
    _writeRow(
        sheet, 14, 'Approval Rate', '$approvalRate%', labelStyle, valueStyle);

    sheet.setColumnWidth(0, 35);
    sheet.setColumnWidth(1, 30);
    sheet.setColumnWidth(2, 30);
  }

  void _buildTemplateRequestsListSheet(
      Excel excel, List<ApprovalRequest> requests) {
    final sheet = excel['Requests List'];

    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#2563EB'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
    );

    final headers = [
      'Request ID',
      'Submitted By',
      'Status',
      'Submitted At',
      'Completed At'
    ];
    for (int c = 0; c < headers.length; c++) {
      final cell =
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0));
      cell.value = TextCellValue(headers[c]);
      cell.cellStyle = headerStyle;
    }

    for (int i = 0; i < requests.length; i++) {
      final request = requests[i];
      final row = i + 1;
      final bg = i % 2 == 0
          ? ExcelColor.fromHexString('#FFFFFF')
          : ExcelColor.fromHexString('#F8FAFC');
      final rowStyle = CellStyle(backgroundColorHex: bg);

      _rowCell(sheet, row, 0, request.displayId, rowStyle);
      _rowCell(sheet, row, 1, request.submittedByName, rowStyle);
      _rowCell(
        sheet,
        row,
        2,
        request.status.name.toUpperCase(),
        CellStyle(
          backgroundColorHex: bg,
          bold: true,
          fontColorHex: _statusHex(request.status),
        ),
      );
      _rowCell(sheet, row, 3, _fmt(request.submittedAt), rowStyle);

      String completedAt = '-';
      if (request.status == RequestStatus.approved ||
          request.status == RequestStatus.rejected) {
        if (request.approvalActions.isNotEmpty) {
          completedAt = _fmt(request.approvalActions.last.timestamp);
        }
      }
      _rowCell(sheet, row, 4, completedAt, rowStyle);
    }

    sheet.setColumnWidth(0, 20);
    sheet.setColumnWidth(1, 25);
    sheet.setColumnWidth(2, 15);
    sheet.setColumnWidth(3, 20);
    sheet.setColumnWidth(4, 20);
  }

  void _buildTemplateApprovalHistorySheet(
      Excel excel, List<ApprovalRequest> requests) {
    final sheet = excel['Approval History'];

    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#2563EB'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
    );

    final headers = ['Request ID', 'Approver', 'Level', 'Decision', 'Date'];
    for (int c = 0; c < headers.length; c++) {
      final cell =
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0));
      cell.value = TextCellValue(headers[c]);
      cell.cellStyle = headerStyle;
    }

    int rowIndex = 1;
    for (final request in requests) {
      for (int i = 0; i < request.approvalActions.length; i++) {
        final action = request.approvalActions[i];
        final bg = (rowIndex - 1) % 2 == 0
            ? ExcelColor.fromHexString('#FFFFFF')
            : ExcelColor.fromHexString('#F8FAFC');
        final rowStyle = CellStyle(backgroundColorHex: bg);

        _rowCell(sheet, rowIndex, 0, request.displayId, rowStyle);
        _rowCell(sheet, rowIndex, 1, action.approverName, rowStyle);
        _rowCell(sheet, rowIndex, 2, 'Level ${action.level}', rowStyle);
        _rowCell(
          sheet,
          rowIndex,
          3,
          action.approved ? 'APPROVED' : 'REJECTED',
          CellStyle(
            backgroundColorHex: bg,
            bold: true,
            fontColorHex: action.approved
                ? ExcelColor.fromHexString('#16A34A')
                : ExcelColor.fromHexString('#DC2626'),
          ),
        );
        _rowCell(sheet, rowIndex, 4, _fmt(action.timestamp), rowStyle);

        rowIndex++;
      }
    }

    sheet.setColumnWidth(0, 20);
    sheet.setColumnWidth(1, 25);
    sheet.setColumnWidth(2, 10);
    sheet.setColumnWidth(3, 12);
    sheet.setColumnWidth(4, 20);
  }

  void _buildTemplateBySubmitterSheet(
      Excel excel, List<ApprovalRequest> requests) {
    final sheet = excel['By Submitter'];

    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#2563EB'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
    );

    // Group by submitter
    final Map<String, List<ApprovalRequest>> bySubmitter = {};
    for (final request in requests) {
      bySubmitter.putIfAbsent(request.submittedByName, () => []).add(request);
    }

    final headers = [
      'Submitter',
      'Submitted',
      'Approved',
      'Rejected',
      'Pending'
    ];
    for (int c = 0; c < headers.length; c++) {
      final cell =
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0));
      cell.value = TextCellValue(headers[c]);
      cell.cellStyle = headerStyle;
    }

    int rowIndex = 1;
    bySubmitter.forEach((submitterName, submitterRequests) {
      final bg = (rowIndex - 1) % 2 == 0
          ? ExcelColor.fromHexString('#FFFFFF')
          : ExcelColor.fromHexString('#F8FAFC');
      final rowStyle = CellStyle(backgroundColorHex: bg);

      final total = submitterRequests.length;
      final approved = submitterRequests
          .where((r) => r.status == RequestStatus.approved)
          .length;
      final rejected = submitterRequests
          .where((r) => r.status == RequestStatus.rejected)
          .length;
      final pending = submitterRequests
          .where((r) => r.status == RequestStatus.pending)
          .length;

      _rowCell(sheet, rowIndex, 0, submitterName, rowStyle);
      _rowCell(sheet, rowIndex, 1, total.toString(), rowStyle);
      _rowCell(
        sheet,
        rowIndex,
        2,
        approved.toString(),
        CellStyle(
          backgroundColorHex: bg,
          fontColorHex: ExcelColor.fromHexString('#16A34A'),
        ),
      );
      _rowCell(
        sheet,
        rowIndex,
        3,
        rejected.toString(),
        CellStyle(
          backgroundColorHex: bg,
          fontColorHex: ExcelColor.fromHexString('#DC2626'),
        ),
      );
      _rowCell(
        sheet,
        rowIndex,
        4,
        pending.toString(),
        CellStyle(
          backgroundColorHex: bg,
          fontColorHex: ExcelColor.fromHexString('#D97706'),
        ),
      );

      rowIndex++;
    });

    sheet.setColumnWidth(0, 30);
    sheet.setColumnWidth(1, 15);
    sheet.setColumnWidth(2, 15);
    sheet.setColumnWidth(3, 15);
    sheet.setColumnWidth(4, 15);
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
      // Share directly from memory bytes - works on all platforms including iOS
      // This avoids file permission issues and provides immediate share sheet
      await Share.shareXFiles(
        [
          XFile.fromData(bytes,
              name: filename,
              mimeType:
                  'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'),
        ],
        subject: 'Approval Request Export',
        text: 'Please find the approval request data attached.',
        sharePositionOrigin: sharePositionOrigin,
      );

      AppLogger.info('Excel shared successfully: $filename');
    } catch (e) {
      AppLogger.error('Error sharing Excel', e);
      rethrow;
    }
  }
}

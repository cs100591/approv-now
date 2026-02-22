import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart';

@JS('window.navigator.msSaveBlob')
external bool? get msSaveBlob;

@JS('window.navigator.msSaveBlob')
external void _msSaveBlob(JSAny blob, String defaultName);

@JS('Blob')
external JSFunction get _blobConstructor;

@JS('window.URL.createObjectURL')
external String _createObjectURL(JSAny blob);

@JS('window.URL.revokeObjectURL')
external void _revokeObjectURL(String url);

@JS('document.createElement')
external JSAny _createElement(String tagName);

extension type JSAnchorElement._(JSAny _) implements JSAny {
  external set href(String value);
  external set download(String value);
  external void click();
}

/// Web implementation: triggers browser download of PDF bytes via data URI.
/// Returns null since there's no file path on web.
Future<String?> savePdfPlatform(Uint8List bytes, String filename) async {
  _triggerDownload(bytes, filename);
  return null;
}

void _triggerDownload(Uint8List bytes, String filename) {
  try {
    // Create blob using js_interop
    final jsBytes = bytes.toJS;
    final jsArray = [jsBytes].toJS;

    // Create options object
    final options = {'type': 'application/pdf'}.jsify();

    final blob = _blobConstructor.callAsConstructor<JSAny>(jsArray, options);

    // Handle IE/Edge old versions if needed
    if (msSaveBlob != null) {
      _msSaveBlob(blob, filename);
      return;
    }

    // Fallback for modern browsers
    final url = _createObjectURL(blob);

    final anchor = JSAnchorElement._(_createElement('a'));
    anchor.href = url;
    anchor.download = filename;

    // Trigger download
    anchor.click();

    // Clean up
    _revokeObjectURL(url);

    if (kDebugMode) {
      print('[PdfService] Web download triggered successfully for: $filename');
    }
  } catch (e) {
    if (kDebugMode) {
      print('[PdfService] Fallback to base64 download due to error: $e');
    }
    _fallbackDownload(bytes, filename);
  }
}

void _fallbackDownload(Uint8List bytes, String filename) {
  try {
    final base64String = base64Encode(bytes);
    final dataUri = 'data:application/pdf;base64,$base64String';

    final anchor = JSAnchorElement._(_createElement('a'));
    anchor.href = dataUri;
    anchor.download = filename;

    anchor.click();
  } catch (e) {
    if (kDebugMode) {
      print('[PdfService] Web download failed: $e');
    }
  }
}

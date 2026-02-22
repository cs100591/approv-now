import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

/// Native (mobile/desktop) implementation: saves PDF to app documents directory
Future<String?> savePdfPlatform(Uint8List bytes, String filename) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$filename');
  await file.writeAsBytes(bytes);
  return file.path;
}

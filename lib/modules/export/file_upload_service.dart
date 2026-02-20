import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/utils/app_logger.dart';

/// FileUploadService - Handles file uploads to Firebase Storage
class FileUploadService {
  final FirebaseStorage _storage;

  FileUploadService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  /// Pick and upload file
  Future<FileUploadResult?> pickAndUploadFile({
    required String workspaceId,
    required String requestId,
    List<String>? allowedExtensions,
    int maxFileSizeInMB = 10,
  }) async {
    try {
      // Pick file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions:
            allowedExtensions ?? ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final file = result.files.first;

      // Check file size
      if (file.size > maxFileSizeInMB * 1024 * 1024) {
        throw FileUploadException(
          'File size exceeds ${maxFileSizeInMB}MB limit',
        );
      }

      // Upload file
      return await uploadFile(
        filePath: file.path!,
        fileName: file.name,
        workspaceId: workspaceId,
        requestId: requestId,
      );
    } catch (e) {
      AppLogger.error('Error picking/uploading file', e);
      rethrow;
    }
  }

  /// Upload file to Firebase Storage
  Future<FileUploadResult> uploadFile({
    required String filePath,
    required String fileName,
    required String workspaceId,
    required String requestId,
  }) async {
    try {
      AppLogger.info('Uploading file: $fileName');

      final file = File(filePath);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = '${timestamp}_$fileName';

      // Create storage reference
      final ref = _storage
          .ref()
          .child('workspaces')
          .child(workspaceId)
          .child('requests')
          .child(requestId)
          .child('attachments')
          .child(uniqueFileName);

      // Upload file
      final uploadTask = ref.putFile(file);

      // Wait for upload to complete
      final snapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      AppLogger.info('File uploaded successfully: $fileName');

      return FileUploadResult(
        fileName: fileName,
        fileUrl: downloadUrl,
        filePath: ref.fullPath,
        size: await file.length(),
      );
    } on FirebaseException catch (e) {
      AppLogger.error('Firebase storage error', e);
      throw FileUploadException(
        'Upload failed: ${e.message ?? 'Unknown error'}',
      );
    } catch (e) {
      AppLogger.error('Error uploading file', e);
      throw FileUploadException('Upload failed. Please try again.');
    }
  }

  /// Delete uploaded file
  Future<void> deleteFile(String filePath) async {
    try {
      final ref = _storage.ref().child(filePath);
      await ref.delete();
      AppLogger.info('File deleted: $filePath');
    } catch (e) {
      AppLogger.error('Error deleting file', e);
      rethrow;
    }
  }

  /// Get file download URL
  Future<String> getDownloadUrl(String filePath) async {
    try {
      final ref = _storage.ref().child(filePath);
      return await ref.getDownloadURL();
    } catch (e) {
      AppLogger.error('Error getting download URL', e);
      rethrow;
    }
  }
}

/// File upload result
class FileUploadResult {
  final String fileName;
  final String fileUrl;
  final String filePath;
  final int size;

  FileUploadResult({
    required this.fileName,
    required this.fileUrl,
    required this.filePath,
    required this.size,
  });
}

/// File upload exception
class FileUploadException implements Exception {
  final String message;
  FileUploadException(this.message);

  @override
  String toString() => message;
}

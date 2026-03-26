import '../../core/services/api_service.dart';
import '../../core/utils/logger.dart';
import 'dart:io';

class UploadAttendanceUseCase {
  final ApiService apiService;

  UploadAttendanceUseCase(this.apiService);

  Future<void> call(File file, String subjectId) async {
    try {
      // In a real implementation, you would send the file as multipart
      // For mock, we just simulate
      await apiService.post('/attendance/upload', data: {
        'subjectId': subjectId,
        'filePath': file.path,
      });
    } catch (e) {
      logger.e('Upload attendance error: $e');
      rethrow;
    }
  }
}
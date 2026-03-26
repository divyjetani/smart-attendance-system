import '../../core/services/api_service.dart';
import '../../core/utils/logger.dart';

class GenerateQrUseCase {
  final ApiService apiService;

  GenerateQrUseCase(this.apiService);

  Future<String> call(String subjectId) async {
    try {
      final response = await apiService.post('/qr/generate', data: {'subjectId': subjectId});
      return response['qrCode'];
    } catch (e) {
      logger.e('Generate QR error: $e');
      rethrow;
    }
  }
}
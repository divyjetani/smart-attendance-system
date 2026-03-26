import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:async';
import '../../domain/usecases/generate_qr_usecase.dart';
import '../../core/services/api_service.dart';
import '../../core/utils/logger.dart';

final generateQrUseCaseProvider = Provider((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return GenerateQrUseCase(apiService);
});

class QrGeneratorScreen extends ConsumerStatefulWidget {
  final String subjectId;

  const QrGeneratorScreen({super.key, required this.subjectId});

  @override
  ConsumerState<QrGeneratorScreen> createState() => _QrGeneratorScreenState();
}

class _QrGeneratorScreenState extends ConsumerState<QrGeneratorScreen> {
  String? _qrCode;
  Timer? _timer;
  int _remainingSeconds = 20;

  @override
  void initState() {
    super.initState();
    _generateAndSchedule();
  }

  Future<void> _generateAndSchedule() async {
    await _generateQr();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        _generateAndSchedule();
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  Future<void> _generateQr() async {
    final useCase = ref.read(generateQrUseCaseProvider);
    try {
      final qr = await useCase(widget.subjectId);
      setState(() {
        _qrCode = qr;
        _remainingSeconds = 20;
      });
    } catch (e) {
      logger.e('QR generation failed: $e');
      setState(() {
        _qrCode = null;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generate Attendance QR')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_qrCode != null)
              QrImageView(
                data: _qrCode!,
                version: QrVersions.auto,
                size: 200.0,
              ),
            const SizedBox(height: 24),
            Text('QR Code valid for: $_remainingSeconds seconds'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _generateAndSchedule,
              child: const Text('Refresh QR'),
            ),
          ],
        ),
      ),
    );
  }
}
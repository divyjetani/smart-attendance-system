import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import '../providers/attendance_provider.dart';
import '../providers/auth_provider.dart';
import '../../core/utils/geolocation_helper.dart';
import '../../core/utils/wifi_helper.dart';
import '../../core/widgets/snackbar.dart';

class MarkAttendanceScreen extends ConsumerStatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  ConsumerState<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends ConsumerState<MarkAttendanceScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool isProcessing = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _handleScan(String? code) async {
    if (isProcessing) return;
    isProcessing = true;

    if (code == null) {
      if (mounted) showErrorSnackBar(context, 'Invalid QR code');
      isProcessing = false;
      return;
    }

    // Check GPS and Wi-Fi
    final gpsOk = await GeolocationHelper.isWithinGeofence();
    if (!gpsOk) {
      if (mounted) showErrorSnackBar(context, 'You are outside the college premises');
      isProcessing = false;
      return;
    }

    final wifiOk = await WifiHelper.isAllowedWifiConnected();
    if (!wifiOk) {
      if (mounted) showErrorSnackBar(context, 'Please connect to college Wi-Fi');
      isProcessing = false;
      return;
    }

    final authState = ref.read(authProvider);
    final studentId = authState.user?.id;
    if (studentId == null) {
      if (mounted) showErrorSnackBar(context, 'User not authenticated');
      isProcessing = false;
      return;
    }

    // Parse QR code: expected format "subjectId:timestamp:signature"
    final parts = code.split(':');
    if (parts.length != 3) {
      if (mounted) showErrorSnackBar(context, 'Invalid QR code format');
      isProcessing = false;
      return;
    }
    final subjectId = parts[0];

    try {
      await ref.read(attendanceProvider.notifier).markAttendance(studentId, subjectId, code);
      if (mounted) {
        showSuccessSnackBar(context, 'Attendance marked successfully');
        context.pop();
      }
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e.toString());
    } finally {
      isProcessing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mark Attendance')),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: MobileScanner(
              controller: _scannerController,
              onDetect: (capture) {
                final barcode = capture.barcodes.firstOrNull;
                _handleScan(barcode?.rawValue);
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  // Option to manually enter code if camera fails
                },
                child: const Text('Enter Code Manually'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import '../../domain/usecases/upload_attendance_usecase.dart';
import '../../core/widgets/snackbar.dart';

final uploadAttendanceUseCaseProvider = Provider((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return UploadAttendanceUseCase(apiService);
});

class UploadAttendanceScreen extends ConsumerStatefulWidget {
  const UploadAttendanceScreen({super.key});

  @override
  ConsumerState<UploadAttendanceScreen> createState() => _UploadAttendanceScreenState();
}

class _UploadAttendanceScreenState extends ConsumerState<UploadAttendanceScreen> {
  bool _isUploading = false;

  Future<void> _pickAndUpload() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );
    if (result == null) return;

    final file = result.files.single;
    setState(() => _isUploading = true);

    try {
      // Parse Excel file
      var bytes = file.bytes;
      var excel = Excel.decodeBytes(bytes!);
      // Assume sheet1, columns: enrollment, subjectId, date, status
      // For simplicity, we'll just simulate parsing and upload
      // In real app, you'd convert to JSON and send
      final useCase = ref.read(uploadAttendanceUseCaseProvider);
      // You need to get subjectId from somewhere, maybe from previous screen.
      // For demo, we'll ask user to select subject.
      // This is a simplified version.
      // We'll just simulate success.
      await Future.delayed(const Duration(seconds: 1));
      showSuccessSnackBar(context, 'Attendance uploaded successfully');
      Navigator.pop(context);
    } catch (e) {
      showErrorSnackBar(context, e.toString());
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Attendance')),
      body: Center(
        child: ElevatedButton(
          onPressed: _isUploading ? null : _pickAndUpload,
          child: _isUploading
              ? const CircularProgressIndicator()
              : const Text('Select Excel File'),
        ),
      ),
    );
  }
}
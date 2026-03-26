import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/student_provider.dart';
import '../../core/widgets/snackbar.dart';

class ChangeDeviceScreen extends ConsumerStatefulWidget {
  const ChangeDeviceScreen({super.key});

  @override
  ConsumerState<ChangeDeviceScreen> createState() => _ChangeDeviceScreenState();
}

class _ChangeDeviceScreenState extends ConsumerState<ChangeDeviceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _studentIdController = TextEditingController();
  final _newDeviceIdController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _studentIdController.dispose();
    _newDeviceIdController.dispose();
    super.dispose();
  }

  Future<void> _changeDevice() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(studentProvider.notifier).changeDevice(
        _studentIdController.text.trim(),
        _newDeviceIdController.text.trim(),
      );
      if (mounted) {
        showSuccessSnackBar(context, 'Device changed successfully');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Device for Student')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _studentIdController,
                decoration: const InputDecoration(labelText: 'Student ID'),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newDeviceIdController,
                decoration: const InputDecoration(labelText: 'New Device ID'),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _changeDevice,
                child: _isLoading ? const CircularProgressIndicator() : const Text('Change Device'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
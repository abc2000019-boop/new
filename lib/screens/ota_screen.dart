import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import '../models/device.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';

class OtaScreen extends StatefulWidget {
  final Device device;
  const OtaScreen({super.key, required this.device});

  @override
  State<OtaScreen> createState() => _OtaScreenState();
}

class _OtaScreenState extends State<OtaScreen> {
  double _progress = 0;
  bool _uploading = false;
  String _status = 'Select firmware .bin file';

  Future<void> _pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['bin'],
    );
    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);
    final url = Uri.parse(
        'http://${widget.device.ip}:${AppConstants.otaPort}/update');

    setState(() {
      _uploading = true;
      _status = 'Uploading...';
      _progress = 0;
    });

    try {
      final request = http.MultipartRequest('POST', url)
        ..files.add(await http.MultipartFile.fromPath('firmware', file.path));

      final streamed = await request.send();
      final total = streamed.contentLength ?? 0;
      var received = 0;

      await for (final chunk in streamed.stream) {
        received += chunk.length;
        if (total > 0) {
          setState(() => _progress = received / total);
        }
      }

      setState(() {
        _uploading = false;
        _status = streamed.statusCode == 200
            ? 'Upload complete. Device will reboot.'
            : 'Upload failed (${streamed.statusCode})';
      });
    } catch (e) {
      setState(() {
        _uploading = false;
        _status = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OTA Update')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.system_update_alt,
                size: 100, color: AppTheme.primary.withOpacity(0.6)),
            const SizedBox(height: 20),
            Text(_status, textAlign: TextAlign.center),
            const SizedBox(height: 30),
            if (_uploading) ...[
              LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.grey[800],
                color: AppTheme.primary,
              ),
              const SizedBox(height: 8),
              Text('${(_progress * 100).toStringAsFixed(1)}%'),
            ] else
              ElevatedButton.icon(
                onPressed: _pickAndUpload,
                icon: const Icon(Icons.upload_file),
                label: const Text('Select Firmware'),
              ),
          ],
        ),
      ),
    );
  }
}
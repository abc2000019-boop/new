import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/device.dart';
import '../services/storage_service.dart';
import '../utils/theme.dart';

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController(text: 'Smart Home');
  final _ipCtrl = TextEditingController(text: '192.168.4.1');
  final _portCtrl = TextEditingController(text: '81');
  final _ssidCtrl = TextEditingController();
  final _wifiPassCtrl = TextEditingController();
  final _adminUserCtrl = TextEditingController(text: 'admin');
  final _adminPassCtrl = TextEditingController(text: '123456');

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ipCtrl.dispose();
    _portCtrl.dispose();
    _ssidCtrl.dispose();
    _wifiPassCtrl.dispose();
    _adminUserCtrl.dispose();
    _adminPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final device = Device(
      id: const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      ip: _ipCtrl.text.trim(),
      port: int.tryParse(_portCtrl.text) ?? 81,
    );

    final list = await StorageService.loadDevices();
    list.add(device);
    await StorageService.saveDevices(list);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${device.name} added successfully'),
          backgroundColor: AppTheme.accent,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Smart Home')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionTitle('Device Info', Icons.devices),
            _field(_nameCtrl, 'Device Name', Icons.label),
            _field(_ipCtrl, 'IP Address', Icons.router,
                keyboard: TextInputType.number),
            _field(_portCtrl, 'Port', Icons.numbers,
                keyboard: TextInputType.number),

            const SizedBox(height: 24),
            _sectionTitle('WiFi Settings (Optional)', Icons.wifi),
            _field(_ssidCtrl, 'SSID', Icons.wifi, required: false),
            _field(_wifiPassCtrl, 'Password', Icons.lock, required: false,
                obscure: true),

            const SizedBox(height: 24),
            _sectionTitle('Admin Credentials', Icons.admin_panel_settings),
            _field(_adminUserCtrl, 'Admin Username', Icons.person),
            _field(_adminPassCtrl, 'Admin Password', Icons.password,
                obscure: true),

            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('Save Device'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 20),
          const SizedBox(width: 8),
          Text(text,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary)),
        ],
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {bool obscure = false, bool required = true, TextInputType? keyboard}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        obscureText: obscure,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
        ),
        validator: required
            ? (v) => (v == null || v.isEmpty) ? 'Required' : null
            : null,
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../models/device.dart';
import '../services/ws_service.dart';
import '../utils/theme.dart';
import 'schedule_screen.dart';
import 'timer_screen.dart';
import 'users_screen.dart';
import 'log_screen.dart';
import 'ota_screen.dart';

class SettingsScreen extends StatelessWidget {
  final Device device;
  final WsService ws;
  const SettingsScreen({super.key, required this.device, required this.ws});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _header(device),
          const Divider(),
          _tile(context, Icons.schedule, 'Schedule',
              'Weekly ON/OFF schedule', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ScheduleScreen(ws: ws)),
            );
          }),
          _tile(context, Icons.timer, 'Timers',
              'Countdown timers per relay', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => TimerScreen(ws: ws)),
            );
          }),
          _tile(context, Icons.people, 'Users',
              'Manage users & permissions', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => UsersScreen(ws: ws)),
            );
          }),
          _tile(context, Icons.history, 'Event Log',
              'Last 24 hours activity', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => LogScreen(ws: ws)),
            );
          }),
          _tile(context, Icons.system_update, 'OTA Update',
              'Upload new firmware', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => OtaScreen(device: device)),
            );
          }),
          const Divider(),
          _tile(context, Icons.wifi, 'WiFi Settings',
              'Change network', () {
            _showWifiDialog(context);
          }),
          _tile(context, Icons.label, 'Rename Device', 'Change device name',
              () {
            _showRenameDialog(context);
          }),
        ],
      ),
    );
  }

  Widget _header(Device d) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.home_work_rounded,
                color: AppTheme.primary, size: 36),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(d.name,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('${d.ip}:${d.port}',
                    style: TextStyle(color: Colors.grey[400], fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String title, String sub,
      VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primary),
      title: Text(title),
      subtitle: Text(sub, style: TextStyle(color: Colors.grey[500])),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showWifiDialog(BuildContext context) {
    final ssid = TextEditingController();
    final pass = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('WiFi Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ssid,
              decoration: const InputDecoration(labelText: 'SSID'),
            ),
            TextField(
              controller: pass,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ws.setWifi(ssid.text, pass.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext context) {
    final ctrl = TextEditingController(text: device.name);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rename Device'),
        content: TextField(controller: ctrl),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ws.setDeviceName(ctrl.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
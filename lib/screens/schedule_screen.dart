import 'package:flutter/material.dart';
import '../services/ws_service.dart';
import '../utils/theme.dart';

class ScheduleScreen extends StatefulWidget {
  final WsService ws;
  const ScheduleScreen({super.key, required this.ws});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final List<Map<String, dynamic>> _schedules = [];

  @override
  void initState() {
    super.initState();
    widget.ws.getState();
    widget.ws.messages.listen((msg) {
      if (!mounted) return;
      if (msg['type'] == 'state' && msg['schedules'] != null) {
        _schedules.clear();
        _schedules.addAll(
            List<Map<String, dynamic>>.from(msg['schedules']));
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _editSchedule(null),
          ),
        ],
      ),
      body: _schedules.isEmpty
          ? const Center(child: Text('No schedules yet'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _schedules.length,
              itemBuilder: (_, i) => _card(_schedules[i], i),
            ),
    );
  }

  Widget _card(Map<String, dynamic> s, int idx) {
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              s['enabled'] ? AppTheme.accent : Colors.grey[800],
          child: Text(days[s['day'] ?? 0].substring(0, 1),
              style: const TextStyle(color: Colors.white, fontSize: 12)),
        ),
        title: Text('${days[s['day'] ?? 0]}'),
        subtitle: Text(
            'ON: ${_two(s['onH'])}:${_two(s['onM'])}  →  OFF: ${_two(s['offH'])}:${_two(s['offM'])}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: s['enabled'] ?? false,
              onChanged: (v) {
                widget.ws.setSchedule({...s, 'id': idx, 'enabled': v});
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: AppTheme.danger),
              onPressed: () => widget.ws.deleteSchedule(idx),
            ),
          ],
        ),
      ),
    );
  }

  String _two(dynamic v) =>
      ((v ?? 0) as int).toString().padLeft(2, '0');

  void _editSchedule(Map<String, dynamic>? existing) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New Schedule'),
        content: const Text('Configure schedule in a full editor (demo).'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.ws.setSchedule({
                'id': _schedules.length,
                'enabled': true,
                'day': 0,
                'onH': 6,
                'onM': 0,
                'offH': 22,
                'offM': 0,
                'mask': 0x3F,
              });
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
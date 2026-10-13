import 'package:flutter/material.dart';
import '../services/ws_service.dart';
import '../utils/theme.dart';

class LogScreen extends StatefulWidget {
  final WsService ws;
  const LogScreen({super.key, required this.ws});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  String _data = '';

  @override
  void initState() {
    super.initState();
    widget.ws.getLog();
    widget.ws.messages.listen((msg) {
      if (!mounted) return;
      if (msg['type'] == 'log') {
        setState(() => _data = msg['data'] ?? '');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Log'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => widget.ws.getLog(),
          ),
        ],
      ),
      body: _data.isEmpty
          ? const Center(child: Text('No events'))
          : ListView(
              padding: const EdgeInsets.all(12),
              children: _data
                  .trim()
                  .split('\n')
                  .reversed
                  .map((line) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(line,
                            style: const TextStyle(
                                fontFamily: 'monospace', fontSize: 12)),
                      ))
                  .toList(),
            ),
    );
  }
}
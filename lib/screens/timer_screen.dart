import 'package:flutter/material.dart';
import '../services/ws_service.dart';
import '../utils/theme.dart';

class TimerScreen extends StatelessWidget {
  final WsService ws;
  const TimerScreen({super.key, required this.ws});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Timers')),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: ws.messages,
        builder: (context, snapshot) {
          final timers = (snapshot.data?['timers'] as List?) ?? [];
          if (timers.isEmpty) {
            return const Center(child: Text('No timers configured'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: timers.length,
            itemBuilder: (_, i) {
              final t = timers[i];
              final running = t['running'] ?? false;
              final remaining = t['remaining'] ?? 0;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        running ? AppTheme.accent : Colors.grey[800],
                    child: Icon(
                      running ? Icons.play_arrow : Icons.timer,
                      color: Colors.white,
                    ),
                  ),
                  title: Text('Relay ${(t['relay'] ?? 0) + 1}'),
                  subtitle: Text(
                      'Duration: ${t['duration']}s  •  Remaining: ${remaining}s'),
                  trailing: Switch(
                    value: running,
                    onChanged: (v) {
                      if (v) {
                        ws.startTimer(t['id']);
                      } else {
                        ws.stopTimer(t['id']);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
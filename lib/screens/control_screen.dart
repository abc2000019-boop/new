import 'package:flutter/material.dart';
import '../models/device.dart';
import '../services/ws_service.dart';
import '../utils/theme.dart';
import 'settings_screen.dart';

class ControlScreen extends StatefulWidget {
  final Device device;
  final WsService ws;
  const ControlScreen({super.key, required this.device, required this.ws});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  int _masterDelay = 300;

  @override
  void initState() {
    super.initState();
    widget.ws.messages.listen(_onMessage);
    widget.ws.getState();
  }

  void _onMessage(Map<String, dynamic> msg) {
    if (!mounted) return;
    if (msg['type'] == 'state') {
      final relays = msg['relays'] as List?;
      if (relays != null) {
        for (final r in relays) {
          final id = r['id'] as int;
          if (id < widget.device.relays.length) {
            widget.device.relays[id].name = r['name'];
            widget.device.relays[id].state = r['state'];
          }
        }
        setState(() {});
      }
    } else if (msg['type'] == 'relay_changed') {
      final id = msg['id'] as int;
      final state = msg['state'] as bool;
      if (id < widget.device.relays.length) {
        widget.device.relays[id].state = state;
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.device;
    final online = d.online;

    return Scaffold(
      appBar: AppBar(
        title: Text(d.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(device: d, ws: widget.ws),
                ),
              );
            },
          ),
        ],
      ),
      body: !online
          ? _offlineView()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _masterSwitch(),
                  const SizedBox(height: 20),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: d.relays.length,
                    itemBuilder: (_, i) => _relayButton(d.relays[i]),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _offlineView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off, size: 80, color: AppTheme.danger.withOpacity(0.7)),
          const SizedBox(height: 16),
          const Text('Device Offline',
              style: TextStyle(fontSize: 22, color: AppTheme.danger)),
          const SizedBox(height: 8),
          Text('Check connection to ${widget.device.ip}',
              style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _masterSwitch() {
    final allOn = widget.device.relays.every((r) => r.state);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (allOn ? AppTheme.accent : AppTheme.danger).withOpacity(0.4),
        ),
      ),
      child: Row(
        children: [
          Icon(
            allOn ? Icons.power_settings_new : Icons.power_off,
            color: allOn ? AppTheme.accent : AppTheme.danger,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Master Switch',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Text('${widget.device.relays.where((r) => r.state).length}/6 active',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: allOn,
            activeColor: AppTheme.accent,
            onChanged: (v) {
              widget.ws.setAllRelays(v, delayMs: _masterDelay);
              setState(() {
                for (final r in widget.device.relays) r.state = v;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _relayButton(dynamic relay) {
    final on = relay.state;
    return GestureDetector(
      onTap: () {
        widget.ws.setRelay(relay.id, !on);
        setState(() => relay.state = !on);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          gradient: on
              ? LinearGradient(
                  colors: [
                    AppTheme.accent.withOpacity(0.25),
                    AppTheme.accent.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [Colors.grey[850]!, Colors.grey[900]!],
                ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: on ? AppTheme.accent : Colors.grey[800]!,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              on ? Icons.lightbulb : Icons.lightbulb_outline,
              size: 42,
              color: on ? AppTheme.accent : Colors.grey[600],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                relay.name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: on ? Colors.white : Colors.grey[400],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              decoration: BoxDecoration(
                color: on ? AppTheme.accent : Colors.grey[800],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                on ? 'ON' : 'OFF',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: on ? AppTheme.bgDark : Colors.grey[500],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
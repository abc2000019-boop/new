import 'package:flutter/material.dart';
import '../models/device.dart';
import '../services/storage_service.dart';
import '../services/ws_service.dart';
import '../utils/theme.dart';
import 'add_device_screen.dart';
import 'control_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Device> _devices = [];
  final Map<String, WsService> _services = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await StorageService.loadDevices();
    setState(() => _devices = list);
    for (final d in list) {
      _connectDevice(d);
    }
  }

  void _connectDevice(Device d) {
    if (_services.containsKey(d.id)) return;
    final ws = WsService(d);
    _services[d.id] = ws;
    ws.connectionStream.listen((online) {
      if (!mounted) return;
      setState(() => d.online = online);
    });
    ws.messages.listen((msg) {
      if (!mounted) return;
      if (msg['type'] == 'relay_changed') {
        final id = msg['id'] as int;
        final state = msg['state'] as bool;
        if (id < d.relays.length) d.relays[id].state = state;
        setState(() {});
      }
    });
    ws.connect();
  }

  @override
  void dispose() {
    for (final s in _services.values) s.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart1 Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Add Smart Home',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddDeviceScreen()),
              );
              _load();
            },
          ),
        ],
      ),
      body: _devices.isEmpty
          ? _emptyState()
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: _devices.length,
              itemBuilder: (_, i) => _deviceCard(_devices[i]),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddDeviceScreen()),
          );
          _load();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add ESP'),
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.devices_other, size: 100, color: Colors.grey[700]),
          const SizedBox(height: 16),
          Text('No Devices Yet',
              style: TextStyle(fontSize: 22, color: Colors.grey[400])),
          const SizedBox(height: 8),
          Text('Tap + to add your Smart Home',
              style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _deviceCard(Device d) {
    final online = d.online;
    return GestureDetector(
      onTap: online
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ControlScreen(
                    device: d,
                    ws: _services[d.id]!,
                  ),
                ),
              );
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: online ? AppTheme.cardDark : Colors.grey[900],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: online ? AppTheme.primary.withOpacity(0.4) : Colors.grey[800]!,
            width: 1.5,
          ),
          boxShadow: online
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.15),
                    blurRadius: 12,
                    spreadRadius: 2,
                  )
                ]
              : null,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: online
                        ? AppTheme.primary.withOpacity(0.15)
                        : Colors.grey[800],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.home_work_rounded,
                    color: online ? AppTheme.primary : Colors.grey[600],
                    size: 28,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: online ? AppTheme.accent : AppTheme.danger,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (online ? AppTheme.accent : AppTheme.danger)
                            .withOpacity(0.5),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              d.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: online ? Colors.white : Colors.grey[500],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              online ? d.ip : 'Offline',
              style: TextStyle(
                fontSize: 13,
                color: online ? Colors.grey[400] : AppTheme.danger,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.power_settings_new,
                    size: 14,
                    color: online ? AppTheme.accent : Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${d.relays.where((r) => r.state).length}/6 ON',
                  style: TextStyle(
                    fontSize: 12,
                    color: online ? Colors.grey[300] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
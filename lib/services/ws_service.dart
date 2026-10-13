import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:logger/logger.dart';
import '../models/device.dart';

class WsService {
  final Device device;
  WebSocketChannel? _channel;
  final _logger = Logger();

  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get messages => _messageController.stream;

  final _connectionController = StreamController<bool>.broadcast();
  Stream<bool> get connectionStream => _connectionController.stream;

  Timer? _reconnectTimer;
  Timer? _pingTimer;
  bool _shouldReconnect = true;
  bool _isConnected = false;

  WsService(this.device);

  bool get isConnected => _isConnected;

  // ==================== الاتصال ====================
  Future<void> connect() async {
    _shouldReconnect = true;
    await _doConnect();
  }

  Future<void> _doConnect() async {
    try {
      _logger.i('Connecting to ${device.wsUrl}');
      _channel = WebSocketChannel.connect(Uri.parse(device.wsUrl));
      await _channel!.ready;

      _isConnected = true;
      _connectionController.add(true);
      _logger.i('Connected to ${device.name}');

      // Ping كل 20 ثانية
      _pingTimer?.cancel();
      _pingTimer = Timer.periodic(const Duration(seconds: 20), (_) {
        _send({'cmd': 'ping'});
      });

      _channel!.stream.listen(
        (data) {
          try {
            final json = jsonDecode(data as String) as Map<String, dynamic>;
            _messageController.add(json);
          } catch (e) {
            _logger.e('Parse error: $e');
          }
        },
        onDone: _onDisconnected,
        onError: (e) {
          _logger.e('WS error: $e');
          _onDisconnected();
        },
      );
    } catch (e) {
      _logger.e('Connect failed: $e');
      _onDisconnected();
    }
  }

  void _onDisconnected() {
    if (_isConnected) {
      _isConnected = false;
      _connectionController.add(false);
      _logger.w('Disconnected from ${device.name}');
    }
    _pingTimer?.cancel();
    if (_shouldReconnect) {
      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(const Duration(seconds: 3), () {
        _doConnect();
      });
    }
  }

  // ==================== الإرسال ====================
  void _send(Map<String, dynamic> data) {
    if (_channel == null || !_isConnected) return;
    try {
      _channel!.sink.add(jsonEncode(data));
    } catch (e) {
      _logger.e('Send error: $e');
    }
  }

  // ==================== API ====================
  void login(String user, String pass) =>
      _send({'cmd': 'login', 'user': user, 'pass': pass});

  void getState() => _send({'cmd': 'get_state'});

  void setRelay(int id, bool state) =>
      _send({'cmd': 'set_relay', 'id': id, 'state': state});

  void setAllRelays(bool state, {int delayMs = 0}) => _send({
        'cmd': 'set_all_relays',
        'state': state,
        'delay': delayMs,
      });

  void setRelayName(int id, String name) =>
      _send({'cmd': 'set_relay_name', 'id': id, 'name': name});

  void setDeviceName(String name) =>
      _send({'cmd': 'set_device_name', 'name': name});

  void setWifi(String ssid, String pass) =>
      _send({'cmd': 'set_wifi', 'ssid': ssid, 'pass': pass});

  void setSchedule(Map<String, dynamic> data) =>
      _send({'cmd': 'set_schedule', ...data});

  void deleteSchedule(int id) =>
      _send({'cmd': 'delete_schedule', 'id': id});

  void setTimer(Map<String, dynamic> data) =>
      _send({'cmd': 'set_timer', ...data});

  void startTimer(int id) => _send({'cmd': 'start_timer', 'id': id});
  void stopTimer(int id) => _send({'cmd': 'stop_timer', 'id': id});

  void listUsers() => _send({'cmd': 'list_users'});
  void addUser(Map<String, dynamic> data) =>
      _send({'cmd': 'add_user', ...data});
  void updateUser(Map<String, dynamic> data) =>
      _send({'cmd': 'update_user', ...data});
  void deleteUser(String username) =>
      _send({'cmd': 'delete_user', 'user': username});

  void getLog() => _send({'cmd': 'get_log'});
  void otaStart() => _send({'cmd': 'ota_start'});

  // ==================== الإغلاق ====================
  void dispose() {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _pingTimer?.cancel();
    _channel?.sink.close();
    _messageController.close();
    _connectionController.close();
  }
}
import 'relay.dart';

class Device {
  final String id;           // UUID داخلي
  String name;               // اسم ESP / Smart Home
  String ip;
  int port;
  String? macAddress;
  bool online;
  bool authenticated;
  String? username;
  bool isAdmin;
  List<Relay> relays;
  DateTime? lastSeen;

  Device({
    required this.id,
    required this.name,
    required this.ip,
    this.port = 81,
    this.macAddress,
    this.online = false,
    this.authenticated = false,
    this.username,
    this.isAdmin = false,
    List<Relay>? relays,
    this.lastSeen,
  }) : relays = relays ??
            List.generate(
              6,
              (i) => Relay(id: i, name: 'Relay ${i + 1}', state: false),
            );

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'],
      name: json['name'],
      ip: json['ip'],
      port: json['port'] ?? 81,
      macAddress: json['mac'],
      relays: (json['relays'] as List?)
              ?.map((e) => Relay.fromJson(e))
              .toList() ??
          null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'ip': ip,
        'port': port,
        'mac': macAddress,
        'relays': relays.map((r) => r.toJson()).toList(),
      };

  String get wsUrl => 'ws://$ip:$port';
}
class Relay {
  final int id;
  String name;
  bool state;

  Relay({
    required this.id,
    required this.name,
    required this.state,
  });

  factory Relay.fromJson(Map<String, dynamic> json) {
    return Relay(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Relay ${(json['id'] ?? 0) + 1}',
      state: json['state'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'state': state,
      };

  Relay copyWith({String? name, bool? state}) => Relay(
        id: id,
        name: name ?? this.name,
        state: state ?? this.state,
      );
}
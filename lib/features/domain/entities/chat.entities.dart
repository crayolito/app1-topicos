class Chat {
  final String id;
  final String nombre;
  final String mensaje;
  final DateTime fecha;

  Chat({
    required this.id,
    required this.mensaje,
    required this.nombre,
    required this.fecha,
  });

  // Convertir de objeto a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'mensaje': mensaje,
      'fecha': fecha.toIso8601String(),
    };
  }

  // Convertir de JSON a objeto (constructor factory)
  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'],
      nombre: json['nombre'],
      mensaje: json['mensaje'],
      fecha: DateTime.parse(json['fecha']),
    );
  }
}

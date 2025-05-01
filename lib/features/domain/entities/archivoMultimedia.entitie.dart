enum TipoArchivo { foto, video, audio, otro }

class ArchivoMultimedia {
  final String ruta;
  final String nombre;
  final TipoArchivo tipo;
  final DateTime fechaCreacion;

  ArchivoMultimedia({
    required this.ruta,
    required this.nombre,
    required this.tipo,
    required this.fechaCreacion,
  });

  // Convertir a JSON para guardar
  Map<String, dynamic> toJson() {
    return {
      'ruta': ruta,
      'nombre': nombre,
      'tipo': tipo.toString(),
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }

  // Crear desde JSON
  factory ArchivoMultimedia.fromJson(Map<String, dynamic> json) {
    return ArchivoMultimedia(
      ruta: json['ruta'],
      nombre: json['nombre'],
      tipo: _stringToTipoArchivo(json['tipo']),
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
    );
  }

  // Helper para convertir string a enum
  static TipoArchivo _stringToTipoArchivo(String tipoStr) {
    if (tipoStr.contains('TipoArchivo.foto')) return TipoArchivo.foto;
    if (tipoStr.contains('TipoArchivo.video')) return TipoArchivo.video;
    if (tipoStr.contains('TipoArchivo.audio')) return TipoArchivo.audio;
    return TipoArchivo.otro;
  }
}

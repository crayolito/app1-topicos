import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'generales.service.dart'; // Importamos el servicio GeneralesService

class FragmentoTexto {
  final int id;
  final String texto;

  FragmentoTexto({required this.id, required this.texto});

  factory FragmentoTexto.fromMap(Map<String, dynamic> map) {
    return FragmentoTexto(id: map['id'], texto: map['texto']);
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'texto': texto};
  }

  @override
  String toString() {
    return 'FragmentoTexto{id: $id, texto: $texto}';
  }
}

class ServicioBaseDatos {
  static final ServicioBaseDatos _instancia = ServicioBaseDatos._interno();
  static Database? _database;
  bool _verificandoFragmentos = false;

  // Constructor privado
  ServicioBaseDatos._interno();

  // Constructor de fábrica
  factory ServicioBaseDatos() {
    return _instancia;
  }

  // Obtener instancia de la base de datos
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();

    // Verificar y cargar datos si es necesario
    await _verificarYCargarFragmentos();

    return _database!;
  }

  // Inicializar la base de datos
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'fragmentos_texto.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  // Crear tablas en la base de datos
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE fragmentos (
        id INTEGER PRIMARY KEY,
        texto TEXT
      )
    ''');
  }

  // Verificar si la base de datos está vacía y cargar fragmentos si es necesario
  Future<void> _verificarYCargarFragmentos() async {
    if (_verificandoFragmentos)
      return; // Evitar múltiples verificaciones simultáneas

    _verificandoFragmentos = true;

    try {
      final Database db = await database;

      // Verificar si hay datos en la tabla
      final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM fragmentos'),
      );

      // Si no hay datos, obtenerlos del servidor
      if (count == 0) {
        debugPrint(
          'Base de datos vacía. Obteniendo fragmentos del servidor...',
        );
        try {
          // Obtener los fragmentos del servidor usando GeneralesService
          final fragmentos = await GeneralesService.obtenerBaseConocimiento();

          // Actualizar la base de datos local con los fragmentos obtenidos
          await actualizarDatosDesdeServidor(fragmentos);

          debugPrint('Fragmentos cargados exitosamente: ${fragmentos.length}');
        } catch (e) {
          debugPrint('Error al obtener fragmentos del servidor: $e');
          // No lanzamos excepción para no interrumpir la aplicación
        }
      } else {
        debugPrint('La base de datos ya contiene $count fragmentos.');
      }
    } catch (e) {
      debugPrint('Error al verificar/cargar fragmentos: $e');
    } finally {
      _verificandoFragmentos = false;
    }
  }

  // Actualizar la base de datos local con datos del servidor
  Future<void> actualizarDatosDesdeServidor(
    List<Map<String, dynamic>> fragmentos,
  ) async {
    try {
      final Database db = await database;

      // Verificar si hay datos en la tabla
      final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM fragmentos'),
      );

      // Si no hay datos, insertarlos
      if (count == 0) {
        // Usar transacción para mejorar rendimiento
        await db.transaction((txn) async {
          Batch batch = txn.batch();
          for (var fragmento in fragmentos) {
            batch.insert('fragmentos', {
              'id': fragmento['id'],
              'texto': fragmento['contenido'],
            });
          }
          await batch.commit(noResult: true);
        });
        debugPrint('Fragmentos insertados en la base de datos local');
      } else {
        debugPrint(
          'La base de datos local ya contiene datos. No se realizó ninguna acción.',
        );
      }
    } catch (e) {
      debugPrint('Error al actualizar la base de datos local: $e');
      throw Exception('Error al actualizar la base de datos local: $e');
    }
  }

  // Método para forzar una recarga de fragmentos desde el servidor
  Future<void> forzarRecargaFragmentos() async {
    try {
      final Database db = await database;

      // Eliminar todos los fragmentos existentes
      await db.delete('fragmentos');
      debugPrint('Fragmentos eliminados para recarga');

      // Obtener y cargar nuevos fragmentos
      await _verificarYCargarFragmentos();
    } catch (e) {
      debugPrint('Error al forzar recarga de fragmentos: $e');
      throw Exception('Error al forzar recarga de fragmentos: $e');
    }
  }

  // Obtener todos los fragmentos
  Future<List<FragmentoTexto>> obtenerTodosFragmentos() async {
    try {
      // Asegurar que la base de datos tenga datos
      await _verificarYCargarFragmentos();

      final Database db = await database;
      final List<Map<String, dynamic>> maps = await db.query('fragmentos');

      return List.generate(maps.length, (i) {
        return FragmentoTexto.fromMap({
          'id': maps[i]['id'],
          'texto': maps[i]['texto'],
        });
      });
    } catch (e) {
      debugPrint('Error al obtener todos los fragmentos: $e');
      throw Exception('Error al obtener todos los fragmentos: $e');
    }
  }

  // Búsqueda flexible de fragmentos
  Future<List<FragmentoTexto>> buscarFragmentos(String query) async {
    try {
      if (query.trim().isEmpty) {
        return [];
      }

      // Asegurar que la base de datos tenga datos
      await _verificarYCargarFragmentos();

      final Database db = await database;

      // Preparar el query para búsqueda insensible a mayúsculas/minúsculas
      // y admitir coincidencia parcial
      String queryNormalizado = _normalizarTexto(query);

      // Usar LIKE con % para buscar coincidencias parciales
      final List<Map<String, dynamic>> maps = await db.rawQuery(
        '''
        SELECT id, texto 
        FROM fragmentos 
        WHERE texto LIKE ?
      ''',
        ['%$queryNormalizado%'],
      );

      // Si no hay resultados con la búsqueda exacta, intentar búsqueda más flexible
      if (maps.isEmpty) {
        // Obtener todos los fragmentos para búsqueda manual más flexible
        final List<Map<String, dynamic>> allFragments = await db.query(
          'fragmentos',
        );

        // Dividir la consulta en palabras clave
        List<String> keywords =
            queryNormalizado
                .split(' ')
                .where((keyword) => keyword.isNotEmpty)
                .toList();

        // Filtrar fragmentos que contengan al menos una palabra clave
        List<Map<String, dynamic>> resultados = [];

        for (var fragmento in allFragments) {
          String textoNormalizado = _normalizarTexto(fragmento['texto']);

          // Verificar si el fragmento contiene al menos una palabra clave
          bool contienePalabraClave = keywords.any(
            (keyword) => textoNormalizado.contains(keyword),
          );

          if (contienePalabraClave) {
            resultados.add(fragmento);
          }
        }

        return resultados
            .map(
              (map) => FragmentoTexto.fromMap({
                'id': map['id'],
                'texto': map['texto'],
              }),
            )
            .toList();
      }

      return maps
          .map(
            (map) => FragmentoTexto.fromMap({
              'id': map['id'],
              'texto': map['texto'],
            }),
          )
          .toList();
    } catch (e) {
      debugPrint('Error al buscar fragmentos: $e');
      throw Exception('Error al buscar fragmentos: $e');
    }
  }

  // Método auxiliar para normalizar texto (eliminar acentos, convertir a minúsculas)
  String _normalizarTexto(String texto) {
    if (texto == null) return '';

    // Convertir a minúsculas
    String resultado = texto.toLowerCase();

    // Reemplazar caracteres acentuados
    Map<String, String> acentos = {
      'á': 'a',
      'é': 'e',
      'í': 'i',
      'ó': 'o',
      'ú': 'u',
      'à': 'a',
      'è': 'e',
      'ì': 'i',
      'ò': 'o',
      'ù': 'u',
      'ä': 'a',
      'ë': 'e',
      'ï': 'i',
      'ö': 'o',
      'ü': 'u',
      'â': 'a',
      'ê': 'e',
      'î': 'i',
      'ô': 'o',
      'û': 'u',
      'ñ': 'n',
    };

    acentos.forEach((key, value) {
      resultado = resultado.replaceAll(key, value);
    });

    // Eliminar caracteres especiales y espacios extras
    resultado = resultado.replaceAll(RegExp(r'[^\w\s]'), '');
    resultado = resultado.replaceAll(RegExp(r'\s+'), ' ').trim();

    return resultado;
  }
}

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:topicos_app1/features/presentation/historial/screens/home.screen.dart';

class GeneralesService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl:
          'http://192.168.1.107:5001', // Reemplaza con la URL de tu backend
    ),
  );

  /// Envía un archivo de audio al servidor para su transcripción y procesamiento
  ///
  /// [audioFilePath] - Ruta completa al archivo de audio
  /// [idioma] - Código del idioma (por defecto 'es-ES')
  ///
  /// Retorna un Map con la respuesta del servidor que incluye:
  /// - textoTranscrito: Texto transcrito del audio
  /// - respuestaDirecta: Respuesta generada por el asistente
  /// - fueraDeContexto: Indica si la consulta está fuera del contexto del asistente
  static Future<String> enviarAudioParaProcesar({
    required String audioFilePath,
    String idioma = 'es-ES',
  }) async {
    try {
      // Verificar que el archivo exista
      final file = File(audioFilePath);
      if (!await file.exists()) {
        throw Exception('El archivo de audio no existe: $audioFilePath');
      }

      // Crear el FormData para la petición multipart
      final formData = FormData.fromMap({
        'archivo': await MultipartFile.fromFile(
          audioFilePath,
          filename: basename(audioFilePath),
        ),
        'idioma': idioma,
        'formato': 'MP3', // Forzar formato MP3 para archivos m4a
        'tasa_muestreo': '44100', // Usar tasa de muestreo adecuada para m4a
      });

      // Realizar la petición POST
      final response = await _dio.post(
        '/api/audio',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      // Verificar respuesta
      if (response.statusCode == 200) {
        // print('Respuesta del servidor: ${response.data['texto']}');
        return response.data['texto'];
      } else {
        throw Exception(
          'Error en la respuesta del servidor: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      // Manejo de errores específicos de Dio
      String mensaje = 'Error de conexión';

      if (e.response != null) {
        // El servidor respondió con un código de error
        mensaje =
            e.response?.data?['error'] ??
            'Error del servidor: ${e.response?.statusCode}';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        mensaje = 'Tiempo de conexión agotado';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        mensaje = 'Tiempo de respuesta agotado';
      }

      debugPrint('Error al enviar audio: $mensaje');
      throw Exception(mensaje);
    } catch (e) {
      // Otros errores
      debugPrint('Error inesperado al enviar audio: $e');
      throw Exception('Error inesperado: $e');
    }
  }

  /// Envía una consulta jurídica al servidor para obtener respuesta del asistente
  ///
  /// [pregunta] - Texto de la consulta jurídica
  /// [tipoModelo] - Tipo de modelo a utilizar (por defecto 'normal')
  /// [historialConversacion] - Lista de mensajes previos en la conversación (opcional)
  ///
  /// Retorna un Map con la respuesta del servidor que incluye:
  /// - respuestaDirecta: Respuesta generada por el asistente
  /// - fueraDeContexto: Indica si la consulta está fuera del contexto jurídico
  static Future<Map<String, dynamic>> enviarConsultaJuridica({
    required String pregunta,
    String tipoModelo = 'normal',
    List<ChatTemporales> historialConversacion = const [],
  }) async {
    try {
      // Convertir el historial de conversación a JSON
      final List<Map<String, dynamic>> historialConversacionJson =
          historialConversacion.map((chat) {
            return {'quien': chat.quien, 'mensaje': chat.mensaje};
          }).toList();

      // Preparar los datos de la petición
      final Map<String, dynamic> datos = {
        'pregunta': pregunta,
        'tipo-modelo': tipoModelo,
        'historial-conversacion': historialConversacionJson,
      };

      // Realizar la petición POST
      final response = await _dio.post(
        '/api/consulta',
        data: datos,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      // Verificar respuesta
      if (response.statusCode == 200) {
        final data = response.data;

        // Verificar qué tipo de estructura tiene la respuesta
        if (data is Map) {
          if (data.containsKey('respuesta')) {
            // Obtener la respuesta principal
            String textoRespuesta = data['respuesta'] ?? '';

            // Obtener las diferencias de temas relacionados
            String diferencias = data['diferencias'] ?? '';
            return {'respuesta': textoRespuesta, 'diferencias': diferencias};
          } else if (data.containsKey('respuestaAmigo')) {
            String textoRespuesta = data['respuestaAmigo'];

            // Si hay análisis legal, añadirlo
            if (data.containsKey('análisisLegal') &&
                data['análisisLegal'] != null) {
              textoRespuesta += "\n\n" + data['análisisLegal'];
            }

            return {'respuesta': textoRespuesta, 'diferencias': ""};
          } else if (data.containsKey('respuestaDirecta')) {
            return {'respuesta': data['respuestaDirecta'], 'diferencias': ""};
          } else {
            // Si ninguna de las claves esperadas está presente
            return {
              'respuesta': "No se pudo procesar la respuesta correctamente.",
              'diferencias': "",
            };
          }
        } else if (data is String) {
          // Si ya es un String, devolverlo directamente
          return {'respuesta': data, 'diferencias': ""};
        } else {
          // Convertir otros tipos a String
          return {'respuesta': data.toString(), 'diferencias': ""};
        }
      } else {
        throw Exception(
          'Error en la respuesta del servidor: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      // Manejo de errores específicos de Dio
      String mensaje = 'Error de conexión';
      if (e.response != null) {
        // El servidor respondió con un código de error
        mensaje =
            e.response?.data?['error'] ??
            'Error del servidor: ${e.response?.statusCode}';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        mensaje = 'Tiempo de conexión agotado';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        mensaje = 'Tiempo de respuesta agotado';
      }
      debugPrint('Error al enviar consulta: $mensaje');
      throw Exception(mensaje);
    } catch (e) {
      // Otros errores
      debugPrint('Error inesperado al enviar consulta: $e');
      throw Exception('Error inesperado: $e');
    }
  }

  /// Obtiene todos los fragmentos de la base de conocimiento
  ///
  /// Retorna una lista de fragmentos con su ID y contenido
  static Future<List<Map<String, dynamic>>> obtenerBaseConocimiento() async {
    try {
      // Realizar la petición GET
      final response = await _dio.get(
        '/api/base_conocimiento',
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      // Verificar respuesta
      if (response.statusCode == 200) {
        // La respuesta debe ser una lista de tuplas (id, contenido)
        final List<dynamic> data = response.data;

        // Convertir los datos a un formato más amigable para Flutter
        final List<Map<String, dynamic>> fragmentos =
            data.map((fragmento) {
              // Cada fragmento es una lista donde el primer elemento es el ID
              // y el segundo elemento es el contenido
              return {'id': fragmento[0], 'contenido': fragmento[1]};
            }).toList();

        return fragmentos;
      } else {
        throw Exception(
          'Error en la respuesta del servidor: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      // Manejo de errores específicos de Dio
      String mensaje = 'Error de conexión';
      if (e.response != null) {
        // El servidor respondió con un código de error
        mensaje =
            e.response?.data?['error'] ??
            'Error del servidor: ${e.response?.statusCode}';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        mensaje = 'Tiempo de conexión agotado';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        mensaje = 'Tiempo de respuesta agotado';
      }
      debugPrint('Error al obtener base de conocimiento: $mensaje');
      throw Exception(mensaje);
    } catch (e) {
      // Otros errores
      debugPrint('Error inesperado al obtener base de conocimiento: $e');
      throw Exception('Error inesperado: $e');
    }
  }
}

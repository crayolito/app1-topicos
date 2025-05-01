import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:topicos_app1/config/services/storage-impl.service.dart';
import 'package:topicos_app1/features/domain/entities/archivoMultimedia.entitie.dart';
import 'package:topicos_app1/features/domain/entities/chat.entities.dart';
import 'package:topicos_app1/features/presentation/historial/helpers.dart';
import 'package:topicos_app1/features/presentation/historial/screens/home.screen.dart';
import 'package:topicos_app1/features/services/generales.service.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final servicioLocalStorage = ServicioAlmacenamientoImpl();
  TextEditingController controllerInputChat = TextEditingController();

  TextEditingController get controllerInput => controllerInputChat;

  String get textoInputChat => controllerInputChat.text;

  set textoInputChat(String texto) {
    controllerInputChat.text = texto;
  }

  ChatBloc() : super(ChatState()) {
    on<OnContruccionDatos>((event, emit) async {
      emit(state.copyWith(estadoDatos: EstadoDatos.cargando));

      try {
        // Cargar historial de chats
        final historiaChatJson = await servicioLocalStorage.obtenerDato(
          'historialChats',
        );
        List<Chat> historialChats = [];

        if (historiaChatJson != null && historiaChatJson.isNotEmpty) {
          // Convertir de JSON a lista de objetos Chat
          final List<dynamic> listaDecodificada = jsonDecode(historiaChatJson);
          historialChats =
              listaDecodificada.map((item) => Chat.fromJson(item)).toList();
        }

        // Cargar historial de búsquedas
        final historialBusquedasJson = await servicioLocalStorage.obtenerDato(
          'historialBusquedas',
        );
        List<String> historialBusquedas = [];

        if (historialBusquedasJson != null &&
            historialBusquedasJson.isNotEmpty) {
          // Convertir de JSON a lista de strings
          historialBusquedas = List<String>.from(
            jsonDecode(historialBusquedasJson),
          );
        }

        print('Historial de chats cargado: ${historialChats.length} elementos');

        // Emitir el estado con los datos cargados
        emit(
          state.copyWith(
            estadoDatos: EstadoDatos.exito,
            historialChats: historialChats,
            historialBusquedas: historialBusquedas,
          ),
        );
      } catch (error) {
        print('Error al cargar datos: $error');
        emit(state.copyWith(estadoDatos: EstadoDatos.error));
      }
    });

    on<OnChagendEstadoConsulta>((event, emit) {
      emit(state.copyWith(estadoConsulta: event.estadoConsulta));
    });

    on<OnChagendPreguntaConsulta>((event, emit) {
      // Actualizar el controlador de texto con la nueva pregunta
      textoInputChat = event.preguntaConsulta;
      emit(
        state.copyWith(
          estadoConsulta: EstadoConsulta.exito,
          preguntaConsulta: event.preguntaConsulta,
        ),
      );
    });

    on<OnChagendTipoModeloIA>((event, emit) {
      emit(state.copyWith(tipoModeloIA: event.tipoModeloIA));
    });

    on<OnChagendTipoRespuesta>((event, emit) {
      emit(state.copyWith(tipoRespuesta: event.tipoRespuesta));
    });

    on<OnChagendHistorialBusquedas>((event, emit) {
      emit(state.copyWith(historialBusquedas: event.historialBusquedas));
    });

    on<OnProcesoConsutalIA>((event, emit) async {
      emit(state.copyWith(estadoConsulta: EstadoConsulta.procesando));
      try {
        String tipoModeloString = "";
        if (state.tipoModeloIA == TipoModeloIA.basico) {
          tipoModeloString = "basico";
        } else if (state.tipoModeloIA == TipoModeloIA.avanzado) {
          tipoModeloString = "avanzado";
        }

        // Obtener la respuesta del servicio
        final respuestaMap = await GeneralesService.enviarConsultaJuridica(
          pregunta: event.preguntaConsulta,
          historialConversacion: state.chatTemporales,
          tipoModelo: tipoModeloString,
        );

        // Procesar la respuesta y formatearla correctamente
        final String respuestaTextoOriginal = respuestaMap['respuesta'] ?? '';
        String respuestaTextoFormateada = '';

        // Formatear el texto principal, reemplazando los marcadores **texto** por formato adecuado
        respuestaTextoFormateada = respuestaTextoOriginal
            .replaceAll(
              RegExp(r'\s{2,}'),
              ' ',
            ) // Reemplazar espacios múltiples por un solo espacio
            .replaceAllMapped(RegExp(r'\*\*(.*?)\*\*'), (match) {
              String titulo = match.group(1) ?? '';
              // Eliminar dos puntos si ya existen en el título para evitar duplicación
              if (titulo.endsWith(':')) {
                titulo = titulo.substring(0, titulo.length - 1);
              }
              return '\n\n$titulo:\n';
            });

        // Separar claramente el contenido adicional que no está relacionado con los artículos
        final List<String> parrafos = respuestaTextoFormateada.split('\n\n');
        respuestaTextoFormateada = '';
        bool contenidoAdicionalEncontrado = false;

        for (int i = 0; i < parrafos.length; i++) {
          String parrafo = parrafos[i];

          // Detectar si este párrafo ya no habla de artículos específicos
          // y es contenido adicional (consejos generales)
          if (!contenidoAdicionalEncontrado &&
              !parrafo.contains('Artículo') &&
              i > 0 &&
              parrafo.length > 50) {
            // Párrafos largos sin mencionar artículos
            respuestaTextoFormateada +=
                '\n\n---- RECOMENDACIONES GENERALES ----\n\n';
            contenidoAdicionalEncontrado = true;
          }

          respuestaTextoFormateada +=
              parrafo + (i < parrafos.length - 1 ? '\n\n' : '');
        }

        // Obtener y formatear las diferencias
        String diferenciasTitulo =
            'DIFERENCIAS CLAVES DE ESTAS NORMATIVAS:\n\n';
        String diferenciasTexto = respuestaMap['diferencias'] ?? '';
        String diferenciasFormateadas = '';

        if (diferenciasTexto.trim().isNotEmpty) {
          // Dividir por "Artículo" para identificar cada caso
          List<String> partesDiferencias = diferenciasTexto.split('Artículo');

          for (int i = 0; i < partesDiferencias.length; i++) {
            String parte = partesDiferencias[i].trim();
            if (parte.isNotEmpty) {
              diferenciasFormateadas += '• Artículo $parte\n\n';
            }
          }
        }

        // Texto final completo con formato
        String textoFinalFormateado = respuestaTextoFormateada;

        // Solo añadir diferencias si existen
        if (diferenciasTexto.isNotEmpty) {
          textoFinalFormateado =
              '$respuestaTextoFormateada\n\n$diferenciasTitulo$diferenciasFormateadas';
        }

        // Crear nuevos mensajes para la lista de chat temporales
        final List<ChatTemporales> nuevosChats = List.from(
          state.chatTemporales,
        );

        // Agregar mensaje del usuario
        nuevosChats.add(
          ChatTemporales(
            quien: 'USUARIO',
            mensaje: event.preguntaConsulta,
            temasRelacionados: [],
          ),
        );

        // Agregar respuesta del asistente con formato mejorado
        nuevosChats.add(
          ChatTemporales(
            quien: 'RODALEX',
            mensaje: textoFinalFormateado,
            temasRelacionados:
                diferenciasTexto.isEmpty ? [] : diferenciasTexto.split('. '),
          ),
        );

        // Emitir el estado con la respuesta formateada
        emit(
          state.copyWith(
            estadoConsulta: EstadoConsulta.exito,
            respuestaConsulta: textoFinalFormateado,
            chatTemporales: nuevosChats,
          ),
        );
      } catch (error) {
        print('Error en la consulta: $error');
        emit(state.copyWith(estadoConsulta: EstadoConsulta.error));
      }
    });

    on<OnChagendEstadoProcesoAudio>((event, emit) {
      emit(state.copyWith(estadoProcesoAudio: event.estadoProcesoAudio));
      HelperHistorial.actualizarColorBarraNavegacion(event.estadoProcesoAudio);
    });

    on<OnChagendTipoPregunta>((event, emit) {
      emit(state.copyWith(tipoPregunta: event.tipoPregunta));
    });
  }

  @override
  Future<void> close() {
    controllerInputChat.dispose();
    return super.close();
  }
}

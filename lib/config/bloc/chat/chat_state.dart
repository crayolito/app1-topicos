part of 'chat_bloc.dart';

enum TipoRazonaminento { basico, avanzado }

enum EstadoDatos { cargando, exito, error }

enum TipoPregunta { none, texto, audio }

enum EstadoConsulta { procesando, exito, error, none }

enum TipoModeloIA { basico, avanzado }

enum TipoRespuesta { normal, consiso, explicativo, defesaLegal }

class ChatState extends Equatable {
  final EstadoDatos estadoDatos;
  final List<Chat> historialChats;
  final List<String> historialBusquedas;
  final List<TipoArchivo> archivosMultimedia;
  final EstadoConsulta estadoConsulta;
  final String preguntaConsulta;
  final String respuestaConsulta;
  final TipoModeloIA tipoModeloIA;
  final TipoRespuesta tipoRespuesta;
  final List<ChatTemporales> chatTemporales;
  //
  final bool estadoProcesoAudio;
  final TipoPregunta tipoPregunta;
  final TipoRazonaminento tipoRazonaminento;

  const ChatState({
    this.estadoDatos = EstadoDatos.cargando,
    this.estadoConsulta = EstadoConsulta.none,
    this.tipoModeloIA = TipoModeloIA.basico,
    this.tipoRespuesta = TipoRespuesta.normal,
    this.respuestaConsulta = '',
    this.preguntaConsulta = '',
    this.historialChats = const [],
    this.historialBusquedas = const [],
    this.archivosMultimedia = const [],
    this.chatTemporales = const [],
    //
    this.estadoProcesoAudio = false,
    this.tipoPregunta = TipoPregunta.none,
    this.tipoRazonaminento = TipoRazonaminento.basico,
  });

  ChatState copyWith({
    EstadoDatos? estadoDatos,
    EstadoConsulta? estadoConsulta,
    TipoModeloIA? tipoModeloIA,
    TipoRespuesta? tipoRespuesta,
    String? respuestaConsulta,
    String? preguntaConsulta,
    List<Chat>? historialChats,
    List<String>? historialBusquedas,
    List<TipoArchivo>? archivosMultimedia,
    List<ChatTemporales>? chatTemporales,
    //
    bool? estadoProcesoAudio,
    TipoPregunta? tipoPregunta,
  }) {
    return ChatState(
      estadoDatos: estadoDatos ?? this.estadoDatos,
      estadoConsulta: estadoConsulta ?? this.estadoConsulta,
      tipoModeloIA: tipoModeloIA ?? this.tipoModeloIA,
      tipoRespuesta: tipoRespuesta ?? this.tipoRespuesta,
      respuestaConsulta:
          respuestaConsulta ?? this.respuestaConsulta, // Añadir esto
      preguntaConsulta: preguntaConsulta ?? this.preguntaConsulta,
      historialChats: historialChats ?? this.historialChats,
      historialBusquedas: historialBusquedas ?? this.historialBusquedas,
      archivosMultimedia: archivosMultimedia ?? this.archivosMultimedia,
      chatTemporales: chatTemporales ?? this.chatTemporales,
      //
      estadoProcesoAudio: estadoProcesoAudio ?? this.estadoProcesoAudio,
      tipoPregunta: tipoPregunta ?? this.tipoPregunta,
    );
  }

  @override
  List<Object?> get props => [
    estadoDatos,
    estadoConsulta,
    preguntaConsulta,
    historialChats,
    historialBusquedas,
    archivosMultimedia,
    tipoModeloIA,
    tipoRespuesta,
    chatTemporales,
    respuestaConsulta,
    //
    estadoProcesoAudio,
    tipoPregunta,
  ];
}

part of 'chat_bloc.dart';

class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object> get props => [];
}

class OnContruccionDatos extends ChatEvent {
  const OnContruccionDatos();
}

class OnChagendEstadoConsulta extends ChatEvent {
  final EstadoConsulta estadoConsulta;

  const OnChagendEstadoConsulta({required this.estadoConsulta});
}

class OnChagendPreguntaConsulta extends ChatEvent {
  final String preguntaConsulta;

  const OnChagendPreguntaConsulta({required this.preguntaConsulta});
}

class OnChagendTipoModeloIA extends ChatEvent {
  final TipoModeloIA tipoModeloIA;

  const OnChagendTipoModeloIA({required this.tipoModeloIA});
}

class OnChagendTipoRespuesta extends ChatEvent {
  final TipoRespuesta tipoRespuesta;

  const OnChagendTipoRespuesta({required this.tipoRespuesta});
}

class OnChagendHistorialBusquedas extends ChatEvent {
  final List<String> historialBusquedas;

  const OnChagendHistorialBusquedas({required this.historialBusquedas});
}

class OnProcesoConsutalIA extends ChatEvent {
  final String preguntaConsulta;

  const OnProcesoConsutalIA({required this.preguntaConsulta});
}

class OnChagendEstadoProcesoAudio extends ChatEvent {
  final bool estadoProcesoAudio;

  const OnChagendEstadoProcesoAudio({required this.estadoProcesoAudio});
}

class OnChagendTipoPregunta extends ChatEvent {
  final TipoPregunta tipoPregunta;

  const OnChagendTipoPregunta({required this.tipoPregunta});
}

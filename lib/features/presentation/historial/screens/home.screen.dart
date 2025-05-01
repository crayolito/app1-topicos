import 'dart:async';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:topicos_app1/config/bloc/chat/chat_bloc.dart';
import 'package:topicos_app1/config/const/colores.const.dart';
import 'package:topicos_app1/config/const/generalizador.const.dart';
import 'package:topicos_app1/features/presentation/historial/helpers.dart';
import 'package:topicos_app1/features/services/generales.service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ScrollController _scrollController;
  bool unaPreguntaAudio = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    HelperHistorial.actualizarColorBarraNavegacion(false);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatBloc = BlocProvider.of<ChatBloc>(context, listen: true);

    return Scaffold(
      backgroundColor: colorTerciario,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          // BARRA DE NAVEGACION SUPEIOR
          BarraNavegacion(),
          // LISTA DE CHATS
          ListaChats(),
          //BARRA INFERIOR CAPTURA DE LA PREGUNTA
          chatBloc.state.estadoProcesoAudio
              ?
              // SECCION DE AUDIO
              GrabacionPersonalizada()
              :
              // Opciones de Chat y Audio
              OpcionesCliente(),
        ],
      ),
    );
  }
}

class GrabacionPersonalizada extends StatefulWidget {
  const GrabacionPersonalizada({super.key});
  @override
  State<GrabacionPersonalizada> createState() => _GrabacionPersonalizadaState();
}

class _GrabacionPersonalizadaState extends State<GrabacionPersonalizada> {
  late ChatBloc chatBloc;
  bool estaGrabando = false;
  String mensaje = "";
  int tiempoTranscurrido = 0;
  Timer? temporizador;
  String? rutaArchivo;
  // Tiempo máximo de grabación en segundos (5 minutos = 300 segundos)
  final int tiempoMaximo = 300;
  // Para el visualizador de ondas
  RecorderController? grabadorController;

  // Estado de carga y respuesta
  bool enviandoAudio = false;
  Map<String, dynamic>? respuestaServidor;

  @override
  void initState() {
    super.initState();
    grabadorController =
        RecorderController()
          ..androidEncoder = AndroidEncoder.aac
          ..androidOutputFormat = AndroidOutputFormat.mpeg4
          ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
          ..sampleRate = 44100;
    iniciarGrabacion();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    chatBloc = BlocProvider.of<ChatBloc>(context, listen: true);
  }

  Future<void> iniciarGrabacion() async {
    if (estaGrabando) return;
    // Obtener directorio temporal para guardar el audio
    final directory = await getTemporaryDirectory();
    rutaArchivo =
        '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
    print('Archivo de audio se guardará en: $rutaArchivo');
    setState(() {
      mensaje = "Grabando...";
      estaGrabando = true;
      tiempoTranscurrido = 0;
    });
    // Iniciar visualización de ondas y grabación
    try {
      await grabadorController?.record(path: rutaArchivo);
      print('Grabación iniciada correctamente');
    } catch (e) {
      print('Error al iniciar grabación: $e');
      setState(() {
        mensaje = "Error al iniciar grabación: $e";
        estaGrabando = false;
      });
      return;
    }
    // Iniciar el temporizador
    temporizador = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        tiempoTranscurrido++;
        // Si se alcanza el tiempo máximo, detener automáticamente
        if (tiempoTranscurrido >= tiempoMaximo) {
          timer.cancel();
          guardarAudioYProcesarlo();
        }
      });
    });
  }

  Future<void> guardarAudioYProcesarlo() async {
    if (!estaGrabando) return;
    setState(() {
      estaGrabando = false;
    });
    // Detener temporizador
    temporizador?.cancel();
    temporizador = null;
    // Detener grabador de ondas
    String? audioPath;
    try {
      audioPath = await grabadorController?.stop();
      print('Grabación detenida. Archivo guardado en: $audioPath');
      setState(() {
        mensaje = "Audio correctamente finalizado";
        enviandoAudio = true;
      });

      // Enviar el audio al backend para procesamiento
      if (audioPath != null) {
        await enviarAudioAlServidor(audioPath);
      } else if (rutaArchivo != null) {
        await enviarAudioAlServidor(rutaArchivo!);
      } else {
        throw Exception("No se pudo obtener la ruta del archivo de audio");
      }

      // Llamar a función para cambiar estado en el widget padre

      chatBloc.add(
        OnChagendEstadoProcesoAudio(
          estadoProcesoAudio: !chatBloc.state.estadoProcesoAudio,
        ),
      );
    } catch (e) {
      print('Error al procesar audio: $e');
      setState(() {
        mensaje = "Error al procesar audio: $e";
        enviandoAudio = false;
      });
    }
  }

  Future<void> enviarAudioAlServidor(String audioPath) async {
    try {
      setState(() {
        enviandoAudio = true;
        mensaje = "Enviando audio al servidor...";
      });

      // Usar nuestro servicio para enviar el audio
      final respuesta = await GeneralesService.enviarAudioParaProcesar(
        audioFilePath: audioPath,
      );

      setState(() {
        // respuestaServidor = respuesta;
        enviandoAudio = false;
        mensaje = "Procesamiento completado";
      });

      print('Respuesta del servidor: $respuesta');
      chatBloc.add(OnChagendPreguntaConsulta(preguntaConsulta: respuesta));

      // Aquí puedes manejar la respuesta según tus necesidades
      // Por ejemplo, mostrar el texto transcrito o navegar a otra pantalla
    } catch (e) {
      setState(() {
        enviandoAudio = false;
        mensaje = "Error al enviar audio: $e";
      });
      print('Error al enviar audio al servidor: $e');
    }
  }

  Future<void> cancelarGrabacion() async {
    if (!estaGrabando) return;
    setState(() {
      estaGrabando = false;
    });
    // Detener temporizador
    temporizador?.cancel();
    temporizador = null;
    // Detener grabador de ondas
    try {
      await grabadorController?.stop();
      chatBloc.add(
        OnChagendEstadoProcesoAudio(
          estadoProcesoAudio: !chatBloc.state.estadoProcesoAudio,
        ),
      );
      print('Grabación cancelada');
      setState(() {
        mensaje = "Grabación cancelada";
      });
    } catch (e) {
      print('Error al cancelar grabación: $e');
      setState(() {
        mensaje = "Error al cancelar grabación: $e";
      });
    }
  }

  String formatearTiempo(int segundos) {
    final minutos = segundos ~/ 60;
    final segundosRestantes = segundos % 60;
    return '${minutos.toString().padLeft(2, '0')}:${segundosRestantes.toString().padLeft(2, '0')}';
  }

  // Calcular el progreso del temporizador (0.0 a 1.0)
  double get progresoTemporizador {
    return tiempoTranscurrido / tiempoMaximo;
  }

  // Tiempo restante formateado
  String get tiempoRestante {
    int segundosRestantes = tiempoMaximo - tiempoTranscurrido;
    if (segundosRestantes < 0) segundosRestantes = 0;
    return formatearTiempo(segundosRestantes);
  }

  @override
  void dispose() {
    temporizador?.cancel();
    // Detener y liberar el controlador de grabación
    grabadorController
        ?.stop()
        .then((_) {
          grabadorController?.dispose();
        })
        .catchError((e) {
          print('Error al disponer el grabador: $e');
        });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size.height * 0.17,
      decoration: BoxDecoration(
        color: colorCuaternario,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(size.width * 0.1),
          topRight: Radius.circular(size.width * 0.1),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          // top: size.height * 0.025,
          top: 0,
          bottom: 0,
          left: size.width * 0.045,
          right: size.width * 0.045,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Controles de grabación
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () async {
                    await cancelarGrabacion();
                    print("Cancelar grabación");
                  },
                  child: Container(
                    width: size.width * 0.16,
                    height: size.height * 0.08,
                    decoration: BoxDecoration(
                      color: Color.lerp(colorCuaternario, Colors.black45, 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.clear,
                        color: colorCuaternario,
                        size: size.width * 0.1,
                      ),
                    ),
                  ),
                ),
                AudioWaveforms(
                  enableGesture: false,
                  size: Size(size.width * 0.37, size.height * 0.06),
                  recorderController: grabadorController!,
                  waveStyle: WaveStyle(
                    waveColor: colorQuinto,
                    extendWaveform: true,
                    showMiddleLine: false,
                    spacing: 5,
                    waveThickness: 3,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                Text(
                  formatearTiempo(tiempoTranscurrido),
                  style: textos.textoEstadoGrabacion,
                ),
                GestureDetector(
                  onTap: enviandoAudio ? null : guardarAudioYProcesarlo,
                  child: Container(
                    width: size.width * 0.16,
                    height: size.height * 0.08,
                    decoration: BoxDecoration(
                      color: enviandoAudio ? Colors.grey : colorQuinto,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child:
                          enviandoAudio
                              ? SizedBox(
                                width: size.width * 0.1,
                                height: size.width * 0.1,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3.0,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    colorCuaternario,
                                  ),
                                ),
                              )
                              : Icon(
                                Icons.arrow_upward,
                                color: colorCuaternario,
                                size: size.width * 0.1,
                              ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class OpcionesCliente extends StatefulWidget {
  const OpcionesCliente({super.key});

  @override
  State<OpcionesCliente> createState() => _OpcionesClienteState();
}

class _OpcionesClienteState extends State<OpcionesCliente> {
  late ChatBloc chatBloc;
  final FocusNode focusNode = FocusNode();
  // final TextEditingController controller = TextEditingController();
  bool enFocoInput = false;
  bool campoVacio = true;

  @override
  void initState() {
    super.initState();
    chatBloc = BlocProvider.of<ChatBloc>(context);
    // Inicializar el estado del campo
    campoVacio = chatBloc.controllerInputChat.text.isEmpty;

    // Configurar listeners
    focusNode.addListener(_onFocusChange);
    chatBloc.controllerInput.addListener(_onTextChange);
  }

  @override
  void dispose() {
    // Remover correctamente los listeners
    focusNode.removeListener(_onFocusChange);
    chatBloc.controllerInput.removeListener(_onTextChange);

    // Liberar recursos
    // chatBloc.controllerInput.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatBloc = BlocProvider.of<ChatBloc>(context, listen: true);

    return Container(
      height: size.height * 0.15,
      decoration: BoxDecoration(
        color: colorPrimario,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(size.width * 0.1),
          topRight: Radius.circular(size.width * 0.1),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: size.height * 0.025,
              bottom: 0,
              left: size.width * 0.02,
              right: size.width * 0.02,
            ),
            child: TextFormField(
              controller: chatBloc.controllerInput,
              focusNode: focusNode,
              cursorColor: colorCuaternario,
              cursorWidth: 1.5,
              cursorRadius: Radius.circular(3),
              style: textos.textoHistorial3,
              decoration: InputDecoration(
                hintText: "Alguna pregunta para Rodalex ...",
                hintStyle: textos.textoHistorial3,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                isDense: true,
                filled: true,
                fillColor: colorPrimario.withOpacity(0.8),
              ),
              onFieldSubmitted: (value) {
                if (value.isNotEmpty) {
                  // Lógica para enviar el mensaje
                  print('Mensaje a enviar: $value');
                  // Limpiar el campo después de enviar
                  chatBloc.controllerInput.clear();
                  // No quitar el foco, permitir al usuario seguir escribiendo
                }
              },
            ),
          ),
          SizedBox(height: size.height * 0.01),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.033),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.psychology,
                      color: colorTerciario,
                      size: size.width * 0.1,
                    ),
                    Switch(
                      value:
                          chatBloc.state.tipoRazonaminento ==
                          TipoRazonaminento.avanzado,
                      onChanged: (bool value) {
                        if (value) {
                          chatBloc.add(
                            OnChagendTipoModeloIA(
                              tipoModeloIA: TipoModeloIA.basico,
                            ),
                          );
                        } else {
                          chatBloc.add(
                            OnChagendTipoModeloIA(
                              tipoModeloIA: TipoModeloIA.avanzado,
                            ),
                          );
                        }
                      },
                      activeColor: colorPrimario,
                      activeTrackColor: colorTerciario,
                      inactiveThumbColor: colorSecundario,
                      inactiveTrackColor: colorTerciario,
                    ),
                    FloatingActionButton.small(
                      heroTag: 'uniqueTag1',
                      shape: CircleBorder(),
                      elevation: 4,
                      highlightElevation: 2,
                      onPressed: () {},
                      backgroundColor: colorTerciario,
                      child: Icon(
                        Icons.add,
                        color: colorPrimario,
                        size: size.width * 0.07,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: size.width * 0.05),
                FloatingActionButton.small(
                  heroTag: 'uniqueTag2',
                  shape: CircleBorder(),
                  elevation: 4,
                  highlightElevation: 2,
                  onPressed: () async {
                    if (chatBloc.state.estadoConsulta ==
                        EstadoConsulta.procesando) {
                      // Aqui va cancelar la consulta a la IA y va poner la pregunta en el input
                      chatBloc.controllerInput.text =
                          chatBloc.state.preguntaConsulta;

                      // return;
                    } else {
                      if (chatBloc.state.estadoConsulta ==
                              EstadoConsulta.exito ||
                          (enFocoInput && !campoVacio)) {
                        // Realizar consulta del texto
                        print(
                          'Enviando mensaje: ${chatBloc.controllerInput.text}',
                        );
                        chatBloc.add(
                          OnProcesoConsutalIA(
                            preguntaConsulta: chatBloc.controllerInput.text,
                          ),
                        );
                        // Limpiar el campo después de enviar
                        chatBloc.controllerInput.clear();
                      } else {
                        // Cambiar al proceso de audio
                        // widget.onPressedAudio();

                        // Si no tiene permisos muestra mensaje que solicita
                        if (!await HelperHistorial.verificarPermisosAudio()) {
                          // ignore: use_build_context_synchronously
                          HelperHistorial.mensajePermisoAudio(context);
                          return;
                        }

                        chatBloc.add(
                          OnChagendEstadoProcesoAudio(
                            estadoProcesoAudio:
                                !chatBloc.state.estadoProcesoAudio,
                          ),
                        );
                      }
                    }
                  },
                  backgroundColor: colorCuaternario,
                  child: Icon(
                    chatBloc.state.estadoConsulta == EstadoConsulta.procesando
                        ? Icons.stop
                        : chatBloc.state.estadoConsulta ==
                                EstadoConsulta.exito ||
                            (enFocoInput && !campoVacio)
                        ? Icons.arrow_upward
                        : Icons.mic_none_outlined,
                    color: colorTerciario,
                    size: size.width * 0.07,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _actualizarEstadoInput() {
    if (!mounted) return;
    final bool tieneFoco = focusNode.hasFocus;

    final bool estaVacio = chatBloc.controllerInput.text.isEmpty;

    if (enFocoInput != tieneFoco || campoVacio != estaVacio) {
      setState(() {
        enFocoInput = tieneFoco;
        campoVacio = estaVacio;
        // Solo actualizamos el tipo de pregunta cuando cambia realmente el estado
        // widget.actualizarTipoPregunta(tieneFoco && !estaVacio);
      });
    }
  }

  void _onFocusChange() {
    _actualizarEstadoInput();
    // Imprimir información de debug
    print(
      'Campo en foco: ${focusNode.hasFocus}, Texto: "${chatBloc.controllerInput.text}", Vacío: ${chatBloc.controllerInput.text.isEmpty}',
    );
  }

  void _onTextChange() {
    _actualizarEstadoInput();
    // Imprimir información de debug
    print(
      'Texto cambiado: "${chatBloc.controllerInput.text}", Vacío: ${chatBloc.controllerInput.text.isEmpty}',
    );
  }
}

class BarraNavegacion extends StatelessWidget {
  const BarraNavegacion({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size.height * 0.16,
      width: size.width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorTerciario,
            colorTerciario,
            colorTerciario,
            colorTerciario.withOpacity(0.9),
            colorTerciario.withOpacity(0.7),
            colorTerciario.withOpacity(0.5),
            colorTerciario.withOpacity(0.3),
            colorTerciario.withOpacity(0.1),
            colorTerciario.withOpacity(0.0),
          ],
          stops: [0.0, 0.5, 0.7, 0.75, 0.8, 0.85, 0.9, 0.95, 1.0],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_outlined, size: size.width * 0.09),
            onPressed: () {},
            color: colorPrimario,
          ),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: "RODALEX", style: textos.textoHistorial),
                TextSpan(text: "0.1 Beta", style: textos.textoHistorial2),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.more_vert, size: size.width * 0.09),
            onPressed: () {},
            color: colorPrimario,
          ),
        ],
      ),
    );
  }
}

class ListaChats extends StatefulWidget {
  const ListaChats({super.key});

  @override
  State<ListaChats> createState() => _ListaChatsState();
}

class _ListaChatsState extends State<ListaChats> {
  late ScrollController _scrollController;
  bool reproduciendoActual = false;
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _configurarTts();
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  // Configuración inicial del TTS
  Future<void> _configurarTts() async {
    await flutterTts.setLanguage("es-ES");
    await flutterTts.setPitch(0.9);
    await flutterTts.setSpeechRate(0.5);

    // Añadir listener para saber cuándo termina la reproducción
    flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          reproduciendoActual = false;
        });
      }
    });
  }

  // Método para reproducir texto
  Future<void> reproducirConVozAbogado(String texto) async {
    if (texto.isEmpty) return;

    setState(() {
      reproduciendoActual = true;
    });

    await flutterTts.speak(texto);
  }

  // Método para detener la reproducción
  Future<void> detenerReproduccion() async {
    await flutterTts.stop();

    setState(() {
      reproduciendoActual = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatBloc = BlocProvider.of<ChatBloc>(context, listen: true);

    return Expanded(
      // height: size.height * 0.63,
      // width: size.width,
      child: SizedBox(
        width: double.infinity,
        child:
            chatBloc.state.chatTemporales.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/logoApp.png",
                        width: size.width * 0.3,
                        height: size.height * 0.15,
                        fit: BoxFit.fill,
                      ),
                      SizedBox(height: size.height * 0.005),
                      Text(
                        "¿Cómo puedo ayudarte \n esta noche?",
                        style: textos.textoHistorial4,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
                : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.zero,
                        controller: _scrollController,
                        itemCount: chatBloc.state.chatTemporales.length,
                        itemBuilder: (context, index) {
                          final chatItem = chatBloc.state.chatTemporales[index];

                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: size.height * 0.02,
                            ),
                            child:
                                chatItem.quien == "USUARIO"
                                    ? Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        margin: EdgeInsets.only(
                                          left: size.width * 0.02,
                                          right: size.width * 0.02,
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          vertical: size.height * 0.015,
                                          horizontal: size.width * 0.03,
                                        ),
                                        decoration: BoxDecoration(
                                          color: colorQuinto,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: colorQuinto,
                                              blurRadius: 5,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          chatItem.mensaje,
                                          style: textos.textoUsuario,
                                          textAlign: TextAlign.start,
                                        ),
                                      ),
                                    )
                                    : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Respuesta principal
                                        Padding(
                                          padding: EdgeInsets.only(
                                            left: size.width * 0.05,
                                            right: size.width * 0.05,
                                          ),
                                          child: RichText(
                                            text: TextSpan(
                                              style: textos.textoIA,
                                              children:
                                                  _procesarTextoConFormato(
                                                    chatItem.mensaje,
                                                    context,
                                                  ),
                                            ),
                                            textAlign: TextAlign.start,
                                          ),
                                        ),
                                      ],
                                    ),
                          );
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: size.height * 0.01),
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.05,
                      ),
                      height: size.height * 0.05,
                      width: size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            child: Row(
                              children: [
                                Image.asset(
                                  "assets/logoApp.png",
                                  width: size.width * 0.08,
                                  height: size.height * 0.04,
                                  fit: BoxFit.fill,
                                ),
                                !reproduciendoActual
                                    ? IconButton(
                                      onPressed: () async {
                                        final textoRespuesta =
                                            chatBloc.state.respuestaConsulta;
                                        await reproducirConVozAbogado(
                                          textoRespuesta,
                                        );
                                      },
                                      icon: Icon(
                                        Icons.volume_up,
                                        color: colorPrimario,
                                        size: size.width * 0.07,
                                      ),
                                    )
                                    : IconButton(
                                      onPressed: () {
                                        detenerReproduccion();
                                      },
                                      icon: Icon(
                                        Icons.stop,
                                        color: colorPrimario,
                                        size: size.width * 0.07,
                                      ),
                                    ),
                              ],
                            ),
                          ),
                          Text(
                            "Tu ultima respuesta.\nPudes reproducirla en audio.",
                            style: textos.textoEstadoGrabacion2,
                            textAlign: TextAlign.end,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  // AÑADE ESTE MÉTODO EN TU CLASE
  List<TextSpan> _procesarTextoConFormato(String texto, BuildContext context) {
    List<TextSpan> spans = [];
    List<String> lineas = texto.split('\n');

    for (var i = 0; i < lineas.length; i++) {
      String linea = lineas[i];

      // Si la línea termina con ":", es un título
      if (linea.endsWith(':')) {
        spans.add(
          TextSpan(text: '$linea\n', style: textos.estilosRespuestaTitulo),
        );
      }
      // Si la línea empieza con "•", es un elemento de lista
      else if (linea.startsWith('•')) {
        spans.add(
          TextSpan(text: '$linea\n', style: textos.estilosRespuestaSubtitulo),
        );
      }
      // Línea normal
      else {
        spans.add(TextSpan(text: '$linea${i < lineas.length - 1 ? '\n' : ''}'));
      }
    }

    return spans;
  }
}

class ChatTemporales {
  final String quien;
  final String mensaje;
  final List<String> temasRelacionados;

  ChatTemporales({
    required this.quien,
    required this.mensaje,
    this.temasRelacionados = const [],
  });
}

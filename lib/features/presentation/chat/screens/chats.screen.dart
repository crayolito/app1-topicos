import 'package:flutter/material.dart';
import 'package:topicos_app1/config/const/colores.const.dart';
import 'package:topicos_app1/config/const/generalizador.const.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        color: colorTerciario,
        child: Stack(
          children: [
            // Lista de Chats
            Positioned(
              top: size.height * 0.11,
              left: 0,
              right: 0,
              bottom: 0, // Define el límite inferior para el área posicionada
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: [
                    // Encabezado incluido en el área de desplazamiento
                    Text("Chats", style: textos.textoChatsScreen),
                    SizedBox(height: size.height * 0.01),
                    // Lista de mensajes
                    ...mensajesTransito.map((mensaje) {
                      return Container(
                        margin: EdgeInsets.only(bottom: 10),
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.01,
                          vertical: size.height * 0.005,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mensaje.titulo,
                              style: textos.texto2ChatsScreen,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "${mensaje.fechaHora.day}/${mensaje.fechaHora.month}/${mensaje.fechaHora.year} ${mensaje.fechaHora.hour}:${mensaje.fechaHora.minute}",
                              style: textos.texto3ChatsScreen,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            // Barras de navegación y superior
            Positioned(
              top: size.height * 0.02,
              child: Container(
                padding: EdgeInsets.only(
                  left: size.width * 0.005,
                  right: size.width * 0.03,
                ),
                height: size.height * 0.12,
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
                      icon: Icon(Icons.menu, size: size.width * 0.09),
                      onPressed: () {},
                      color: colorPrimario,
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.search, size: size.width * 0.09),
                          onPressed: () {},
                          color: colorPrimario,
                        ),
                        Image.asset(
                          "assets/logoApp.png",
                          width: size.width * 0.08,
                          height: size.height * 0.04,
                          fit: BoxFit.fill,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Icono iniciar un nuevo chat
            Positioned(
              bottom: size.height * 0.02,
              right: size.width * 0.05,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.03,
                  vertical: size.height * 0.01,
                ),
                height: 56,
                decoration: BoxDecoration(
                  color: colorCuaternario,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.add_comment_rounded,
                      size: size.width * 0.08,
                      color: colorPrimario,
                    ),
                    SizedBox(width: size.width * 0.02),
                    Text("Nuevo Chat", style: textos.texto4ChatsScreen),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MensajeJuridico {
  final String titulo;
  final DateTime fechaHora;
  final String contenido;

  MensajeJuridico({
    required this.titulo,
    required this.fechaHora,
    required this.contenido,
  });
}

List<MensajeJuridico> mensajesTransito = [
  MensajeJuridico(
    titulo: "Infracción por Exceso de Velocidad",
    fechaHora: DateTime.parse("2025-05-01 09:30:00"),
    contenido:
        "Sanción por superar el límite de velocidad en zona urbana. Art. 121 inc. 3.",
  ),
  MensajeJuridico(
    titulo: "Estacionamiento en Zona Prohibida",
    fechaHora: DateTime.parse("2025-05-01 14:20:00"),
    contenido:
        "Multa por estacionar en área señalizada como prohibida. Art. 183 inc. 2.",
  ),
  MensajeJuridico(
    titulo: "Conducir Sin Licencia",
    fechaHora: DateTime.parse("2025-05-02 11:30:00"),
    contenido:
        "Infracción grave por conducir sin licencia válida. Art. 94 inc. 1.",
  ),
  MensajeJuridico(
    titulo: "Semáforo en Rojo",
    fechaHora: DateTime.parse("2025-05-02 16:15:00"),
    contenido: "Sanción por cruzar con semáforo en rojo. Art. 146 inc. 5.",
  ),
  MensajeJuridico(
    titulo: "Alcoholemia Positiva",
    fechaHora: DateTime.parse("2025-05-03 08:45:00"),
    contenido:
        "Procedimiento por conducir bajo efectos del alcohol. Art. 220 inc. 1.",
  ),
  MensajeJuridico(
    titulo: "Circulación en Sentido Contrario",
    fechaHora: DateTime.parse("2025-05-03 13:20:00"),
    contenido:
        "Infracción por circular en sentido opuesto al establecido. Art. 132 inc. 4.",
  ),
  MensajeJuridico(
    titulo: "Uso del Celular",
    fechaHora: DateTime.parse("2025-05-04 10:00:00"),
    contenido:
        "Sanción por uso de teléfono móvil durante la conducción. Art. 157 inc. 2.",
  ),
  MensajeJuridico(
    titulo: "No Usar Cinturón",
    fechaHora: DateTime.parse("2025-05-04 15:30:00"),
    contenido:
        "Infracción por no utilizar cinturón de seguridad. Art. 165 inc. 1.",
  ),
  MensajeJuridico(
    titulo: "Documentación Vencida",
    fechaHora: DateTime.parse("2025-05-05 09:15:00"),
    contenido:
        "Sanción por circular con documentación vehicular caducada. Art. 103 inc. 3.",
  ),
  MensajeJuridico(
    titulo: "Giro Prohibido",
    fechaHora: DateTime.parse("2025-05-05 14:45:00"),
    contenido:
        "Multa por realizar un giro en lugar no permitido. Art. 142 inc. 2.",
  ),
  MensajeJuridico(
    titulo: "Luces Apagadas",
    fechaHora: DateTime.parse("2025-05-06 11:00:00"),
    contenido:
        "Infracción por circular sin luces reglamentarias encendidas. Art. 175 inc. 4.",
  ),
  MensajeJuridico(
    titulo: "Estacionamiento en Doble Fila",
    fechaHora: DateTime.parse("2025-05-06 16:30:00"),
    contenido:
        "Sanción por estacionar en doble fila obstruyendo circulación. Art. 186 inc. 3.",
  ),
  MensajeJuridico(
    titulo: "No Respetar Paso Peatonal",
    fechaHora: DateTime.parse("2025-05-07 09:45:00"),
    contenido: "Multa por no ceder el paso en cruce peatonal. Art. 148 inc. 2.",
  ),
  MensajeJuridico(
    titulo: "Sobrepasar en Línea Continua",
    fechaHora: DateTime.parse("2025-05-07 13:20:00"),
    contenido:
        "Infracción por adelantamiento en zona de línea continua. Art. 136 inc. 1.",
  ),
  MensajeJuridico(
    titulo: "Vehículo sin VTV/ITV",
    fechaHora: DateTime.parse("2025-05-08 10:30:00"),
    contenido:
        "Sanción por circular sin revisión técnica obligatoria. Art. 112 inc. 5.",
  ),
  MensajeJuridico(
    titulo: "No Respetar Señal de Stop",
    fechaHora: DateTime.parse("2025-05-08 15:00:00"),
    contenido: "Multa por no detenerse ante señal de Stop. Art. 144 inc. 3.",
  ),
  MensajeJuridico(
    titulo: "Escape Modificado",
    fechaHora: DateTime.parse("2025-05-09 08:30:00"),
    contenido:
        "Infracción por circular con sistema de escape modificado. Art. 178 inc. 2.",
  ),
  MensajeJuridico(
    titulo: "Obstrucción de Rampa",
    fechaHora: DateTime.parse("2025-05-09 14:15:00"),
    contenido: "Sanción por obstruir rampa de accesibilidad. Art. 184 inc. 6.",
  ),
  MensajeJuridico(
    titulo: "Transporte Inseguro de Carga",
    fechaHora: DateTime.parse("2025-05-10 11:45:00"),
    contenido:
        "Multa por transportar carga sin las medidas de seguridad. Art. 195 inc. 4.",
  ),
  MensajeJuridico(
    titulo: "Conducción Temeraria",
    fechaHora: DateTime.parse("2025-05-10 16:00:00"),
    contenido:
        "Infracción grave por conducción temeraria o peligrosa. Art. 205 inc. 1.",
  ),
];

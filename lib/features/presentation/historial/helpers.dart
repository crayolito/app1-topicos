import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:topicos_app1/config/const/colores.const.dart';
import 'package:topicos_app1/config/const/generalizador.const.dart';

class HelperHistorial {
  static actualizarColorBarraNavegacion(bool estadoProcesoAudio) {
    // SystemChrome.setSystemUIOverlayStyle(
    //   SystemUiOverlayStyle(
    //     systemNavigationBarColor:
    //         procesoAudio ? colorCuaternario : colorPrimario,
    //     systemNavigationBarDividerColor: Colors.transparent,
    //     systemNavigationBarIconBrightness: Brightness.light,
    //     statusBarColor: Colors.transparent,
    //     statusBarIconBrightness: Brightness.light,
    //   ),
    // );

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor:
            estadoProcesoAudio ? colorCuaternario : colorPrimario,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  static mensajePermisoAudio(BuildContext context) {
    String valorSeleccionado = "Español";

    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(top: size.height * 0.4),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(size.width * 0.05),
              height: size.height * 0.2,
              width: size.width,
              decoration: BoxDecoration(
                color: colorTerciario,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    "Envía mensajes a RODALEX usando tu voz.".toUpperCase(),
                    style: textos.textoPermisos,
                    textAlign: TextAlign.center,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: size.height * 0.013),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: Icon(
                            Icons.public,
                            color: colorCuaternario,
                            size: size.width * 0.07,
                          ),
                          title: Text(
                            'Elige un idioma para hablar',
                            style: textos.textoPermisos2,
                          ),
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.access_time,
                            color: colorCuaternario,
                            size: size.width * 0.07,
                          ),
                          title: Text(
                            'Habla hasta 5 minutos',
                            style: textos.textoPermisos2,
                          ),
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.flash_on,
                            color: colorCuaternario,
                            size: size.width * 0.07,
                          ),
                          title: Text(
                            'Chatea más rápido y con más naturalidad',
                            style: textos.textoPermisos2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Idioma de entrada de voz',
                      labelStyle: textos.tituloDropdown,
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      filled: true,
                      fillColor: colorQuinto,
                      // Eliminar la línea inferior
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      // También eliminar la línea de enfoque
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    icon: Icon(Icons.arrow_drop_down, color: colorCuaternario),
                    dropdownColor: colorQuinto,
                    value: valorSeleccionado,
                    onChanged: (String? newValue) {},
                    items:
                        <String>[
                          'Español',
                          'Inglés',
                          'Francés',
                          'Alemán',
                          'Italiano',
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: textos.subtituloDropdown),
                          );
                        }).toList(),
                  ),
                  SizedBox(height: size.height * 0.02),
                  GestureDetector(
                    onTap: () async {
                      bool tienePermisos = await verificarPermisosAudio();
                      print("Permisos verificados: $tienePermisos");
                      if (!tienePermisos) {
                        tienePermisos = await solicitarPermisosAudio();
                        print("Permisos solicitados: $tienePermisos");
                        if (tienePermisos) {
                          // ignore: use_build_context_synchronously
                          Navigator.pop(context);
                          return;
                        }
                      }
                    },
                    child: Container(
                      height: size.height * 0.065,
                      width: size.width,
                      decoration: BoxDecoration(
                        color: colorPrimario,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          "Continuar",
                          style: textos.subtituloDropdown,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<bool> verificarPermisosAudio() async {
    if (Platform.isAndroid) {
      // Verificar versión de Android
      final infoDispositivo = DeviceInfoPlugin();
      final infoAndroid = await infoDispositivo.androidInfo;

      // Verificar permiso de micrófono sin solicitarlo
      final estadoMicrofono = await Permission.microphone.status;

      // Verificar permiso de almacenamiento según versión, sin solicitarlo
      PermissionStatus estadoAlmacenamiento;
      if (infoAndroid.version.sdkInt >= 33) {
        // Para Android 13+ verificar Permission.audio
        estadoAlmacenamiento = await Permission.audio.status;
      } else {
        // Para versiones anteriores verificar Permission.storage
        estadoAlmacenamiento = await Permission.storage.status;
      }

      // Devolver true solo si ambos permisos están concedidos
      return estadoMicrofono.isGranted && estadoAlmacenamiento.isGranted;
    } else if (Platform.isIOS) {
      // Solo verificar permiso de micrófono en iOS
      final estadoMicrofono = await Permission.microphone.status;
      return estadoMicrofono.isGranted;
    }

    return false;
  }

  static Future<bool> solicitarPermisosAudio() async {
    final estadoMicrofono = await Permission.microphone.request();
    final estadoAudio = await Permission.audio.request();
    return estadoMicrofono.isGranted && estadoAudio.isGranted;
  }

  static mensajeOpcionesModelo(BuildContext context) {}
}

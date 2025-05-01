import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:topicos_app1/config/const/colores.const.dart';

class Textos {
  BuildContext context;

  Textos(this.context);
  Size get size => MediaQuery.of(context).size;

  // BIENVENIDA SCREEN

  TextStyle get textoBienvenida => GoogleFonts.kanit(
    fontSize: size.width * 0.08,
    color: colorSecundario,
    fontWeight: FontWeight.w600,
  );

  TextStyle get textoBienvenida2 => GoogleFonts.kanit(
    fontSize: size.width * 0.06,
    color: colorSecundario,
    fontWeight: FontWeight.w600,
  );

  // HOME SCREEN

  TextStyle get textoHistorial => GoogleFonts.kanit(
    fontSize: size.width * 0.06,
    color: colorCuaternario,
    fontWeight: FontWeight.w600,
  );

  TextStyle get textoHistorial2 =>
      GoogleFonts.kanit(fontSize: size.width * 0.05, color: colorPrimario);

  TextStyle get textoHistorial3 => GoogleFonts.kanit(
    fontSize: size.width * 0.045,
    color: colorTerciario,
    fontWeight: FontWeight.w500,
  );

  TextStyle get textoHistorial4 => GoogleFonts.kanit(
    fontSize: size.width * 0.06,
    color: colorCuaternario,
    fontWeight: FontWeight.w500,
  );

  // Mensaje de solicitud de permisos
  TextStyle get textoPermisos => GoogleFonts.kanit(
    fontSize: size.width * 0.055,
    color: colorCuaternario,
    fontWeight: FontWeight.w500,
  );

  TextStyle get textoPermisos2 =>
      GoogleFonts.kanit(fontSize: size.width * 0.045, color: colorCuaternario);

  TextStyle get tituloDropdown =>
      GoogleFonts.kanit(fontSize: size.width * 0.04, color: colorCuaternario);

  TextStyle get subtituloDropdown =>
      GoogleFonts.kanit(fontSize: size.width * 0.045, color: colorCuaternario);

  // Elemento widget de estado de grabacion

  TextStyle get textoEstadoGrabacion => GoogleFonts.kanit(
    fontSize: size.width * 0.045,
    color: colorQuinto,
    fontWeight: FontWeight.w500,
  );

  TextStyle get textoEstadoGrabacion2 => GoogleFonts.kanit(
    fontSize: size.width * 0.03,
    color: colorCuaternario,
    fontWeight: FontWeight.w500,
  );

  // Elemento widget de la lista de chat

  TextStyle get textoUsuario => GoogleFonts.kanit(
    fontSize: size.width * 0.045,
    color: colorCuaternario,
    fontWeight: FontWeight.w300,
  );

  TextStyle get textoIA => GoogleFonts.kanit(
    fontSize: size.width * 0.045,
    color: colorCuaternario,
    // fontWeight: FontWeight.w500,
  );

  TextStyle get estilosRespuestaTitulo => GoogleFonts.kanit(
    fontSize: size.width * 0.05,
    color: colorPrimario,
    fontWeight: FontWeight.w600,
  );

  TextStyle get estilosRespuestaSubtitulo => GoogleFonts.kanit(
    fontSize: size.width * 0.036,
    color: colorCuaternario,
    fontWeight: FontWeight.w500,
  );
}

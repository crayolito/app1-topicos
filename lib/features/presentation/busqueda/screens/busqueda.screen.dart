import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:topicos_app1/config/const/generalizador.const.dart';
import 'package:topicos_app1/features/services/basedatos.service.dart';

class BusquedaScreen extends StatefulWidget {
  const BusquedaScreen({super.key});

  @override
  State<BusquedaScreen> createState() => _BusquedaScreenState();
}

class _BusquedaScreenState extends State<BusquedaScreen> {
  final ServicioBaseDatos _baseDatos = ServicioBaseDatos();
  final TextEditingController _searchController = TextEditingController();
  List<FragmentoTexto> _resultados = [];
  List<String> _historialBusqueda = [];
  bool _estaCargando = false;
  bool _mostrarResultados = false;
  String _textoBuscado = '';

  // Controlador del debounce
  Timer? _debounce;

  // Colores de la aplicación
  final Color colorPrimario = const Color.fromRGBO(188, 154, 101, 1.0);
  final Color colorSecundario = const Color.fromRGBO(242, 242, 242, 1.0);
  final Color colorTerciario = const Color.fromRGBO(44, 44, 44, 1.0);
  final Color colorCuaternario = const Color(0xFFCEC2C4);
  final Color colorQuinto = const Color.fromRGBO(30, 30, 30, 1.0);

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Método para realizar la búsqueda con debounce
  void _realizarBusqueda(String texto) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _textoBuscado = texto;

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (texto.trim().isEmpty) {
        setState(() {
          _resultados = [];
          _mostrarResultados = false;
        });
        return;
      }

      setState(() {
        _estaCargando = true;
        _mostrarResultados = true;
      });

      try {
        final resultados = await _baseDatos.buscarFragmentos(texto);

        // Agregar a historial si la búsqueda devuelve resultados y la consulta es lo suficientemente larga
        if (resultados.isNotEmpty &&
            !_historialBusqueda.contains(texto) &&
            texto.length > 3) {
          setState(() {
            _historialBusqueda.insert(0, texto);
            // Limitar el historial a 10 elementos
            if (_historialBusqueda.length > 10) {
              _historialBusqueda.removeLast();
            }
          });
        }

        setState(() {
          _resultados = resultados;
          _estaCargando = false;
        });
      } catch (e) {
        debugPrint('Error en la búsqueda: $e');
        setState(() {
          _resultados = [];
          _estaCargando = false;
        });
      }
    });
  }

  // Método para resaltar el texto buscado en los resultados
  Widget _resaltarTexto(String texto, String consulta) {
    if (consulta.isEmpty) return Text(texto, style: textos.textoBusquedaScreen);

    List<String> partes = [];
    List<bool> esResaltado = [];

    // Normalizar para la comparación
    String textoLower = texto.toLowerCase();
    String consultaLower = consulta.toLowerCase();

    int currentIndex = 0;

    // Encontrar todas las ocurrencias de la consulta en el texto
    while (true) {
      int matchIndex = textoLower.indexOf(consultaLower, currentIndex);
      if (matchIndex == -1) break;

      // Añadir la parte antes del match
      if (matchIndex > currentIndex) {
        partes.add(texto.substring(currentIndex, matchIndex));
        esResaltado.add(false);
      }

      // Añadir la parte que coincide (usando el texto original para preservar mayúsculas/minúsculas)
      partes.add(texto.substring(matchIndex, matchIndex + consulta.length));
      esResaltado.add(true);

      currentIndex = matchIndex + consulta.length;
    }

    // Añadir el resto del texto
    if (currentIndex < texto.length) {
      partes.add(texto.substring(currentIndex));
      esResaltado.add(false);
    }

    // Si no se encontraron coincidencias, mostrar texto normal
    if (partes.isEmpty) {
      return Text(texto, style: textos.textoBusquedaScreen);
    }

    // Crear spans para cada parte
    List<TextSpan> spans = [];
    for (int i = 0; i < partes.length; i++) {
      spans.add(
        TextSpan(
          text: partes[i],
          style:
              esResaltado[i]
                  ? TextStyle(
                    color: colorPrimario,
                    fontWeight: FontWeight.bold,
                    backgroundColor: colorPrimario.withOpacity(0.2),
                  )
                  : null,
        ),
      );
    }

    return RichText(
      text: TextSpan(style: textos.textoBusquedaScreen, children: spans),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        color: colorTerciario,
        child: Column(
          children: [
            // Barra de búsqueda
            SafeArea(
              child: Container(
                width: size.width,
                height: size.height * 0.1,
                color: colorTerciario,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
                  child: Row(
                    children: [
                      // Icono de volver atrás
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: colorSecundario,
                          size: size.width * 0.06,
                        ),
                        onPressed: () {
                          // Acción para volver atrás
                          // Navigator.pop(context);
                          context.replace('/chats');
                        },
                      ),
                      // Espacio entre el icono y el TextField
                      SizedBox(width: size.width * 0.02),
                      // TextField expandido para ocupar el resto del espacio
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          cursorColor: colorSecundario,
                          style: textos.textoBusquedaScreen,
                          decoration: InputDecoration(
                            hintText: 'Buscar...',
                            hintStyle: TextStyle(color: colorSecundario),
                            filled: true,
                            fillColor: colorQuinto,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: size.height * 0.025,
                              horizontal: size.width * 0.05,
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(
                                size.width * 0.07,
                              ),
                            ),
                            suffixIcon:
                                _searchController.text.isNotEmpty
                                    ? IconButton(
                                      icon: Icon(
                                        Icons.clear,
                                        color: colorSecundario,
                                      ),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {
                                          _mostrarResultados = false;
                                          _resultados = [];
                                        });
                                      },
                                    )
                                    : null,
                          ),
                          onChanged: (value) {
                            _realizarBusqueda(value);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Lista de resultados
            Expanded(
              child:
                  _estaCargando
                      ? Center(
                        child: CircularProgressIndicator(
                          color: colorPrimario,
                          strokeWidth: 3,
                        ),
                      )
                      : _mostrarResultados
                      ? _resultados.isEmpty
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.travel_explore,
                                  size: size.width * 0.2,
                                  color: colorSecundario.withOpacity(0.7),
                                ),
                                SizedBox(height: size.height * 0.02),
                                Text(
                                  "No se encontraron resultados",
                                  style: textos.texto2BusquedaScreen,
                                ),
                                SizedBox(height: size.height * 0.01),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: size.width * 0.1,
                                  ),
                                  child: Text(
                                    '"$_textoBuscado"',
                                    textAlign: TextAlign.center,
                                    style: textos.texto3BusquedaScreen,
                                  ),
                                ),
                              ],
                            ),
                          )
                          : ListView.builder(
                            itemCount: _resultados.length,
                            padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.04,
                              vertical: size.height * 0.01,
                            ),
                            itemBuilder: (context, index) {
                              final resultado = _resultados[index];
                              return Container(
                                margin: EdgeInsets.only(
                                  bottom: size.height * 0.015,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      colorQuinto,
                                      colorQuinto.withOpacity(0.9),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: colorPrimario.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () {
                                      // Acción al seleccionar un resultado
                                    },
                                    splashColor: colorPrimario.withOpacity(0.1),
                                    highlightColor: colorPrimario.withOpacity(
                                      0.05,
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(
                                        size.width * 0.04,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // ID del fragmento con un diseño sutil
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: size.width * 0.02,
                                              vertical: size.height * 0.005,
                                            ),
                                            decoration: BoxDecoration(
                                              color: colorPrimario.withOpacity(
                                                0.2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              'Fragmento #${resultado.id}',
                                              style:
                                                  textos.texto4BusquedaScreen,
                                            ),
                                          ),
                                          SizedBox(height: size.height * 0.01),
                                          // Contenido del fragmento con el texto resaltado
                                          _resaltarTexto(
                                            resultado.texto,
                                            _textoBuscado,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                      : _historialBusqueda.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history_toggle_off,
                              size: size.width * 0.2,
                              color: colorSecundario.withOpacity(0.7),
                            ),
                            SizedBox(height: size.height * 0.02),
                            Text(
                              "Historial Vacío",
                              style: textos.texto2BusquedaScreen,
                            ),
                            SizedBox(height: size.height * 0.01),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.1,
                              ),
                              child: Text(
                                "Puedes empezar a buscar para crear tu historial de búsquedas",
                                textAlign: TextAlign.center,
                                style: textos.texto3BusquedaScreen,
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        itemCount: _historialBusqueda.length,
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.04,
                          vertical: size.height * 0.01,
                        ),
                        itemBuilder: (context, index) {
                          final busqueda = _historialBusqueda[index];
                          return Container(
                            margin: EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: colorQuinto,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: colorPrimario.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: colorPrimario.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.history,
                                  color: colorPrimario,
                                  size: size.width * 0.05,
                                ),
                              ),
                              title: Text(
                                busqueda,
                                style: textos.textoBusquedaScreen,
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                color: colorSecundario.withOpacity(0.5),
                                size: size.width * 0.04,
                              ),
                              onTap: () {
                                _searchController.text = busqueda;
                                _realizarBusqueda(busqueda);
                              },
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

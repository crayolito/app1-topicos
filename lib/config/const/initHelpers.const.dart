import 'package:flutter/widgets.dart';
import 'package:topicos_app1/config/const/textos.const.dart';

class InitHelpers {
  static InitHelpers? _instancia;
  late Size sizeApp;
  late Textos actualTextosApp;

  InitHelpers._internal(BuildContext context) {
    sizeApp = MediaQuery.of(context).size;
    actualTextosApp = Textos(context);
  }

  static InitHelpers getInstance(BuildContext context) {
    _instancia ??= InitHelpers._internal(context);
    return _instancia!;
  }

  static Size get actualSize => _ensureInitialized().sizeApp;
  static Textos get actualTextos => _ensureInitialized().actualTextosApp;

  static void inicializar(BuildContext context) {
    getInstance(context);
  }

  static InitHelpers _ensureInitialized() {
    if (_instancia == null) {
      throw Exception('InitHelpers not initialized. Call inicializar() first.');
    }
    return _instancia!;
  }

  static void dispose() {
    _instancia = null;
  }
}

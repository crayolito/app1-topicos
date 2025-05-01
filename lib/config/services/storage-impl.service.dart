import 'package:shared_preferences/shared_preferences.dart';
import 'package:topicos_app1/config/services/storage.service.dart';

class ServicioAlmacenamientoImpl extends StorageService {
  @override
  Future<bool> eliminarDato(String clave) async {
    if (clave.isEmpty) {
      return false; // No podemos eliminar con clave vacía
    }

    try {
      final preferencias = await SharedPreferences.getInstance();
      return await preferencias.remove(clave);
    } catch (error) {
      print('Error al eliminar dato: $error');
      return false;
    }
  }

  @override
  Future<bool> guardarDato(String clave, String valor) async {
    if (clave.isEmpty) {
      return false;
    }

    try {
      final preferencias = await SharedPreferences.getInstance();
      return await preferencias.setString(clave, valor);
    } catch (error) {
      print('Error al guardar dato: $error');
      return false;
    }
  }

  @override
  Future<String?> obtenerDato(String clave) async {
    if (clave.isEmpty) {
      return null;
    }

    try {
      final preferencias = await SharedPreferences.getInstance();
      return preferencias.getString(clave);
    } catch (error) {
      print('Error al obtener dato: $error');
      return null;
    }
  }

  Future<bool> existeDato(String clave) async {
    if (clave.isEmpty) {
      return false;
    }

    try {
      final preferencias = await SharedPreferences.getInstance();
      return preferencias.containsKey(clave);
    } catch (error) {
      print('Error al verificar dato: $error');
      return false;
    }
  }
}

abstract class StorageService {
  Future<void> guardarDato(String key, String value);
  Future<String?> obtenerDato(String key);
  Future<void> eliminarDato(String key);
}

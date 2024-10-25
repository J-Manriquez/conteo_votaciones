import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conteo_votaciones/database/singleton_db.dart';

class MesaTableService {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'mesas'; // Nombre de la colección en Firestore

  // Método para crear una mesa en la colección `mesas`
  Future<void> createMesa(String mesaId, String nombre, String ubicacion,
      String encargado, Map<String, int> votos) async {
    // Verifica si el documento ya existe en la colección `mesas`
    DocumentSnapshot mesaSnapshot = await _firestoreService.getDocumentId(
        _collectionName, mesaId); // Busca el documento por ID

    // Si el documento no existe, lo creamos
    if (!mesaSnapshot.exists) {
      await _firestoreService.addDocumentWithId(_collectionName, mesaId, {
        'nombre': nombre,
        'ubicacion': ubicacion,
        'encargado': encargado,
        'votos': votos, // Almacena los votos como un mapa
      });
      print('Mesa creada exitosamente');
    } else {
      print('La mesa ya existe en la base de datos');
    }
  }

  // Método para actualizar una mesa existente
  Future<void> updateMesa(String mesaId, String nombre, String ubicacion,
      String encargado, Map<String, int> votos) async {
    try {
      // Crea un mapa de datos a actualizar
      Map<String, dynamic> updatedData = {
        'nombre': nombre,
        'ubicacion': ubicacion,
        'encargado': encargado,
        'votos': votos, // Actualiza los votos como un mapa
      };

      // Actualiza el documento en Firestore
      await _firestore.collection(_collectionName).doc(mesaId).update(updatedData);
      print('Mesa actualizada exitosamente');
    } catch (e) {
      print('Error al actualizar mesa: $e');
    }
  }

  // Método para eliminar una mesa
  Future<void> deleteMesa(String mesaId) async {
    try {
      await _firestore.collection(_collectionName).doc(mesaId).delete();
      print('Mesa eliminada exitosamente');
    } catch (e) {
      print('Error al eliminar mesa: $e');
    }
  }
}

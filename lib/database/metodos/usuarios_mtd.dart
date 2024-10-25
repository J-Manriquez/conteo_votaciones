import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conteo_votaciones/database/singleton_db.dart';

class UserTableService {
  final FirestoreService _firestoreService = FirestoreService();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'usuarios'; // Nombre de la colección en Firestore

  // Método para crear un usuario en la colección `usuarios`
  Future<void> createUser(String userId, String nombre, {String? cargo}) async {
    // Verifica si el documento ya existe en la colección `usuarios`
    DocumentSnapshot userSnapshot = await _firestoreService.getDocumentId(
        'usuarios', userId); // Busca el documento por ID

    // Si el documento no existe, lo creamos
    if (!userSnapshot.exists) {
      await _firestoreService.addDocumentWithId('usuarios', userId, {
        'nombre': nombre,
        'cargo': cargo ?? '', // Cargo opcional, se guarda como cadena vacía si no se proporciona
      });
      print('Usuario creado exitosamente');
    } else {
      print('El usuario ya existe en la base de datos');
    }
  }

  // Método para actualizar un usuario existente
  Future<void> updateUser(String userId, String nombre, {String? cargo}) async {
    try {
      await _firestore.collection(_collectionName).doc(userId).update({
        'nombre': nombre,
        'cargo': cargo ?? '', // Actualiza el cargo como cadena vacía si no se proporciona
      });
      print('Usuario actualizado exitosamente');
    } catch (e) {
      print('Error al actualizar usuario: $e');
    }
  }

  // Método para eliminar un usuario
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection(_collectionName).doc(userId).delete();
      print('Usuario eliminado exitosamente');
    } catch (e) {
      print('Error al eliminar usuario: $e');
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conteo_votaciones/database/singleton_db.dart';

class CandidateTableService {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'candidatos'; // Nombre de la colección en Firestore

  // Método para crear un candidato en la colección `candidatos`
  Future<void> createCandidate(
    String candidateId,
    String nombre,
    String cargoPostulacion,
  ) async {
    // Verifica si el documento ya existe en la colección `candidatos`
    DocumentSnapshot candidateSnapshot = await _firestoreService.getDocumentId(
      _collectionName,
      candidateId,
    ); // Busca el documento por ID

    // Si el documento no existe, lo creamos
    if (!candidateSnapshot.exists) {
      await _firestoreService.addDocumentWithId(_collectionName, candidateId, {
        'nombre': nombre,
        'cargo_postulacion': cargoPostulacion,
      });
      print('Candidato creado exitosamente');
    } else {
      print('El candidato ya existe en la base de datos');
    }
  }

  // Método para actualizar un candidato existente
  Future<void> updateCandidate(
    String candidateId,
    String nombre,
    String cargoPostulacion,
  ) async {
    try {
      await _firestore.collection(_collectionName).doc(candidateId).update({
        'nombre': nombre,
        'cargo_postulacion': cargoPostulacion,
      });
      print('Candidato actualizado exitosamente');
    } catch (e) {
      print('Error al actualizar candidato: $e');
    }
  }

  // Método para eliminar un candidato
  Future<void> deleteCandidate(String candidateId) async {
    try {
      await _firestore.collection(_collectionName).doc(candidateId).delete();
      print('Candidato eliminado exitosamente');
    } catch (e) {
      print('Error al eliminar candidato: $e');
    }
  }

    // Método para obtener todos los candidatos
  Future<List<Candidate>> getAllCandidates() async {
    try {
      // Obtiene todos los documentos en la colección `candidatos`
      QuerySnapshot querySnapshot = await _firestore.collection(_collectionName).get();

      // Mapea cada documento a una instancia de `Candidate` usando el constructor `fromFirestore`
      List<Candidate> candidates = querySnapshot.docs
          .map((doc) => Candidate.fromFirestore(doc))
          .toList();

      return candidates;
    } catch (e) {
      print('Error al obtener candidatos: $e');
      return []; // Devuelve una lista vacía en caso de error
    }
  }

}
class Candidate {
  final String id;
  final String nombre;
  final String cargoPostulacion;

  Candidate({
    required this.id,
    required this.nombre,
    required this.cargoPostulacion,
  });

  // Factory constructor para crear una instancia de Candidate a partir de un DocumentSnapshot
  factory Candidate.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Candidate(
      id: doc.id,
      nombre: data['nombre'],
      cargoPostulacion: data['cargo_postulacion'],
    );
  }
}


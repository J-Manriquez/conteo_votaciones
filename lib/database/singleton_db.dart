import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // 1. Creamos una instancia estática privada de FirestoreService
  static final FirestoreService _instance = FirestoreService._internal();

  // 2. Constructor privado para evitar instancias adicionales
  FirestoreService._internal();

  // 3. Método factory que devuelve la misma instancia cada vez
  factory FirestoreService() {
    return _instance;
  }

  // 4. Referencia a Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Método para eliminar los votos de un candidato
  Future<void> deleteCandidateVotes(String candidateId) async {
    // Obtiene todos los documentos de la colección 'mesas' donde el campo 'candidateId' coincide
    QuerySnapshot votesSnapshot = await _firestore.collection('mesas')
        .where('candidateId', isEqualTo: candidateId) // Asegúrate de que este sea el nombre correcto del campo
        .get();

    // Elimina cada documento relacionado
    for (var vote in votesSnapshot.docs) {
      await vote.reference.delete();
    }
  }
  
  // Agregar un documento con un ID específico
  Future<void> addDocumentWithId(String collectionPath, String docId, Map<String, dynamic> data) async {
    await _firestore.collection(collectionPath).doc(docId).set(data);
  }
  
  // Obtener un documento por su ID
  Future<DocumentSnapshot> getDocumentId(String collectionPath, String docId) async {
    return await _firestore.collection(collectionPath).doc(docId).get();
  }

  // 5. Método para agregar un documento a una colección
  Future<void> addDocument(String collectionPath, Map<String, dynamic> data) async {
    await _firestore.collection(collectionPath).add(data); // Agrega un nuevo documento
  }

  // 6. Método para obtener documentos de una colección
  Stream<QuerySnapshot> getDocuments(String collectionPath) {
    return _firestore.collection(collectionPath).snapshots(); // Obtiene documentos en tiempo real
  }

  // 7. Método para actualizar un documento en una colección
  Future<void> updateDocument(String collectionPath, String docId, Map<String, dynamic> data) async {
    await _firestore.collection(collectionPath).doc(docId).update(data); // Actualiza documento
  }

  // 8. Método para eliminar un documento
  Future<void> deleteDocument(String collectionPath, String docId) async {
    await _firestore.collection(collectionPath).doc(docId).delete(); // Elimina documento
  }
}

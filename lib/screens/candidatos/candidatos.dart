import 'package:flutter/material.dart';
import 'package:conteo_votaciones/screens/candidatos/agregarEditarCandidato.dart'; // Asegúrate de que la ruta es correcta
import 'package:conteo_votaciones/database/singleton_db.dart';

class CandidatosScreen extends StatefulWidget {
  @override
  _CandidatosScreenState createState() => _CandidatosScreenState();
}

class _CandidatosScreenState extends State<CandidatosScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  // Función para eliminar un candidato y sus votos relacionados
  Future<void> _deleteCandidate(String candidateId) async {
    // Eliminar los votos del candidato en la colección 'mesas'
    await _firestoreService.deleteCandidateVotes(candidateId);

    // Eliminar el candidato de la colección 'candidatos'
    await _firestoreService.deleteDocument('candidatos', candidateId);

    // Mostrar mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Candidato y sus votos eliminados')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Candidatos'),
      ),
      body: Column(
        children: [
          // Botón para añadir candidato
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddCandidateScreen()),
                );
              },
              child: Text('Añadir Candidato'),
            ),
          ),
          // Lista de candidatos en tarjetas
          Expanded(
            child: StreamBuilder(
              stream: _firestoreService.getDocuments('candidatos'), // Escucha los cambios en la colección
              builder: (context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final candidates = snapshot.data.docs;

                return ListView.builder(
                  itemCount: candidates.length,
                  itemBuilder: (context, index) {
                    var candidate = candidates[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: ListTile(
                        title: Text(candidate['nombre']), // Nombre del candidato
                        subtitle: Text('Cargo: ${candidate['cargo_postulacion']}'), // Cargo del candidato
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Botón de editar
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                // Navegar a AddCandidateScreen para editar el candidato
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddCandidateScreen.edit(
                                      candidateId: candidate.id, // ID del candidato
                                      nombre: candidate['nombre'], // Nombre del candidato
                                      cargoPostulacion: candidate['cargo_postulacion'], // Cargo del candidato
                                    ),
                                  ),
                                );
                              },
                            ),
                            // Botón de eliminar
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _deleteCandidate(candidate.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

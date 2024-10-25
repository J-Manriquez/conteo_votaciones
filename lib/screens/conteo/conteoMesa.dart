import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conteo_votaciones/database/singleton_db.dart'; // Asegúrate de tener esta ruta

class VoteCountingScreen extends StatefulWidget {
  final String mesaId; // ID de la mesa

  const VoteCountingScreen({Key? key, required this.mesaId}) : super(key: key);

  @override
  _VoteCountingScreenState createState() => _VoteCountingScreenState();
}

class _VoteCountingScreenState extends State<VoteCountingScreen> {
  final FirestoreService _firestoreService = FirestoreService(); // Servicio Firestore
  List<String> _candidates = []; // Lista de candidatos
  Map<String, Map<String, int>> _votes = {}; // Mapa para almacenar los votos por candidato
  String? _openCandidate; // Almacena el candidato cuya tarjeta está abierta

  @override
  void initState() {
    super.initState();
    _fetchCandidates(); // Obtener la lista de candidatos
  }

  // Función para obtener todos los nombres de los candidatos
  Future<void> _fetchCandidates() async {
    // Usar el método getDocuments para obtener la colección de candidatos
    _firestoreService.getDocuments('candidatos').listen((QuerySnapshot snapshot) {
      setState(() {
        _candidates = snapshot.docs.map((doc) => doc['nombre'] as String).toList(); // Extrae los nombres de los documentos

        // Inicializa el mapa de votos por candidato
        for (var candidate in _candidates) {
          // Inicializa cada candidato con valores por defecto
          _votes[candidate] = {
            'validos': 0,
            'blancos': 0,
            'objetados': 0,
            'nulos': 0,
          };
        }
      });

      // Llama a la función para obtener los votos de la mesa
      _fetchVotesForMesa();
    });
  }

  // Función para obtener los votos de la mesa desde Firestore
  Future<void> _fetchVotesForMesa() async {
    DocumentSnapshot mesaSnapshot = await _firestoreService.getDocumentId('mesas', widget.mesaId);
    if (mesaSnapshot.exists) {
      // Si la mesa existe, inicializa los votos desde los datos de la mesa
      Map<String, dynamic> mesaData = mesaSnapshot.data() as Map<String, dynamic>;

      // Verifica si hay votos para cada candidato
      for (var candidate in _candidates) {
        if (mesaData['votos'] != null && mesaData['votos'][candidate] != null) {
          // Actualiza los votos desde la base de datos
          _votes[candidate] = {
            'validos': mesaData['votos'][candidate]['validos'] ?? 0,
            'blancos': mesaData['votos'][candidate]['blancos'] ?? 0,
            'objetados': mesaData['votos'][candidate]['objetados'] ?? 0,
            'nulos': mesaData['votos'][candidate]['nulos'] ?? 0,
          };
        }
      }
      setState(() {}); // Actualiza el estado para reflejar los cambios
    }
  }

  // Método para guardar los votos automáticamente
  Future<void> _updateVotesInDatabase(String candidate) async {
    await _firestoreService.updateDocument(
      'mesas', // Cambia esto por el nombre de la colección de mesas
      widget.mesaId,
      {
        'votos.${candidate}.validos': _votes[candidate]!['validos'], // Actualiza votos válidos del candidato
        'votos.${candidate}.blancos': _votes[candidate]!['blancos'], // Actualiza votos blancos del candidato
        'votos.${candidate}.objetados': _votes[candidate]!['objetados'], // Actualiza votos objetados del candidato
        'votos.${candidate}.nulos': _votes[candidate]!['nulos'], // Actualiza votos nulos del candidato
      },
    );
  }

  // Método para restar votos
  void _subtractVotes(String candidate, String voteType) {
    setState(() {
      if (_votes[candidate]![voteType] != null && _votes[candidate]![voteType]! > 0) {
        _votes[candidate]![voteType] = _votes[candidate]![voteType]! - 1; // Restar 1 voto
      }
    });
    _updateVotesInDatabase(candidate); // Guardar cambios automáticamente
  }

  // Método para sumar votos
  void _addVote(String candidate, String voteType) {
    setState(() {
      _votes[candidate]![voteType] = _votes[candidate]![voteType]! + 1; // Sumar 1 voto
    });
    _updateVotesInDatabase(candidate); // Guardar cambios automáticamente
  }

  // Método para alternar la visibilidad de la tarjeta
  void _toggleCandidate(String candidate) {
    setState(() {
      if (_openCandidate == candidate) {
        _openCandidate = null; // Cierra la tarjeta si ya está abierta
      } else {
        _openCandidate = candidate; // Abre la tarjeta del candidato seleccionado
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conteo de Votos'), // Título de la pantalla
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Mostrar los candidatos y sus campos de votos
            Expanded(
              child: ListView.builder(
                itemCount: _candidates.length,
                itemBuilder: (context, index) {
                  String candidate = _candidates[index]; // Nombre del candidato
                  bool isOpen = _openCandidate == candidate; // Verifica si la tarjeta está abierta
                  return GestureDetector(
                    onTap: () => _toggleCandidate(candidate), // Alternar visibilidad al tocar
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Nombre del candidato y su cargo
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(candidate, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    const Text('Cargo: [Cargo del candidato]'), // Debes ajustar esto según tu implementación
                                  ],
                                ),
                                // Icono de visibilidad
                                Icon(isOpen ? Icons.visibility : Icons.visibility_off),
                              ],
                            ),
                            if (isOpen) // Solo muestra las opciones si la tarjeta está abierta
                              Column(
                                children: [
                                  // Primera fila: Votos válidos y objetados
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _voteColumn(candidate, 'validos', 'Votos Válidos'),
                                      _voteColumn(candidate, 'objetados', 'Votos Objetados'),
                                    ],
                                  ),
                                  // Segunda fila: Votos blancos y nulos
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _voteColumn(candidate, 'blancos', 'Votos Blancos'),
                                      _voteColumn(candidate, 'nulos', 'Votos Nulos'),
                                    ],
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
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

  // Método para crear una columna de votos
  Widget _voteColumn(String candidate, String voteType, String label) {
    return Column(
      children: [
        Text(label), // Etiqueta del tipo de voto
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () => _subtractVotes(candidate, voteType), // Restar voto y guardar
            ),
            Text('${_votes[candidate]![voteType]}'), // Mostrar votos
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _addVote(candidate, voteType), // Sumar voto y guardar
            ),
          ],
        ),
      ],
    );
  }
}

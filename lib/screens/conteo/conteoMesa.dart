import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conteo_votaciones/database/singleton_db.dart';
import 'package:conteo_votaciones/database/metodos/candidatos_mtd.dart';

class VoteCountingScreen extends StatefulWidget {
  final String mesaId;

  const VoteCountingScreen({Key? key, required this.mesaId}) : super(key: key);

  @override
  _VoteCountingScreenState createState() => _VoteCountingScreenState();
}

class _VoteCountingScreenState extends State<VoteCountingScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final CandidateTableService _candidateTableService = CandidateTableService();
  List<String> _candidates = [];
  Map<String, Map<String, int>> _votes = {};
  String? _openCandidate;
  Map<String, String> _cargosCandidatos = {};
  StreamSubscription<QuerySnapshot>? _candidatesSubscription;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _candidatesSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeData() async {
    try {
      await _fetchCandidatesCargos();
      await _setupCandidatesSubscription();
    } catch (e) {
      if (mounted) {
        // Manejar el error apropiadamente, tal vez mostrar un snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar los datos: $e')),
        );
      }
    }
  }

  Future<void> _fetchCandidatesCargos() async {
    if (!mounted) return;
    
    try {
      var candidatos = await _candidateTableService.getAllCandidates();
      if (!mounted) return;

      setState(() {
        _cargosCandidatos = {
          for (var candidato in candidatos)
            candidato.nombre: candidato.cargoPostulacion
        };
      });
    } catch (e) {
      print('Error fetching cargos: $e');
    }
  }

  Future<void> _setupCandidatesSubscription() async {
    _candidatesSubscription?.cancel();
    
    _candidatesSubscription = _firestoreService.getDocuments('candidatos').listen(
      (QuerySnapshot snapshot) async {
        if (!mounted) return;

        setState(() {
          _candidates = snapshot.docs.map((doc) => doc['nombre'] as String).toList();
          _votes = {
            for (var candidate in _candidates)
              candidate: {
                'validos': 0,
                'blancos': 0,
                'objetados': 0,
                'nulos': 0,
              }
          };
        });

        await _fetchVotesForMesa();
        
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al cargar candidatos: $error')),
          );
        }
      },
    );
  }

  Future<void> _fetchVotesForMesa() async {
    if (!mounted) return;

    try {
      DocumentSnapshot mesaSnapshot = await _firestoreService.getDocumentId('mesas', widget.mesaId);
      if (!mounted) return;

      if (mesaSnapshot.exists) {
        Map<String, dynamic> mesaData = mesaSnapshot.data() as Map<String, dynamic>;
        
        setState(() {
          for (var candidate in _candidates) {
            if (mesaData['votos']?[candidate] != null) {
              _votes[candidate] = {
                'validos': mesaData['votos'][candidate]['validos'] ?? 0,
                'blancos': mesaData['votos'][candidate]['blancos'] ?? 0,
                'objetados': mesaData['votos'][candidate]['objetados'] ?? 0,
                'nulos': mesaData['votos'][candidate]['nulos'] ?? 0,
              };
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar votos: $e')),
        );
      }
    }
  }

  Future<void> _updateVotesInDatabase(String candidate) async {
    if (!mounted) return;

    try {
      await _firestoreService.updateDocument(
        'mesas',
        widget.mesaId,
        {
          'votos.$candidate.validos': _votes[candidate]!['validos'],
          'votos.$candidate.blancos': _votes[candidate]!['blancos'],
          'votos.$candidate.objetados': _votes[candidate]!['objetados'],
          'votos.$candidate.nulos': _votes[candidate]!['nulos'],
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar votos: $e')),
        );
      }
    }
  }

  void _subtractVotes(String candidate, String voteType) {
    if (!mounted) return;
    
    if (_votes[candidate]?[voteType] != null && _votes[candidate]![voteType]! > 0) {
      setState(() {
        _votes[candidate]![voteType] = _votes[candidate]![voteType]! - 1;
      });
      _updateVotesInDatabase(candidate);
    }
  }

  void _addVote(String candidate, String voteType) {
    if (!mounted) return;

    setState(() {
      _votes[candidate]![voteType] = (_votes[candidate]?[voteType] ?? 0) + 1;
    });
    _updateVotesInDatabase(candidate);
  }

  void _toggleCandidate(String candidate) {
    if (!mounted) return;
    
    setState(() {
      _openCandidate = _openCandidate == candidate ? null : candidate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conteo de Votos'),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _candidates.length,
                    itemBuilder: (context, index) {
                      String candidate = _candidates[index];
                      bool isOpen = _openCandidate == candidate;
                      return GestureDetector(
                        onTap: () => _toggleCandidate(candidate),
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
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(candidate, 
                                          style: const TextStyle(
                                            fontSize: 18, 
                                            fontWeight: FontWeight.bold
                                          )
                                        ),
                                        Text('Cargo: ${_cargosCandidatos[candidate] ?? "Cargando..."}'),
                                      ],
                                    ),
                                    Icon(isOpen ? Icons.visibility : Icons.visibility_off),
                                  ],
                                ),
                                if (isOpen)
                                  Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          _voteColumn(candidate, 'validos', 'Votos Válidos'),
                                          _voteColumn(candidate, 'objetados', 'Votos Objetados'),
                                        ],
                                      ),
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

  Widget _voteColumn(String candidate, String voteType, String label) {
    return Column(
      children: [
        Text(label),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () => _subtractVotes(candidate, voteType),
            ),
            Text('${_votes[candidate]?[voteType] ?? 0}'),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _addVote(candidate, voteType),
            ),
          ],
        ),
      ],
    );
  }
}
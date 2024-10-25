import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conteo_votaciones/database/singleton_db.dart';
import 'package:conteo_votaciones/database/metodos/candidatos_mtd.dart';

class VoteCountingScreen extends StatefulWidget {
  final String mesaId;
  final bool showAppBar; // Controla la visibilidad del AppBar

  const VoteCountingScreen({Key? key, required this.mesaId,
  this.showAppBar = true}) : super(key: key);

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

    _candidatesSubscription =
        _firestoreService.getDocuments('candidatos').listen(
      (QuerySnapshot snapshot) async {
        if (!mounted) return;

        setState(() {
          _candidates =
              snapshot.docs.map((doc) => doc['nombre'] as String).toList();
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
      DocumentSnapshot mesaSnapshot =
          await _firestoreService.getDocumentId('mesas', widget.mesaId);
      if (!mounted) return;

      if (mesaSnapshot.exists) {
        Map<String, dynamic> mesaData =
            mesaSnapshot.data() as Map<String, dynamic>;

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

    if (_votes[candidate]?[voteType] != null &&
        _votes[candidate]![voteType]! > 0) {
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

  // Definimos los colores para cada tipo de voto
  final Map<String, Color> _voteColors = {
    'validos': Colors.green.shade300,
    'blancos': Colors.grey.shade400,
    'objetados': Colors.red.shade300,
    'nulos': const Color.fromARGB(120, 0, 0, 0),
  };
  final Map<String, Color> _voteBorderColors = {
    'validos': Colors.green.shade300,
    'blancos': Colors.grey.shade400,
    'objetados': Colors.red.shade300,
    'nulos': const Color.fromARGB(120, 0, 0, 0),
  };
  
  get showAppBar => true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text('Conteo de Votos'), // Título del AppBar
            )
          : null, 
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
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              elevation: 5,
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(candidate,
                                                style: const TextStyle(
                                                    fontSize: 22,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Text(
                                              'Cargo: ${_cargosCandidatos[candidate] ?? "Cargando..."}',
                                              style: TextStyle(fontSize: 17),
                                            ),
                                          ],
                                        ),
                                        Icon(isOpen
                                            ? Icons.visibility
                                            : Icons.visibility_off),
                                      ],
                                    ),
                                    if (isOpen) ...[
                                      const SizedBox(height: 16),
                                      GridView.count(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        crossAxisCount: 2,
                                        mainAxisSpacing: 4,
                                        crossAxisSpacing: 4,
                                        childAspectRatio: 1.25,
                                        children: [
                                          _voteContainer(candidate, 'validos',
                                              'Votos Válidos'),
                                          _voteContainer(candidate, 'objetados',
                                              'Votos Objetados'),
                                          _voteContainer(candidate, 'blancos',
                                              'Votos en Blanco'),
                                          _voteContainer(candidate, 'nulos',
                                              'Votos Nulos'),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ));
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Widget _voteColumn(String candidate, String voteType, String label) {
  //   return Column(
  //     children: [
  //       Text(label),
  //       Row(
  //         children: [
  //           IconButton(
  //             icon: const Icon(Icons.remove),
  //             onPressed: () => _subtractVotes(candidate, voteType),
  //           ),
  //           Text('${_votes[candidate]?[voteType] ?? 0}'),
  //           IconButton(
  //             icon: const Icon(Icons.add),
  //             onPressed: () => _addVote(candidate, voteType),
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  Widget _voteContainer(String candidate, String voteType, String label) {
    return Container(
      decoration: BoxDecoration(
        color: _voteColors[voteType],
        // border: Border.all(
        //   color: _voteBorderColors[voteType]!,
        //   width: 2,
        // ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.25),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(255, 255, 255, 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () => _subtractVotes(candidate, voteType),
                color: Color.fromRGBO(255, 255, 255, 1),
                iconSize: 40,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _voteBorderColors[voteType]!.withOpacity(0.5),
                  ),
                ),
                child: Text(
                  '${_votes[candidate]?[voteType] ?? 0}',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: _voteBorderColors[voteType],
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => _addVote(candidate, voteType),
                color: Color.fromRGBO(255, 255, 255, 1),
                iconSize: 40,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

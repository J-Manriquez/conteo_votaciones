import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conteo_votaciones/database/singleton_db.dart';
import 'package:conteo_votaciones/database/metodos/candidatos_mtd.dart'; // Importa el servicio de candidatos

class RecuentoVotosScreen extends StatefulWidget {
  const RecuentoVotosScreen({Key? key}) : super(key: key);

  @override
  _RecuentoVotosScreenState createState() => _RecuentoVotosScreenState();
}

class _RecuentoVotosScreenState extends State<RecuentoVotosScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final CandidateTableService _candidateTableService = CandidateTableService();
  bool _isTableVisible = false;
  String _selectedSorting = 'votos_validos';
  String? _selectedCargo;

  List<String> _cargos = [
    'Alcalde',
    'Concejo Municipal',
    'Gobernador',
    'Consejo Regional'
  ];

  // Mapa que asociará cada candidato con su cargo
  Map<String, String> _cargosCandidatos = {};

  @override
  void initState() {
    super.initState();
    // Llamar al método para obtener los candidatos y sus cargos al iniciar el widget
    _fetchCandidatesCargos();
  }

  Future<void> _fetchCandidatesCargos() async {
    // Obtiene la lista de candidatos desde el servicio y asigna el cargo a cada nombre
    var candidatos = await _candidateTableService.getAllCandidates();
    setState(() {
      _cargosCandidatos = {
        for (var candidato in candidatos) candidato.nombre: candidato.cargoPostulacion
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuento de Votos'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getDocuments('mesas'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay votos registrados.'));
          }

          Map<String, Map<String, dynamic>> votosSumados = {};
          print('****************************INICIO PROCESAMIENTO*********************************');
          print('Cargo seleccionado: $_selectedCargo');

          for (var doc in snapshot.data!.docs) {
            var data = doc.data() as Map<String, dynamic>;
            print('Procesando mesa: ${data['nombre']}');

            if (data.containsKey('votos')) {
              var votosPorCandidatos = data['votos'] as Map<String, dynamic>;
              print('Votos encontrados en la mesa: ${votosPorCandidatos.keys.length} candidatos');

              votosPorCandidatos.forEach((candidato, votos) {
                print('Procesando candidato: $candidato');
                print('Datos del candidato: $votos');
                
                // Obtener el cargo del candidato del mapa de cargos (_cargosCandidatos)
                String? cargoDelCandidato = _cargosCandidatos[candidato];

                print('Cargo del candidato: $cargoDelCandidato');
                
                // Verificar si el candidato cumple con el filtro de cargo
                if (_selectedCargo == null || cargoDelCandidato == _selectedCargo) {
                  print('El candidato cumple con el filtro de cargo');
                  
                  int votosValidos = (votos['validos'] ?? 0) as int;
                  int votosBlancos = (votos['blancos'] ?? 0) as int;
                  int votosObjetados = (votos['objetados'] ?? 0) as int;
                  int votosNulos = (votos['nulos'] ?? 0) as int;

                  if (!votosSumados.containsKey(candidato)) {
                    votosSumados[candidato] = {
                      'votos_validos': 0,
                      'votos_blancos': 0,
                      'votos_objetados': 0,
                      'votos_nulos': 0,
                      'cargo': cargoDelCandidato,
                    };
                  }

                  votosSumados[candidato]!['votos_validos'] =
                      (votosSumados[candidato]!['votos_validos'] ?? 0) + votosValidos;
                  votosSumados[candidato]!['votos_blancos'] =
                      (votosSumados[candidato]!['votos_blancos'] ?? 0) + votosBlancos;
                  votosSumados[candidato]!['votos_objetados'] =
                      (votosSumados[candidato]!['votos_objetados'] ?? 0) + votosObjetados;
                  votosSumados[candidato]!['votos_nulos'] =
                      (votosSumados[candidato]!['votos_nulos'] ?? 0) + votosNulos;
                  
                  print('Votos acumulados para $candidato: ${votosSumados[candidato]}');
                } else {
                  print('El candidato no cumple con el filtro de cargo');
                }
              });
            } else {
              print('La mesa no tiene votos registrados');
            }
          }

          print('****************************RESULTADOS FINALES*********************************');
          print('Total de candidatos procesados: ${votosSumados.length}');
          print('Resultados acumulados: $votosSumados');

          List<Map<String, dynamic>> votosData = votosSumados.entries
              .map((entry) => {
                    'candidato': entry.key,
                    ...entry.value,
                  })
              .toList();

          votosData.sort((a, b) => b[_selectedSorting].compareTo(a[_selectedSorting]));

          return SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isTableVisible = !_isTableVisible;
                    });
                  },
                  child: Card(
                    elevation: 5,
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Conteo Total',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(_isTableVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                                onPressed: () {
                                  setState(() {
                                    _isTableVisible = !_isTableVisible;
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  _showEditModal(context);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_isTableVisible)
                  DataTable(
                    dataRowHeight: 30,
                    columnSpacing: 8,
                    columns: const [
                      DataColumn(label: Text('Candidato')),
                      DataColumn(label: Text('Válidos')),
                      DataColumn(label: Text('Blancos')),
                      DataColumn(label: Text('Objetados')),
                      DataColumn(label: Text('Nulos')),
                    ],
                    rows: votosData.map((voto) {
                      return DataRow(cells: [
                        DataCell(Text(voto['candidato'])),
                        DataCell(Text(voto['votos_validos'].toString())),
                        DataCell(Text(voto['votos_blancos'].toString())),
                        DataCell(Text(voto['votos_objetados'].toString())),
                        DataCell(Text(voto['votos_nulos'].toString())),
                      ]);
                    }).toList(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEditModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Editar Configuración',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              DropdownButtonFormField<String>(
                value: _selectedSorting,
                items: const [
                  DropdownMenuItem(
                      value: 'votos_validos', child: Text('Votos Válidos')),
                  DropdownMenuItem(value: 'votos_blancos', child: Text('Votos Blancos')),
                  DropdownMenuItem(value: 'votos_objetados', child: Text('Votos Objetados')),
                  DropdownMenuItem(value: 'votos_nulos', child: Text('Votos Nulos')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedSorting = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Ordenar por'),
              ),
              DropdownButtonFormField<String>(
                value: _selectedCargo,
                items: _cargos.map((String cargo) {
                  return DropdownMenuItem(value: cargo, child: Text(cargo));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCargo = value;
                  });
                },
                decoration: const InputDecoration(labelText: 'Filtrar por Cargo'),
              ),
            ],
          ),
        );
      },
    );
  }
}

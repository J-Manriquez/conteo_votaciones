import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conteo_votaciones/database/singleton_db.dart';
import 'package:conteo_votaciones/database/metodos/candidatos_mtd.dart';

class RecuentoVotosScreen extends StatefulWidget {
  const RecuentoVotosScreen({Key? key}) : super(key: key);

  @override
  _RecuentoVotosScreenState createState() => _RecuentoVotosScreenState();
}

class _RecuentoVotosScreenState extends State<RecuentoVotosScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final CandidateTableService _candidateTableService = CandidateTableService();
  bool _isTableVisible = false;

  static List<Map<String, dynamic>> _tableConfigs = [
    {
        'title': 'Conteo Total',
        'sorting': 'votos_validos',
        'cargo': null,
        'visible': true,
        'selectedMesas': <String>[]
    }
];

  List<String> _cargos = [
    'Alcalde',
    'Concejo Municipal',
    'Gobernador',
    'Consejo Regional'
  ];

  Map<String, String> _cargosCandidatos = {};

  @override
  void initState() {
    super.initState();
    _fetchCandidatesCargos();
  }

  Future<void> _fetchCandidatesCargos() async {
    var candidatos = await _candidateTableService.getAllCandidates();
    setState(() {
      _cargosCandidatos = {
        for (var candidato in candidatos)
          candidato.nombre: candidato.cargoPostulacion
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Recuento de Votos'),
      // ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 50.0),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _tableConfigs.add({
                        'title': 'Nueva Tabla',
                        'sorting': 'votos_validos',
                        'cargo': null,
                        'visible': true,
                        'selectedMesas': <String>[]
                      });
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50)),
                  child: const Text('Añadir Tabla'),
                ),
              ),
              ..._tableConfigs.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, dynamic> config = entry.value;

                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          config['visible'] = !config['visible'];
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
                              Text(config['title'],
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(config['visible']
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                    onPressed: () {
                                      setState(() {
                                        config['visible'] = !config['visible'];
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      _showEditModal(context, index);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (config['visible']) _buildTable(config),
                  ],
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTable(Map<String, dynamic> config) {
    return StreamBuilder<QuerySnapshot>(
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

        for (var doc in snapshot.data!.docs) {
          if (config['selectedMesas'] != null &&
              config['selectedMesas'].isNotEmpty &&
              !config['selectedMesas'].contains(doc.id)) {
            continue;
          }

          var data = doc.data() as Map<String, dynamic>;

          if (data.containsKey('votos')) {
            var votosPorCandidatos = data['votos'] as Map<String, dynamic>;

            votosPorCandidatos.forEach((candidato, votos) {
              String? cargoDelCandidato = _cargosCandidatos[candidato];

              if (config['cargo'] == null ||
                  cargoDelCandidato == config['cargo']) {
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
                    (votosSumados[candidato]!['votos_validos'] ?? 0) +
                        votosValidos;
                votosSumados[candidato]!['votos_blancos'] =
                    (votosSumados[candidato]!['votos_blancos'] ?? 0) +
                        votosBlancos;
                votosSumados[candidato]!['votos_objetados'] =
                    (votosSumados[candidato]!['votos_objetados'] ?? 0) +
                        votosObjetados;
                votosSumados[candidato]!['votos_nulos'] =
                    (votosSumados[candidato]!['votos_nulos'] ?? 0) + votosNulos;
              }
            });
          }
        }

        List<Map<String, dynamic>> votosData = votosSumados.entries
            .map((entry) => {
                  'candidato': entry.key,
                  ...entry.value,
                })
            .toList();

        votosData.sort(
            (a, b) => b[config['sorting']].compareTo(a[config['sorting']]));

        return DataTable(
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
        );
      },
    );
  }

  void _showEditModal(BuildContext context, int index) {
    Map<String, dynamic> config = _tableConfigs[index];
    TextEditingController titleController =
        TextEditingController(text: config['title']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // Añadimos StatefulBuilder para actualizar el estado dentro del modal
          builder: (BuildContext context, StateSetter setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.8,
              maxChildSize: 0.9,
              minChildSize: 0.5,
              builder: (context, scrollController) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Editar Configuración',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                            labelText: 'Título de la Tabla'),
                        onChanged: (value) {
                          setState(() {
                            config['title'] = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: config['sorting'],
                        items: const [
                          DropdownMenuItem(
                              value: 'votos_validos',
                              child: Text('Votos Válidos')),
                          DropdownMenuItem(
                              value: 'votos_blancos',
                              child: Text('Votos Blancos')),
                          DropdownMenuItem(
                              value: 'votos_objetados',
                              child: Text('Votos Objetados')),
                          DropdownMenuItem(
                              value: 'votos_nulos', child: Text('Votos Nulos')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            config['sorting'] = value!;
                          });
                        },
                        decoration:
                            const InputDecoration(labelText: 'Ordenar por'),
                      ),
                      DropdownButtonFormField<String>(
                        value: config['cargo'],
                        items: _cargos.map((String cargo) {
                          return DropdownMenuItem(
                              value: cargo, child: Text(cargo));
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            config['cargo'] = value;
                          });
                        },
                        decoration: const InputDecoration(
                            labelText: 'Filtrar por Cargo'),
                      ),
                      const SizedBox(height: 16),
                      const Text('Seleccionar Mesas',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: _firestoreService.getDocuments('mesas'),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            return ListView.builder(
                              controller: scrollController,
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, i) {
                                var doc = snapshot.data!.docs[i];
                                var mesaData =
                                    doc.data() as Map<String, dynamic>;
                                String mesaId = doc.id;
                                String mesaNombre = mesaData['nombre'] ??
                                    'Mesa sin nombre'; // Asumiendo que el campo se llama 'nombre'
                                bool isSelected =
                                    (config['selectedMesas'] ?? [])
                                        .contains(mesaId);

                                return CheckboxListTile(
                                  title: Text(mesaNombre),
                                  value: isSelected,
                                  onChanged: (bool? value) {
                                    setModalState(() {
                                      // Usamos setModalState en lugar de setState
                                      if (value == true) {
                                        config['selectedMesas'] = [
                                          ...(config['selectedMesas'] ?? []),
                                          mesaId
                                        ];
                                      } else {
                                        config['selectedMesas'] =
                                            (config['selectedMesas'] as List)
                                                .where((id) => id != mesaId)
                                                .toList();
                                      }
                                    });
                                    setState(
                                        () {}); // Actualizamos también el estado principal
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

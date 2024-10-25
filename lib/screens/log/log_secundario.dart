import 'package:conteo_votaciones/database/metodos/mesas_mtd.dart';
import 'package:conteo_votaciones/screens/conRestriccion/main_conRestriccion.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MesaSelectionScreen extends StatefulWidget {
  @override
  _MesaSelectionScreenState createState() => _MesaSelectionScreenState();
}

class _MesaSelectionScreenState extends State<MesaSelectionScreen> {
  final MesaTableService _mesaService =
      MesaTableService(); // Instancia del servicio
  String?
      _selectedEncargado; // Variable para almacenar el encargado seleccionado
  List<String> _encargados = []; // Lista para almacenar los encargados
  Map<String, List<String>> _encargadoMesaMap =
      {}; // Mapa para almacenar IDs de mesas por encargado

  @override
  void initState() {
    super.initState();
    _fetchEncargados(); // Obtiene los encargados al iniciar la pantalla
  }

  // Método para obtener los encargados desde Firestore
  Future<void> _fetchEncargados() async {
    try {
      // Aquí se obtiene la colección de mesas
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('mesas').get();
      Map<String, List<String>> encargadoMesaMap =
          {}; // Mapa temporal para almacenar IDs de mesas

      // Itera sobre los documentos y agrega los encargados a la lista
      for (var doc in snapshot.docs) {
        String encargado = doc[
            'encargado']; // Asume que 'encargado' es un campo en la colección
        String mesaId = doc
            .id; // Obtiene el ID de la mesa (asumiendo que el ID del documento es el ID de la mesa)

        // Si el encargado ya está en el mapa, agrega el ID de la mesa a su lista; de lo contrario, crea una nueva lista
        if (encargadoMesaMap.containsKey(encargado)) {
          encargadoMesaMap[encargado]!.add(mesaId);
        } else {
          encargadoMesaMap[encargado] = [
            mesaId
          ]; // Inicializa la lista con el ID de la mesa
        }
      }

      setState(() {
        _encargados = encargadoMesaMap.keys
            .toList(); // Actualiza el estado con la lista de encargados
        _encargadoMesaMap =
            encargadoMesaMap; // Actualiza el mapa con IDs de mesas
      });
    } catch (e) {
      print('Error al obtener encargados: $e'); // Manejo de errores
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centra el contenido
          children: [
            Text(
              'Busca tu nombre en \nla lista de encargados',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20), // Espacio entre el texto y el dropdown
            DropdownButton<String>(
              hint: const Text(
                  'Seleccione un Encargado'), // Mensaje en el dropdown si no hay selección
              value: _selectedEncargado, // Valor seleccionado
              items: _encargados.map((String encargado) {
                return DropdownMenuItem<String>(
                  value: encargado,
                  child: Text(encargado), // Texto que se muestra en el dropdown
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedEncargado =
                      newValue; // Actualiza el encargado seleccionado
                });
              },
            ),
            const SizedBox(height: 20), // Espacio entre el dropdown y el botón
            ElevatedButton(
                onPressed: () {
                  if (_selectedEncargado != null) {
                    List<String> mesaIds = _encargadoMesaMap[
                        _selectedEncargado]!; // Obtiene la lista de IDs de mesas
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainResriccionScreen(
                            mesaIds:
                                mesaIds), // Navega a la siguiente pantalla con lista de IDs
                      ),
                    );
                  } else {
                    // Mensaje si no se ha seleccionado un encargado
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Por favor seleccione un encargado')),
                    );
                  }
                },
                child: const Text(
                  'Confirmar Selección',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ) // Texto del botón
                ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:conteo_votaciones/screens/mesas/agregarEditarMesa.dart'; // Asegúrate de tener la ruta correcta
import 'package:conteo_votaciones/database/singleton_db.dart';

class MesasScreen extends StatefulWidget {
  @override
  _MesasScreenState createState() => _MesasScreenState();
}

class _MesasScreenState extends State<MesasScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  // Función para eliminar una mesa
  Future<void> _deleteMesa(String mesaId) async {
    await _firestoreService.deleteDocument('mesas', mesaId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Mesa eliminada')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mesas'),
      ),
      body: Column(
        children: [
          // Botón para añadir mesa
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddMesaScreen()),
                );
              },
              child: Text('Añadir Mesa'),
            ),
          ),
          // Lista de mesas en tarjetas
          Expanded(
            child: StreamBuilder(
              stream: _firestoreService.getDocuments('mesas'), // Escucha los cambios en la colección de mesas
              builder: (context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final mesas = snapshot.data.docs;

                return ListView.builder(
                  itemCount: mesas.length,
                  itemBuilder: (context, index) {
                    var mesa = mesas[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: ListTile(
                        title: Text(mesa['nombre']),
                        subtitle: Text('Encargado: ${mesa['encargado'] ?? 'No asignado'}\nUbicación: ${mesa['ubicacion'] ?? 'No asignada'}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Botón de editar
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                // Navegar a AddMesaScreen para editar la mesa
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddMesaScreen.edit(
                                      mesaId: mesa.id, // ID de la mesa
                                      nombre: mesa['nombre'], // Nombre de la mesa
                                      ubicacion: mesa['ubicacion'], // Ubicación de la mesa
                                      encargado: mesa['encargado'], // Encargado de la mesa
                                    ),
                                  ),
                                );
                              },
                            ),
                            // Botón de eliminar
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _deleteMesa(mesa.id),
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

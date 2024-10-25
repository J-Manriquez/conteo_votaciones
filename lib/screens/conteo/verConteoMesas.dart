import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conteo_votaciones/database/singleton_db.dart';
import 'package:conteo_votaciones/screens/conteo/conteoMesa.dart';

class MesaListScreen extends StatefulWidget {
  @override
  _MesaListScreenState createState() => _MesaListScreenState();
}

class _MesaListScreenState extends State<MesaListScreen> {
  final FirestoreService _firestoreService = FirestoreService(); // Servicio Firestore
  List<Map<String, dynamic>> _mesas = []; // Lista de mesas con sus detalles

  @override
  void initState() {
    super.initState();
    _fetchMesas(); // Obtener la lista de mesas
  }

  // Función para obtener todas las mesas
  void _fetchMesas() {
    _firestoreService.getDocuments('mesas').listen((QuerySnapshot snapshot) {
      setState(() {
        _mesas = snapshot.docs.map((doc) => {
          'id': doc.id, // Guardamos el ID para la navegación
          'nombre': doc['nombre'], // Obtener nombre de la mesa
          'ubicacion': doc['ubicacion'], // Obtener ubicación de la mesa
          'encargado': doc['encargado'], // Obtener encargado de la mesa
        }).toList(); // Convertimos a una lista de mapas
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listado de Mesas'), // Título de la pantalla
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _mesas.isEmpty // Verifica si hay mesas
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: _mesas.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> mesa = _mesas[index]; // Datos de la mesa
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(mesa['nombre']), // Mostrar nombre de la mesa
                      subtitle: Text('Ubicación: ${mesa['ubicacion']}\nEncargado: ${mesa['encargado']}'), // Mostrar ubicación y encargado
                      trailing: const Icon(Icons.arrow_forward), // Icono de navegación
                      onTap: () {
                        // Navegar a la pantalla de conteo de votos
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VoteCountingScreen(mesaId: mesa['id']),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}

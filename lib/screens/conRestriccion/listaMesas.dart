import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conteo_votaciones/database/singleton_db.dart';
import 'package:conteo_votaciones/screens/conteo/conteoMesa.dart';

class MesaIdListScreen extends StatefulWidget {
  final List<String> mesaIds; // Lista de IDs de mesas que se recibirán como parámetro

  const MesaIdListScreen({Key? key, required this.mesaIds}) : super(key: key); // Constructor que acepta los IDs

  @override
  _MesaIdListScreenState createState() => _MesaIdListScreenState();
}

class _MesaIdListScreenState extends State<MesaIdListScreen> {
  final FirestoreService _firestoreService = FirestoreService(); // Servicio Firestore
  List<Map<String, dynamic>> _mesas = []; // Lista de mesas con sus detalles

  @override
  void initState() {
    super.initState();
    _fetchMesas(); // Obtener la lista de mesas usando los IDs
  }

  // Función para obtener mesas por IDs
  void _fetchMesas() {
    // Usamos FutureBuilder para manejar múltiples llamadas asíncronas
    Future.wait(widget.mesaIds.map((id) {
      return _firestoreService.getDocumentId('mesas', id).then((doc) {
        if (doc.exists) {
          // Solo agregar documentos existentes
          return {
            'id': doc.id,
            'nombre': doc['nombre'],
            'ubicacion': doc['ubicacion'],
            'encargado': doc['encargado'],
          };
        }
        return null; // Si el documento no existe, devolver null
      });
    })).then((mesas) {
      // Filtrar los valores nulos y actualizar el estado
      setState(() {
        _mesas = mesas.where((mesa) => mesa != null).cast<Map<String, dynamic>>().toList();
      });
    }).catchError((error) {
      // Manejar errores al obtener los documentos
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar mesas: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Listado de Mesas'), // Título de la pantalla
      // ),
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
                      title: Text(mesa['nombre'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)), // Mostrar nombre de la mesa
                      subtitle: Text('Ubicación: ${mesa['ubicacion']}\nEncargado: ${mesa['encargado']}'), // Mostrar ubicación y encargado
                      trailing: const Icon(Icons.arrow_forward), // Icono de navegación
                      onTap: () {
                        // Navegar a la pantalla de conteo de votos
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VoteCountingScreen(mesaId: mesa['id'], showAppBar: true),
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

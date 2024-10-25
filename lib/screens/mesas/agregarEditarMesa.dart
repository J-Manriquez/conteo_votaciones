import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:conteo_votaciones/database/singleton_db.dart'; // Asegúrate de tener esta ruta
import 'package:cloud_firestore/cloud_firestore.dart';

class AddMesaScreen extends StatefulWidget {
  final String? mesaId; // ID de la mesa a editar, opcional para agregar
  final String? nombre; // Nombre de la mesa, opcional para agregar
  final String? ubicacion; // Ubicación de la mesa, opcional para agregar
  final String? encargado; // Encargado de la mesa, opcional para agregar

  // Constructor para agregar una nueva mesa
  const AddMesaScreen({Key? key})
      : mesaId = null,
        nombre = null,
        ubicacion = null,
        encargado = null,
        super(key: key);

  // Constructor para editar una mesa existente
  const AddMesaScreen.edit({
    Key? key,
    required this.mesaId,
    required this.nombre,
    required this.ubicacion,
    required this.encargado,
  }) : super(key: key);

  @override
  _AddMesaScreenState createState() => _AddMesaScreenState();
}

class _AddMesaScreenState extends State<AddMesaScreen> {
  final FirestoreService _firestoreService = FirestoreService(); // Servicio Firestore
  final TextEditingController _nameController = TextEditingController(); // Controlador para el nombre
  final TextEditingController _ubicacionController = TextEditingController(); // Controlador para la ubicación
  String? _selectedEncargado; // Variable para almacenar el encargado seleccionado
  List<String> _userNames = []; // Lista para almacenar nombres de usuarios

  final Uuid uuid = const Uuid(); // Instancia para generar IDs únicos

  @override
  void initState() {
    super.initState();
    // Si estamos editando, pre-cargamos los datos
    if (widget.nombre != null && widget.ubicacion != null && widget.encargado != null) {
      _nameController.text = widget.nombre!; // Carga el nombre existente
      _ubicacionController.text = widget.ubicacion!; // Carga la ubicación existente
      _selectedEncargado = widget.encargado; // Carga el encargado existente
    }
    _fetchUserNames(); // Obtiene los nombres de los usuarios
  }

  // Función para obtener todos los nombres de los usuarios
  Future<void> _fetchUserNames() async {
    // Escucha la colección de usuarios
    _firestoreService.getDocuments('usuarios').listen((QuerySnapshot snapshot) {
      setState(() {
        _userNames = snapshot.docs.map((doc) => doc['nombre'] as String).toList(); // Extrae los nombres de los documentos
      });
    });
  }

  // Método para agregar o editar una mesa
  void _saveMesa() async {
    String mesaId;

    // Si estamos editando, usamos el ID existente
    if (widget.mesaId != null) {
      mesaId = widget.mesaId!;
      // Actualiza la mesa existente
      await _firestoreService.updateDocument(
        'mesas', // Cambia esto por el nombre de la colección de mesas
        mesaId,
        {
          'nombre': _nameController.text,
          'ubicacion': _ubicacionController.text,
          'encargado': _selectedEncargado ?? '', // Usa el encargado seleccionado
          // Eliminamos el campo candidato y los votos, ya que no son visibles
        },
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mesa actualizada exitosamente')),
      );
    } else {
      // Genera un ID único y crea una nueva mesa
      mesaId = uuid.v4(); // Genera un ID único
      await _firestoreService.addDocumentWithId(
        'mesas', // Cambia esto por el nombre de la colección de mesas
        mesaId,
        {
          'nombre': _nameController.text,
          'ubicacion': _ubicacionController.text,
          'encargado': _selectedEncargado ?? '', // Usa el encargado seleccionado
          // Eliminamos el campo candidato y los votos, ya que no son visibles
        },
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mesa agregada exitosamente')),
      );
    }

    // Limpia los campos de texto
    _nameController.clear();
    _ubicacionController.clear();
    _selectedEncargado = null; // Resetea el encargado seleccionado
    Navigator.pop(context); // Regresa a la pantalla anterior
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mesaId != null ? 'Editar Mesa' : 'Añadir Mesa'), // Título según la acción
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Campo de texto para el nombre de la mesa
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la Mesa',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            // Campo de texto para la ubicación
            TextField(
              controller: _ubicacionController,
              decoration: const InputDecoration(
                labelText: 'Ubicación',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            // Dropdown para seleccionar el encargado
            DropdownButtonFormField<String>(
              value: _selectedEncargado,
              decoration: const InputDecoration(
                labelText: 'Encargado',
                border: OutlineInputBorder(),
              ),
              items: _userNames.map((String name) {
                return DropdownMenuItem<String>(
                  value: name, // Valor del menú desplegable
                  child: Text(name), // Texto mostrado en el menú
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedEncargado = newValue; // Almacena el encargado seleccionado
                });
              },
              hint: const Text('Selecciona un encargado'), // Texto sugerido cuando no hay selección
            ),
            const SizedBox(height: 16.0),
            // Botón para añadir o editar la mesa
            ElevatedButton(
              onPressed: _saveMesa,
              child: const Text('Guardar Mesa'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ubicacionController.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:conteo_votaciones/database/metodos/usuarios_mtd.dart';

class AddUserScreen extends StatefulWidget {
  final String? userId; // ID del usuario a editar, opcional para agregar
  final String? nombre; // Nombre del usuario, opcional para agregar
  final String? cargo; // Cargo del usuario, opcional para agregar

  // Constructor para agregar un nuevo usuario
  const AddUserScreen({Key? key})
      : userId = null,
        nombre = null,
        cargo = null,
        super(key: key);

  // Constructor para editar un usuario existente
  const AddUserScreen.edit({
    Key? key,
    required this.userId,
    required this.nombre,
    required this.cargo,
  }) : super(key: key);

  @override
  _AddUserScreenState createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final UserTableService _userTableService = UserTableService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cargoController = TextEditingController();
  final Uuid uuid = const Uuid(); // Instancia para generar IDs únicos

  @override
  void initState() {
    super.initState();
    // Si estamos editando, pre-cargamos los datos
    if (widget.nombre != null && widget.cargo != null) {
      _nameController.text = widget.nombre!; // Carga el nombre existente
      _cargoController.text = widget.cargo!; // Carga el cargo existente
    }
  }

  // Método para agregar o editar un usuario
  void _saveUser() async {
    String userId;

    // Si estamos editando, usamos el ID existente
    if (widget.userId != null) {
      userId = widget.userId!;
      // Actualiza el usuario existente
      await _userTableService.updateUser(userId, _nameController.text, cargo: _cargoController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario actualizado exitosamente')),
      );
    } else {
      // Genera un ID único y crea un nuevo usuario
      userId = uuid.v4(); // Genera un ID único
      await _userTableService.createUser(userId, _nameController.text, cargo: _cargoController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario agregado exitosamente')),
      );
    }

    // Limpia los campos de texto
    _nameController.clear();
    _cargoController.clear();
    Navigator.pop(context); // Regresa a la pantalla anterior
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userId != null ? 'Editar Usuario' : 'Añadir Usuario'), // Título según la acción
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Campo de texto para el nombre
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            // Campo de texto para el cargo
            TextField(
              controller: _cargoController,
              decoration: const InputDecoration(
                labelText: 'Cargo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            // Botón para añadir o editar el usuario
            ElevatedButton(
              onPressed: _saveUser,
              child: const Text('Guardar Usuario'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cargoController.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:conteo_votaciones/database/metodos/candidatos_mtd.dart'; // Asegúrate de importar tu servicio de candidatos

class AddCandidateScreen extends StatefulWidget {
  final String? candidateId; // ID del candidato a editar, opcional para agregar
  final String? nombre; // Nombre del candidato, opcional para agregar
  final String? cargoPostulacion; // Cargo al que se postula, opcional para agregar

  // Constructor para agregar un nuevo candidato
  const AddCandidateScreen({Key? key})
      : candidateId = null,
        nombre = null,
        cargoPostulacion = null,
        super(key: key);

  // Constructor para editar un candidato existente
  const AddCandidateScreen.edit({
    Key? key,
    required this.candidateId,
    required this.nombre,
    required this.cargoPostulacion,
  }) : super(key: key);

  @override
  _AddCandidateScreenState createState() => _AddCandidateScreenState();
}

class _AddCandidateScreenState extends State<AddCandidateScreen> {
  final CandidateTableService _candidateTableService = CandidateTableService();
  final TextEditingController _nameController = TextEditingController();
  String? _selectedCargo; // Variable para almacenar el cargo seleccionado
  final List<String> _cargos = [
    'Alcalde',
    'Concejo Municipal',
    'Gobernador',
    'Consejo Regional'
  ]; // Lista de cargos

  final Uuid uuid = const Uuid(); // Instancia para generar IDs únicos

  @override
  void initState() {
    super.initState();
    // Si estamos editando, pre-cargamos los datos
    if (widget.nombre != null) {
      _nameController.text = widget.nombre!;
    }
    // Preseleccionamos el cargo si está definido
    _selectedCargo = widget.cargoPostulacion;
  }

  // Método para agregar o editar un candidato
  void _saveCandidate() async {
    String candidateId;

    // Si estamos editando, usamos el ID existente
    if (widget.candidateId != null) {
      candidateId = widget.candidateId!;
      // Actualiza el candidato existente
      await _candidateTableService.updateCandidate(
        candidateId,
        _nameController.text,
        _selectedCargo!, // Guardamos el cargo seleccionado
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Candidato actualizado exitosamente')),
      );
    } else {
      // Genera un ID único y crea un nuevo candidato
      candidateId = uuid.v4(); // Genera un ID único
      await _candidateTableService.createCandidate(
        candidateId,
        _nameController.text,
        _selectedCargo!, // Guardamos el cargo seleccionado
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Candidato agregado exitosamente')),
      );
    }

    // Limpia los campos de texto
    _nameController.clear();
    _selectedCargo = null; // Reiniciamos el cargo seleccionado
    Navigator.pop(context); // Regresa a la pantalla anterior
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.candidateId != null ? 'Editar Candidato' : 'Añadir Candidato'), // Título según la acción
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
            // Dropdown para seleccionar el cargo de postulación
            DropdownButtonFormField<String>(
              value: _selectedCargo,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCargo = newValue; // Actualiza el cargo seleccionado
                });
              },
              decoration: const InputDecoration(
                labelText: 'Cargo Postulación',
                border: OutlineInputBorder(),
              ),
              items: _cargos.map<DropdownMenuItem<String>>((String cargo) {
                return DropdownMenuItem<String>(
                  value: cargo,
                  child: Text(cargo),
                );
              }).toList(),
              hint: const Text('Selecciona un cargo'), // Texto del hint
            ),
            const SizedBox(height: 16.0),
            // Botón para añadir o editar el candidato
            ElevatedButton(
              onPressed: _saveCandidate,
              child: const Text('Guardar Candidato'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Liberamos los controladores de texto
    _nameController.dispose();
    super.dispose();
  }
}

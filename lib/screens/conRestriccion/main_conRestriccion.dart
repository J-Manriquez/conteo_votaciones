import 'package:conteo_votaciones/screens/conRestriccion/listaMesas.dart';
import 'package:conteo_votaciones/screens/conteo/recuentoVotos.dart';
import 'package:flutter/material.dart';

class MainResriccionScreen extends StatefulWidget {
  final List<String> mesaIds; // Almacena el ID de la mesa

  const MainResriccionScreen({Key? key, required this.mesaIds}) : super(key: key);
  
  @override
  _MainResriccionScreenState createState() => _MainResriccionScreenState();
}

class _MainResriccionScreenState extends State<MainResriccionScreen> {
  int _currentIndex = 0; // Índice para el Bottom Navigation Bar

  // Modificar aquí para usar widget.mesaId
  final List<Widget> _screens = []; // Inicialmente vacío

  final List<String> _titles = [
    'Recuento de Votos', // Título para Recuento de Votos
    'Lista de Mesas', // Título para Lista de Mesas
  ];

  @override
  void initState() {
    super.initState();
    // Inicializa las pantallas en el initState
    _screens.add(RecuentoVotosScreen()); // Pantalla principal
    _screens.add(MesaIdListScreen(mesaIds: widget.mesaIds,)); // Segunda pantalla
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]), // Cambia el título según el índice
      ),
      body: _screens[_currentIndex], // Muestra la pantalla actual
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Cambia la pantalla según el índice
          });
        },
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Recuento de Votos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Mesas',
          ),
        ],
      ),
    );
  }

  
}

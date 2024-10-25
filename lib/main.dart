import 'package:conteo_votaciones/screens/candidatos/candidatos.dart';
import 'package:conteo_votaciones/screens/conteo/recuentoVotos.dart';
import 'package:conteo_votaciones/screens/conteo/verConteoMesas.dart';
import 'package:conteo_votaciones/screens/mesas/mesas.dart';
import 'package:conteo_votaciones/screens/usuarios/apoderados.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Asegura la inicialización de widgets
  await Firebase.initializeApp(); // Inicializa Firebase
  runApp(const MainApp()); // Inicia la aplicación
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Conteo Votaciones', // Título de la aplicación
      home: HomeScreen(), // Establece la pantalla principal
      debugShowCheckedModeBanner: false, // Elimina el banner de depuración
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // Índice para el Bottom Navigation Bar

  final List<Widget> _screens = [
    RecuentoVotosScreen(), // Pantalla principal
    MesaListScreen(), // Segunda pantalla
  ];

  final List<String> _titles = [
    'Recuento de Votos', // Título para Recuento de Votos
    'Lista de Mesas', // Título para Lista de Mesas
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]), // Cambia el título según el índice
      ),
      drawer: _buildDrawer(context), // Crea el drawer
      body: _screens[_currentIndex], // Muestra la pantalla actual
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Cambia la pantalla según el índice
          });
        },
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

  // Método para construir el Drawer
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Encabezado del Drawer
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).primaryColor,
            child: Row(
              children: [
                Icon(Icons.menu, color: Colors.white, size: 40), // Icono de menú
                const SizedBox(width: 16), // Espacio entre icono y texto
                const Text(
                  'Menú Principal',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ), // Título del menú
              ],
            ),
          ),
          const SizedBox(height: 16.0), // Espacio debajo del encabezado
          Expanded(
            child: ListView(
              children: [
                // Botón para navegar a la pantalla Vocales
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => VocalesScreen()),
                    );
                  },
                  child: const Text('Ver Vocales'), // Texto del botón
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)), // Estilo del botón
                ),
                const SizedBox(height: 16.0), // Espacio entre botones
                
                // Botón para navegar a la pantalla Candidatos
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CandidatosScreen()),
                    );
                  },
                  child: const Text('Ver Candidatos'), // Texto del botón
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)), // Estilo del botón
                ),
                const SizedBox(height: 16.0), // Espacio entre botones
                
                // Botón para navegar a la pantalla Mesas
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MesasScreen()),
                    );
                  },
                  child: const Text('Ver Mesas'), // Texto del botón
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)), // Estilo del botón
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

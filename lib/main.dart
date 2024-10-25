import 'package:conteo_votaciones/screens/candidatos/candidatos.dart';
import 'package:conteo_votaciones/screens/conteo/recuentoVotos.dart';
import 'package:conteo_votaciones/screens/conteo/verConteoMesas.dart';
import 'package:conteo_votaciones/screens/log/log_inicial.dart';
import 'package:conteo_votaciones/screens/mesas/mesas.dart';
import 'package:conteo_votaciones/screens/usuarios/apoderados.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Asegura la inicialización de widgets
  await Firebase.initializeApp(); // Inicializa Firebase
  runApp(const MainApp()); // Inicia la aplicación
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Conteo Votaciones', // Título de la aplicación
      home: LoginScreen(), // Establece la pantalla principal
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

  // Método para construir el Drawer
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Encabezado del Drawer
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.black,
            child: Row(
              children: [
                Icon(Icons.menu,
                    color: Colors.white, size: 40), // Icono de menú
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
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => VocalesScreen()),
                    );
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.people_alt_sharp,
                            color: Colors.black), // Ícono al lado del texto
                        SizedBox(
                            width: 8.0), // Espacio entre el ícono y el texto
                        Text(
                          'Ver Apoderados',
                          style: TextStyle(color: Colors.black, fontSize: 16.0),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(
                  color: Colors.black87,
                  indent: 20,
                  thickness: 1.0,
                  height: 1.0,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CandidatosScreen()),
                    );
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.people_outline_outlined,
                            color: Colors.black), // Ícono al lado del texto
                        SizedBox(
                            width: 8.0), // Espacio entre el ícono y el texto
                        Text(
                          'Ver Candidatos',
                          style: TextStyle(color: Colors.black, fontSize: 16.0),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(
                  color: Colors.black87,
                  indent: 20,
                  thickness: 1.0,
                  height: 1.0,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MesasScreen()),
                    );
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                    // decoration: BoxDecoration(
                    // color: Colors.blue,
                    // borderRadius: BorderRadius.circular(8.0),
                    // ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.add_box_sharp,
                            color: Colors.black), // Ícono al lado del texto
                        SizedBox(
                            width: 8.0), // Espacio entre el ícono y el texto
                        Text(
                          'Ver Mesas',
                          style: TextStyle(color: Colors.black, fontSize: 16.0),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(
                  color: Colors.black87,
                  indent: 20,
                  thickness: 1.0,
                  height: 1.0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

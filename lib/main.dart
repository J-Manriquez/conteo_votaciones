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
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conteo Votaciones'), // Título en la barra de aplicaciones
      ),
      body: Center( // Centra el contenido verticalmente
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centra el contenido en la columna
          children: [
            ElevatedButton(
              onPressed: () {
                // Navega a la pantalla Vocales
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VocalesScreen()),
                );
              },
              child: const Text('ver Vocales'), // Texto del botón
            ),
            const SizedBox(height: 16.0), // Espacio entre botones
            // CandidatosScreen
            ElevatedButton(
              onPressed: () {
                // Navega a la pantalla Vocales
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CandidatosScreen()),
                );
              },
              child: const Text('ver candidatos'), // Texto del botón
            ),
            const SizedBox(height: 16.0), // Espacio entre botones
            ElevatedButton(
              onPressed: () {
                // Navega a la pantalla Vocales
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MesasScreen()),
                );
              },
              child: const Text('ver mesas'), // Texto del botón
            ),
            const SizedBox(height: 16.0), // Espacio entre botones
            ElevatedButton(
              onPressed: () {
                // Navega a la pantalla Vocales
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MesaListScreen()),
                );
              },
              child: const Text('conteo x mesas'), // Texto del botón
            ),
            const SizedBox(height: 16.0), // Espacio entre botones
            ElevatedButton(
              onPressed: () {
                // Navega a la pantalla Vocales
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RecuentoVotosScreen()),
                );
              },
              child: const Text('Recuento votos'), // Texto del botón
            ),
          ],
        ),
      ),
    );
  }
}

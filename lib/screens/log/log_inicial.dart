import 'package:conteo_votaciones/main.dart';
import 'package:conteo_votaciones/screens/log/log_secundario.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _passwordController =
      TextEditingController(); // Controlador para el TextField
  final String _IngresoAdmin = 'mejoryerno';
  final String _IngresoOtros = 'florida';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar:
      //     AppBar(title: const ), // Título de la AppBar
      body: Padding(
        padding:
            const EdgeInsets.all(16.0), // Espaciado alrededor del contenido
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Centra el contenido verticalmente
          children: [
            Text(
              'Ingresa la contraseña para entrar',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20), // Espacio entre el TextField y el botón
            Text(
              'Elecciones florida 2024, contraseña: florida',
              style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic),
            ),
            TextField(
              controller:
                  _passwordController, // Asocia el controlador al TextField
              obscureText: true, // Oculta el texto ingresado
              decoration: InputDecoration(
                labelText: 'Contraseña', // Etiqueta del TextField
                border: OutlineInputBorder(), // Borde del TextField
              ),
            ),
            const SizedBox(height: 20), // Espacio entre el TextField y el botón
            ElevatedButton(
              onPressed:
                  _checkPassword, // Llama a _checkPassword al presionar el botón
              child: const Text('Ingresar',
                  style: TextStyle(
                    color: Colors.black,
                  )), // Texto del botón
            ),
          ],
        ),
      ),
    );
  }

  void _checkPassword() {
    // Comprueba si la contraseña ingresada es correcta
    if (_passwordController.text == _IngresoAdmin) {
      Navigator.pushReplacement(
        // Navega a la HomeScreen y reemplaza la LoginScreen
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else if (_passwordController.text == _IngresoOtros) {
      Navigator.pushReplacement(
        // Navega a la HomeScreen y reemplaza la LoginScreen
        context,
        MaterialPageRoute(builder: (context) => MesaSelectionScreen()),
      );
    } else {
      // Muestra un mensaje de error si la contraseña es incorrecta
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Contraseña incorrecta')), // Mensaje de error
      );
    }
  }
}

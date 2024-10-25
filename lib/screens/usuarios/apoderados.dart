import 'package:flutter/material.dart';
import 'package:conteo_votaciones/screens/usuarios/agregarEditarApoderado.dart';
import 'package:conteo_votaciones/database/singleton_db.dart';

class VocalesScreen extends StatefulWidget {
  @override
  _VocalesScreenState createState() => _VocalesScreenState();
}

class _VocalesScreenState extends State<VocalesScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  // Función para eliminar un usuario
  Future<void> _deleteUser(String userId) async {
    await _firestoreService.deleteDocument('usuarios', userId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Apoderado eliminado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Apoderados'),
      ),
      body: Column(
        children: [
          // Botón para añadir usuario
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddUserScreen()),
                );
              },
              child: Text('Añadir Apoderado', style: TextStyle(color: Color.fromRGBO(5, 5, 5, 1,))),
            ),
          ),
          // Lista de usuarios en tarjetas
          Expanded(
            child: StreamBuilder(
              stream: _firestoreService.getDocuments('usuarios'), // Escucha los cambios en la colección
              builder: (context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final users = snapshot.data.docs;

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    var user = users[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: ListTile(
                        title: Text(user['nombre']),
                        subtitle: Text('Cargo: ${user['cargo'] ?? 'No asignado'}'), // Muestra el cargo, si no hay, muestra 'No asignado'
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Botón de editar
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                // Navegar a AddUserScreen para editar el usuario
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddUserScreen.edit(
                                      userId: user.id, // ID del usuario
                                      nombre: user['nombre'], // Nombre del usuario
                                      cargo: user['cargo'], // Cargo del usuario
                                    ),
                                  ),
                                );
                              },
                            ),
                            // Botón de eliminar
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _deleteUser(user.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

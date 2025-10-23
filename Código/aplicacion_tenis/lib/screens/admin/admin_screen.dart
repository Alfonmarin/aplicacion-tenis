import 'package:flutter/material.dart';
import '../tournaments/TournamentManagementScreen.dart';
import 'account_managementscreen.dart';

class AdminScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Colors.white), // Icono de flecha en blanco
          onPressed: () {
            Navigator.pop(context); // Acción para volver atrás
          },
        ),
        title: const Text(
          'Administración',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 117, 52, 221),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Imagen de fondo
          Positioned.fill(
            child: Image.asset(
              'assets/fondo_admin.jpg', // Reemplaza con la ruta real de tu imagen
              fit: BoxFit.cover,
            ),
          ),
          // Capa opaca blancuzca
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    // Navega a la pantalla de gestión de cuentas
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AccountManagementScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Gestión de Cuentas',
                    style: TextStyle(fontSize: 18), // Tamaño de texto aumentado
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 60, vertical: 25),
                    textStyle: TextStyle(fontSize: 20),
                  ),
                ),
                SizedBox(height: 40), // Espacio aumentado entre botones
                ElevatedButton(
                  onPressed: () {
                    // Navega a la pantalla de gestión de torneos
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TournamentManagementScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Gestión de Torneos',
                    style: TextStyle(fontSize: 18), // Tamaño de texto aumentado
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 60, vertical: 25),
                    textStyle: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

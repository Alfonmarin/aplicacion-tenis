import 'package:aplicacion_tenis/screens/tournaments/select_tournaments_screen.dart';
import 'package:flutter/material.dart';
import 'create_tournament_screen.dart';
import 'update_scores_screen.dart';

class TournamentManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 117, 52, 221),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Gestión de Torneos',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          // Imagen de fondo
          Positioned.fill(
            child: Image.asset(
              'assets/fondo_admin.jpg', // Ruta de tu imagen de fondo
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
                SizedBox(
                  width: 250, // Ancho fijo para uniformidad
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateTournamentScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Crear un torneo',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 250, // Ancho fijo para uniformidad
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SelectTournamentScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Emparejamiento de torneos',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 250, // Ancho fijo para uniformidad
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UpdateScoresScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Actualizar puntuaciones',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
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

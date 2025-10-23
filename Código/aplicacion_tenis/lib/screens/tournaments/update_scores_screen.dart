import 'package:aplicacion_tenis/screens/tournaments/TournamentManagementScreen.dart';
import 'package:flutter/material.dart';
import 'octavos_screen.dart'; // Importamos la pantalla de octavos

class UpdateScoresScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 117, 52, 221),
        elevation: 0, // Sin sombra
        centerTitle: true,
        title: const Text(
          'Actualizar puntuaciones',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TournamentManagementScreen(),
              ),
            );
          },
        ),
      ),
      body: Stack(
        children: [
          // Imagen de fondo
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/fondo_admin.jpg'), // Cambia por tu imagen
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Capa blanca semi-transparente
          Container(
            color: Colors.white.withOpacity(0.5),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _tournamentCard(
                  context,
                  'assets/otoño.jpg',
                  'Torneo de Otoño',
                ),
                const SizedBox(height: 20),
                _tournamentCard(
                  context,
                  'assets/primavera.jpg',
                  'Torneo de Primavera',
                ),
                const SizedBox(height: 20),
                _tournamentCard(
                  context,
                  'assets/verano.jpg',
                  'Torneo de Verano',
                ),
                const SizedBox(height: 20),
                _tournamentCard(
                  context,
                  'assets/invierno.jpg',
                  'Torneo de Invierno',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tournamentCard(
      BuildContext context, String imagePath, String torneo) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OctavosScreen(torneo: torneo),
          ),
        );
      },
      child: Container(
        width: 350,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.black.withOpacity(0.5),
          ),
          alignment: Alignment.center,
          child: Text(
            torneo,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PointsPlayerScreen extends StatelessWidget {
  final String playerId;

  PointsPlayerScreen({required this.playerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Puntuaciones del Jugador',
            style: TextStyle(color: Colors.black),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 200, 211, 229),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Container(
        color: const Color.fromARGB(255, 200, 211, 229),
        child: FutureBuilder(
          future: _fetchPlayerStats(playerId),
          builder: (context, AsyncSnapshot<Map<String, int>> statsSnapshot) {
            if (!statsSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final playerStats = statsSnapshot.data!;

            return FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('Usuarios creados')
                  .doc(playerId)
                  .get(),
              builder: (context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                if (!userSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final userData =
                    userSnapshot.data!.data() as Map<String, dynamic>;
                final username = userData['nombreUsuario'] ?? 'Desconocido';

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Nombre del jugador
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            username,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Mostrar puntos obtenidos
                      Column(
                        children: [
                          Text(
                            playerStats['PuntosObtenidos'].toString(),
                            style: const TextStyle(
                              fontSize: 72,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Puntos obtenidos',
                            style: TextStyle(fontSize: 22, color: Colors.grey),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Estadísticas adicionales
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Text(
                                playerStats['SetsGanados'].toString(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'Sets ganados',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                playerStats['JuegosGanados'].toString(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'Juegos ganados',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                playerStats['JuegosPerdidos'].toString(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'Juegos perdidos',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Botón para volver al ranking
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'RANKING GLOBAL',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<Map<String, int>> _fetchPlayerStats(String playerId) async {
    final torneoSnapshot =
        await FirebaseFirestore.instance.collection('Torneos').get();

    Map<String, int> playerStats = {
      'JuegosGanados': 0,
      'JuegosPerdidos': 0,
      'SetsGanados': 0,
      'PuntosObtenidos': 0, // Añadimos puntos obtenidos
    };

    for (var torneo in torneoSnapshot.docs) {
      final data = torneo.data();
      if (data.containsKey('Puntuaciones totales torneo jugadores')) {
        final stats = data['Puntuaciones totales torneo jugadores']
            as Map<String, dynamic>;
        if (stats.containsKey(playerId)) {
          final playerData = stats[playerId] as Map<String, dynamic>;
          playerStats['JuegosGanados'] = (playerStats['JuegosGanados'] ?? 0) +
              ((playerData['juegosGanados'] ?? 0) as int);
          playerStats['JuegosPerdidos'] = (playerStats['JuegosPerdidos'] ?? 0) +
              ((playerData['juegosPerdidos'] ?? 0) as int);
          playerStats['SetsGanados'] = (playerStats['SetsGanados'] ?? 0) +
              ((playerData['setsGanados'] ?? 0) as int);
          playerStats['PuntosObtenidos'] =
              (playerStats['PuntosObtenidos'] ?? 0) +
                  ((playerData['puntos'] ?? 0) as int); // Sumamos puntos
        }
      }
    }

    return playerStats;
  }
}

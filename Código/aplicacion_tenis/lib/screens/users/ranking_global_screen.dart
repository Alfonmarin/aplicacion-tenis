import 'package:aplicacion_tenis/screens/users/points_player.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RankingGlobalScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ranking Global',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 3, 54, 112),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Imagen de fondo y capa azul oscuro
          Positioned.fill(
            child: Image.asset('assets/gettyimages-600955998.jpg',
                fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(
                color: const Color.fromARGB(255, 3, 54, 112).withOpacity(0.9)),
          ),
          FutureBuilder(
            future: _fetchRankedPlayers(),
            builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final jugadores = snapshot.data!;

              return ListView.builder(
                itemCount: jugadores.length,
                itemBuilder: (context, index) {
                  final player = jugadores[index];

                  // Iconos especiales para los 3 primeros
                  Widget leadingIcon;
                  if (index == 0) {
                    leadingIcon = const Icon(Icons.emoji_events,
                        color: Colors.amber, size: 30);
                  } else if (index == 1) {
                    leadingIcon = const Icon(Icons.emoji_events,
                        color: Colors.grey, size: 30);
                  } else if (index == 2) {
                    leadingIcon = const Icon(Icons.emoji_events,
                        color: Colors.brown, size: 30);
                  } else {
                    leadingIcon = CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Text(
                        (index + 1).toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    );
                  }

                  return ListTile(
                    leading: GestureDetector(
                      onTap: () {
                        // Navegar a PointsPlayerScreen con el ID del jugador
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PointsPlayerScreen(playerId: player['id']),
                          ),
                        );
                      },
                      child: leadingIcon,
                    ),
                    title: Text(player['username'],
                        style: const TextStyle(color: Colors.white)),
                    trailing: Text("Puntos: ${player['puntos']}",
                        style: const TextStyle(color: Colors.white70)),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchRankedPlayers() async {
    final torneosSnapshot =
        await FirebaseFirestore.instance.collection('Torneos').get();
    final userSnapshot =
        await FirebaseFirestore.instance.collection('Usuarios creados').get();

    final playerStats = <String, Map<String, dynamic>>{};

    for (var torneoDoc in torneosSnapshot.docs) {
      final data = torneoDoc.data();

      if (data.containsKey('Puntuaciones totales torneo jugadores') &&
          data['Puntuaciones totales torneo jugadores'] is Map) {
        final jugadores = data['Puntuaciones totales torneo jugadores'] as Map;

        jugadores.forEach((playerId, stats) {
          if (stats != null && stats is Map<String, dynamic>) {
            playerStats.putIfAbsent(playerId, () => {
                  'puntos': 0,
                  'juegosGanados': 0,
                  'juegosPerdidos': 0,
                  'setsGanados': 0,
                });

            playerStats[playerId]!['puntos'] += stats['puntos'] ?? 0;
            playerStats[playerId]!['juegosGanados'] += stats['juegosGanados'] ?? 0;
            playerStats[playerId]!['juegosPerdidos'] += stats['juegosPerdidos'] ?? 0;
            playerStats[playerId]!['setsGanados'] += stats['setsGanados'] ?? 0;
          }
        });
      }
    }

    final playerList = userSnapshot.docs.map((userDoc) {
      final userId = userDoc.id;
      final username = userDoc.data()['nombreUsuario'] ?? 'Desconocido';
      final stats = playerStats[userId] ?? {
        'puntos': 0,
        'juegosGanados': 0,
        'juegosPerdidos': 0,
        'setsGanados': 0,
      };

      return {
        'id': userId,
        'username': username,
        'puntos': stats['puntos'],
        'stats': stats, // Estadísticas detalladas
      };
    }).toList();

    playerList.sort((a, b) => b['puntos'].compareTo(a['puntos']));
    return playerList;
  }
}

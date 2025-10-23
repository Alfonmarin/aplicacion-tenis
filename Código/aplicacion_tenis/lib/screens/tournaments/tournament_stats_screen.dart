import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TournamentStatsScreen extends StatelessWidget {
  final String tournamentName;

  const TournamentStatsScreen({Key? key, required this.tournamentName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 117, 52, 221),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white), // Flecha blanca
        title: Text(
          tournamentName,
          style: const TextStyle(color: Colors.white),
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
          FutureBuilder(
            future: _getTournamentDocumentId(tournamentName),
            builder: (context, AsyncSnapshot<String?> tournamentIdSnapshot) {
              if (!tournamentIdSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              if (tournamentIdSnapshot.data == null) {
                return const Center(
                  child: Text(
                    'No se encontró el torneo especificado.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                );
              }

              final String tournamentId = tournamentIdSnapshot.data!;

              return FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('Torneos')
                    .doc(tournamentId)
                    .get(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.data!.exists) {
                    return const Center(
                      child: Text(
                        'No se encontraron estadísticas para este torneo.',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    );
                  }

                  final tournamentData =
                      snapshot.data!.data() as Map<String, dynamic>;
                  final statsMap =
                      tournamentData['Puntuaciones totales torneo jugadores']
                          as Map<String, dynamic>;

                  if (!statsMap.containsKey(userId)) {
                    return const Center(
                      child: Text(
                        'No se encontraron estadísticas disponibles para este jugador.',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    );
                  }

                  final userStats = statsMap[userId] as Map<String, dynamic>;
                  final int puntos = userStats['puntos'] ?? 0;
                  final int juegosGanados = userStats['juegosGanados'] ?? 0;
                  final int juegosPerdidos = userStats['juegosPerdidos'] ?? 0;
                  final int setsGanados = userStats['setsGanados'] ?? 0;

                  final sortedPlayers = statsMap.entries.toList()
                    ..sort((a, b) => (b.value['puntos'] ?? 0)
                        .compareTo(a.value['puntos'] ?? 0));

                  final int posicion =
                      sortedPlayers.indexWhere((entry) => entry.key == userId) +
                          1;

                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStatRow('Posición:', posicion),
                        const SizedBox(height: 10),
                        _buildStatRow('Puntos:', puntos),
                        const SizedBox(height: 10),
                        _buildStatRow('Sets Ganados:', setsGanados),
                        const SizedBox(height: 10),
                        _buildStatRow('Juegos Ganados:', juegosGanados),
                        const SizedBox(height: 10),
                        _buildStatRow('Juegos Perdidos:', juegosPerdidos),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            value.toString(),
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

  Future<String?> _getTournamentDocumentId(String tournamentName) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Torneos')
        .where('Nombre', isEqualTo: tournamentName)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return null;
    }

    return querySnapshot.docs.first.id;
  }
}

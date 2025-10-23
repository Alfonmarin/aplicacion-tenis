import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:aplicacion_tenis/screens/tournaments/update_scores_screen.dart';
import 'dart:math';

class RankingScreen extends StatelessWidget {
  final String torneoId;

  RankingScreen({required this.torneoId});

  Future<List<Map<String, dynamic>>> _obtenerRanking() async {
    try {
      final torneoDoc = await FirebaseFirestore.instance
          .collection('Torneos')
          .doc(torneoId)
          .get();
      final data = torneoDoc.data();

      if (data == null) {
        return [];
      }

      // Obtener estadísticas de todas las fases
      final puntuacionesOctavos = data['Puntuaciones octavos'] ?? {};
      final puntuacionesCuartos = data['Puntuaciones cuartos'] ?? {};
      final puntuacionesSemis = data['Puntuaciones semis'] ?? {};
      final puntuacionesFinal = data['Puntuaciones final'] ?? {};

      // Inicializar mapa total
      final totales = <String, Map<String, int>>{};

      void acumularPuntuaciones(Map<String, dynamic> fase) {
        fase.forEach((jugadorId, stats) {
          if (!totales.containsKey(jugadorId)) {
            totales[jugadorId] = {
              'setsGanados': 0,
              'juegosGanados': 0,
              'juegosPerdidos': 0,
            };
          }
          totales[jugadorId]!['setsGanados'] =
              (totales[jugadorId]!['setsGanados'] ?? 0) +
                  ((stats['setsGanados'] ?? 0) as int);
          totales[jugadorId]!['juegosGanados'] =
              (totales[jugadorId]!['juegosGanados'] ?? 0) +
                  ((stats['juegosGanados'] ?? 0) as int);
          totales[jugadorId]!['juegosPerdidos'] =
              (totales[jugadorId]!['juegosPerdidos'] ?? 0) +
                  ((stats['juegosPerdidos'] ?? 0) as int);
        });
      }

      // Acumular puntuaciones de todas las fases
      acumularPuntuaciones(puntuacionesOctavos);
      acumularPuntuaciones(puntuacionesCuartos);
      acumularPuntuaciones(puntuacionesSemis);
      acumularPuntuaciones(puntuacionesFinal);

      // Actualizar estadísticas totales en Firebase
      await FirebaseFirestore.instance
          .collection('Torneos')
          .doc(torneoId)
          .update({'Puntuaciones totales torneo jugadores': totales});

      // Crear lista de jugadores y ordenar
      final jugadores = totales.keys.toList();
      jugadores.sort((a, b) {
        final statsA = totales[a]!;
        final statsB = totales[b]!;

        int compareSets =
            (statsB['setsGanados'] ?? 0).compareTo(statsA['setsGanados'] ?? 0);
        if (compareSets != 0) return compareSets;

        int compareGames = (statsB['juegosGanados'] ?? 0)
            .compareTo(statsA['juegosGanados'] ?? 0);
        if (compareGames != 0) return compareGames;

        int compareLostGames = (statsA['juegosPerdidos'] ?? 0)
            .compareTo(statsB['juegosPerdidos'] ?? 0);
        if (compareLostGames != 0) return compareLostGames;

        return Random().nextInt(2) == 0 ? -1 : 1;
      });

      // Generar puntos
      final puntos = [
        2000,
        1500,
        1000,
        500,
        475,
        450,
        425,
        400,
        375,
        350,
        325,
        300,
        275,
        250,
        225,
        200
      ];

      final ranking = <Map<String, dynamic>>[];
      for (int i = 0; i < jugadores.length; i++) {
        final jugadorId = jugadores[i];
        ranking.add({
          'jugadorId': jugadorId,
          'setsGanados': totales[jugadorId]!['setsGanados'] ?? 0,
          'juegosGanados': totales[jugadorId]!['juegosGanados'] ?? 0,
          'juegosPerdidos': totales[jugadorId]!['juegosPerdidos'] ?? 0,
          'puntos': i < puntos.length ? puntos[i] : 0,
        });

        // Actualizar puntos en Firebase
        totales[jugadorId]!['puntos'] = i < puntos.length ? puntos[i] : 0;
      }

      // Guardar los puntos en Firebase
      await FirebaseFirestore.instance
          .collection('Torneos')
          .doc(torneoId)
          .update({'Puntuaciones totales torneo jugadores': totales});

      return ranking;
    } catch (e) {
      print('Error al obtener el ranking: $e');
      return [];
    }
  }

  Future<Map<String, String>> _obtenerNombresJugadores(
      List<Map<String, dynamic>> ranking) async {
    try {
      final ids = ranking.map((item) => item['jugadorId']).toList();
      final nombres = <String, String>{};

      final usuariosSnapshot =
          await FirebaseFirestore.instance.collection('Usuarios creados').get();

      for (var doc in usuariosSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('nombreUsuario')) {
          nombres[doc.id] = data['nombreUsuario'];
        }
      }

      for (var id in ids) {
        if (!nombres.containsKey(id)) {
          nombres[id] = 'Jugador desconocido';
        }
      }

      return nombres;
    } catch (e) {
      print('Error al obtener nombres de jugadores: $e');
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UpdateScoresScreen()),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 117, 52, 221),
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white), // Flecha blanca
          title: const Text(
            'Ranking del Torneo',
            style: TextStyle(color: Colors.white),
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
              color: Colors.white.withOpacity(0.8),
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _obtenerRanking(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final ranking = snapshot.data!;
                if (ranking.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay datos de ranking disponibles.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }

                return FutureBuilder<Map<String, String>>(
                  future: _obtenerNombresJugadores(ranking),
                  builder: (context, nombresSnapshot) {
                    if (!nombresSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final nombres = nombresSnapshot.data!;
                    return ListView.builder(
                      itemCount: ranking.length,
                      itemBuilder: (context, index) {
                        final item = ranking[index];
                        final jugadorId = item['jugadorId'];
                        final nombreJugador =
                            nombres[jugadorId] ?? 'Jugador desconocido';

                        return ListTile(
                          leading: Text(
                            '#${index + 1}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          title: Text(
                            nombreJugador,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            'Puntos: ${item['puntos']}, '
                            'Sets Ganados: ${item['setsGanados']}, '
                            'Juegos Ganados: ${item['juegosGanados']} (+), '
                            'Juegos Perdidos: ${item['juegosPerdidos']} (-)',
                            style: const TextStyle(fontSize: 16),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

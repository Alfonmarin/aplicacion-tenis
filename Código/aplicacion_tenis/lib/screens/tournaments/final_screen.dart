import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:aplicacion_tenis/screens/tournaments/ranking_screen.dart';

class FinalScreen extends StatefulWidget {
  final String torneo;

  FinalScreen({required this.torneo});

  @override
  _FinalScreenState createState() => _FinalScreenState();
}

class _FinalScreenState extends State<FinalScreen> {
  final Map<String, List<TextEditingController>> _controllers = {};

  @override
  void dispose() {
    for (var controllerList in _controllers.values) {
      for (var controller in controllerList) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  bool _todosLosCamposLlenos() {
    for (var controllerList in _controllers.values) {
      for (var controller in controllerList) {
        if (controller.text.isEmpty) {
          return false;
        }
      }
    }
    return true;
  }

  Future<void> _guardarResultadosFinal(BuildContext context, String torneoId,
      List<dynamic> emparejamientos) async {
    final ganadores = <String>[];
    final puntuacionesFinal = <String, Map<String, int>>{};

    for (var emparejamiento in emparejamientos) {
      final jugador1Id = emparejamiento['idjugador1'];
      final jugador2Id = emparejamiento['idjugador2'];

      final jugador1Scores = _controllers[jugador1Id]!
          .map((c) => int.tryParse(c.text) ?? 0)
          .toList();
      final jugador2Scores = _controllers[jugador2Id]!
          .map((c) => int.tryParse(c.text) ?? 0)
          .toList();

      int setsGanadosJugador1 = 0;
      int setsGanadosJugador2 = 0;
      int juegosGanadosJugador1 = 0;
      int juegosGanadosJugador2 = 0;

      for (int i = 0; i < 5; i++) {
        if (jugador1Scores[i] > jugador2Scores[i]) {
          setsGanadosJugador1++;
          juegosGanadosJugador1 += jugador1Scores[i];
          juegosGanadosJugador2 += jugador2Scores[i];
        } else if (jugador2Scores[i] > jugador1Scores[i]) {
          setsGanadosJugador2++;
          juegosGanadosJugador1 += jugador1Scores[i];
          juegosGanadosJugador2 += jugador2Scores[i];
        }
      }

      final ganador =
          setsGanadosJugador1 > setsGanadosJugador2 ? jugador1Id : jugador2Id;
      ganadores.add(ganador);

      puntuacionesFinal[jugador1Id] = {
        'setsGanados': setsGanadosJugador1,
        'juegosGanados': juegosGanadosJugador1,
        'juegosPerdidos': juegosGanadosJugador2,
      };

      puntuacionesFinal[jugador2Id] = {
        'setsGanados': setsGanadosJugador2,
        'juegosGanados': juegosGanadosJugador2,
        'juegosPerdidos': juegosGanadosJugador1,
      };
    }

    final torneoDoc = await FirebaseFirestore.instance
        .collection('Torneos')
        .doc(torneoId)
        .get();
    final data = torneoDoc.data();
    final totales = data?['Puntuaciones totales torneo jugadores'] ?? {};

    puntuacionesFinal.forEach((jugadorId, stats) {
      if (!totales.containsKey(jugadorId)) {
        totales[jugadorId] = {
          'setsGanados': 0,
          'juegosGanados': 0,
          'juegosPerdidos': 0,
        };
      }
      totales[jugadorId]['setsGanados'] += stats['setsGanados'];
      totales[jugadorId]['juegosGanados'] += stats['juegosGanados'];
      totales[jugadorId]['juegosPerdidos'] += stats['juegosPerdidos'];
    });

    await FirebaseFirestore.instance
        .collection('Torneos')
        .doc(torneoId)
        .update({
      'Puntuaciones final': puntuacionesFinal,
      'Puntuaciones totales torneo jugadores': totales,
      'Ganador': ganadores.isNotEmpty ? ganadores.first : '',
      'Estado': 'Jugado y finalizado',
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => RankingScreen(torneoId: torneoId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 117, 52, 221),
        elevation: 0, // Sin sombra
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white), // Flecha blanca
        title: Text(
          '${widget.torneo} - Final',
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
            future: FirebaseFirestore.instance
                .collection('Torneos')
                .where('Nombre', isEqualTo: widget.torneo)
                .get(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final torneoData = snapshot.data!.docs.first;
              final torneoId = torneoData.id;
              final emparejamientos =
                  torneoData['Emparejamientos final'] as List<dynamic>;

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: emparejamientos.length,
                      itemBuilder: (context, index) {
                        final emparejamiento =
                            emparejamientos[index] as Map<String, dynamic>;
                        final jugador1Id = emparejamiento['idjugador1'];
                        final jugador2Id = emparejamiento['idjugador2'];

                        return FutureBuilder(
                          future: FirebaseFirestore.instance
                              .collection('Usuarios creados')
                              .get(),
                          builder: (context,
                              AsyncSnapshot<QuerySnapshot> userSnapshot) {
                            if (!userSnapshot.hasData) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            final jugadoresMap = {
                              for (var doc in userSnapshot.data!.docs)
                                doc.id: (doc.data()
                                    as Map<String, dynamic>)['nombreUsuario']
                            };

                            final jugador1 =
                                jugadoresMap[jugador1Id] ?? 'Jugador 1';
                            final jugador2 =
                                jugadoresMap[jugador2Id] ?? 'Jugador 2';

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Column(
                                children: [
                                  _playerRow(jugador1, jugador1Id),
                                  _playerRow(jugador2, jugador2Id),
                                  const Divider(),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_todosLosCamposLlenos()) {
                            await _guardarResultadosFinal(
                                context, torneoId, emparejamientos);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Por favor, completa todos los campos antes de continuar.')),
                            );
                          }
                        },
                        child: const Text(
                          'Guardar Resultados y Mostrar Ranking',
                          style: TextStyle(fontSize: 18),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: const Color(0xFF6B42A8),
                          fixedSize: const Size(450, 70),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _playerRow(String playerName, String playerId) {
    if (!_controllers.containsKey(playerId)) {
      _controllers[playerId] =
          List.generate(6, (index) => TextEditingController());
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                playerName,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        Flexible(
          flex: 6,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
                6, (index) => _scoreInputField(_controllers[playerId]![index])),
          ),
        ),
      ],
    );
  }

  Widget _scoreInputField(TextEditingController controller) {
    return SizedBox(
      width: 40,
      child: TextFormField(
        controller: controller,
        textAlign: TextAlign.center,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}

import 'package:aplicacion_tenis/screens/tournaments/cuartos_screen.dart';
import 'package:aplicacion_tenis/screens/tournaments/update_scores_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OctavosScreen extends StatefulWidget {
  final String torneo;

  OctavosScreen({required this.torneo});

  @override
  _OctavosScreenState createState() => _OctavosScreenState();
}

class _OctavosScreenState extends State<OctavosScreen> {
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
          return false; // Si algún campo está vacío, retorna falso
        }
      }
    }
    return true; // Todos los campos están llenos
  }

  Future<bool> _onWillPop() async {
    // Mostrar alerta de confirmación al intentar volver atrás
    final shouldLeave = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmación'),
        content: Text(
            '¿Estás seguro de volver hacia atrás? Se perderán los resultados actualizados.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Cancelar
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Confirmar
            child: Text('Sí'),
          ),
        ],
      ),
    );

    if (shouldLeave ?? false) {
      _borrarResultados();
      // Redirigir a la pantalla de Actualizar Puntuaciones
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => UpdateScoresScreen(),
        ),
      );
      return false; // Evitar comportamiento por defecto de retroceder
    }
    return false; // Cancelar la acción de retroceder
  }

  void _borrarResultados() {
    for (var controllerList in _controllers.values) {
      for (var controller in controllerList) {
        controller.clear(); // Borrar contenido de los controladores
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Se han borrado los resultados introducidos.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 117, 52, 221),
          elevation: 0, // Sin sombra
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white), // Iconos blancos
          title: Text(
            '${widget.torneo} - Octavos',
            style: const TextStyle(color: Colors.white), // Texto blanco
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
                    torneoData['emparejamientos'] as List<dynamic>;

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
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
                                  return const SizedBox(
                                    height: 100,
                                    child: Center(
                                        child: CircularProgressIndicator()),
                                  );
                                }

                                final jugadoresMap = {
                                  for (var doc in userSnapshot.data!.docs)
                                    doc.id: (doc.data() as Map<String,
                                        dynamic>)['nombreUsuario']
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
                      ElevatedButton(
                        onPressed: () async {
                          if (_todosLosCamposLlenos()) {
                            await _guardarResultadosOctavos(
                                context, torneoId, emparejamientos);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CuartosScreen(torneo: widget.torneo),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Por favor, completa todos los campos antes de continuar.')),
                            );
                          }
                        },
                        child: Text('Pasar a Cuartos'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          textStyle: TextStyle(fontSize: 18),
                          foregroundColor: const Color(0xFF6B42A8),
                          fixedSize: const Size(250, 60),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
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
          child: Text(
            playerName,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  Future<void> _guardarResultadosOctavos(BuildContext context, String torneoId,
      List<dynamic> emparejamientos) async {
    final ganadores = <String>[];
    final puntuacionesOctavos = <String, Map<String, int>>{};

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

      puntuacionesOctavos[jugador1Id] = {
        'setsGanados': setsGanadosJugador1,
        'juegosGanados': juegosGanadosJugador1,
        'juegosPerdidos': juegosGanadosJugador2,
      };

      puntuacionesOctavos[jugador2Id] = {
        'setsGanados': setsGanadosJugador2,
        'juegosGanados': juegosGanadosJugador2,
        'juegosPerdidos': juegosGanadosJugador1,
      };
    }

    await FirebaseFirestore.instance
        .collection('Torneos')
        .doc(torneoId)
        .update({
      'Puntuaciones octavos': puntuacionesOctavos,
      'Ganadores octavos': ganadores,
      'Emparejamientos cuartos': _generarEmparejamientos(ganadores),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Resultados guardados y emparejamientos creados.')),
    );
  }

  List<Map<String, String>> _generarEmparejamientos(List<String> ganadores) {
    ganadores.shuffle();
    final emparejamientos = <Map<String, String>>[];

    for (int i = 0; i < ganadores.length; i += 2) {
      if (i + 1 < ganadores.length) {
        emparejamientos.add({
          'idjugador1': ganadores[i],
          'idjugador2': ganadores[i + 1],
        });
      }
    }
    return emparejamientos;
  }
}

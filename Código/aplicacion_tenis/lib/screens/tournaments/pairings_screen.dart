import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math'; // Para mezclar aleatoriamente
import 'player_selection_screen.dart';

class PairingsScreen extends StatelessWidget {
  final Map<String, dynamic> torneo;

  PairingsScreen({required this.torneo});

  // Función para generar emparejamientos aleatorios
  List<Map<String, String>> generarEmparejamientos(List<String> jugadores) {
    jugadores.shuffle(Random());
    List<Map<String, String>> emparejamientos = [];

    for (int i = 0; i < jugadores.length; i += 2) {
      if (i + 1 < jugadores.length) {
        emparejamientos.add({
          'idjugador1': jugadores[i],
          'idjugador2': jugadores[i + 1],
        });
      } else {
        emparejamientos.add({
          'idjugador1': jugadores[i],
          'idjugador2': 'BYE',
        });
      }
    }
    return emparejamientos;
  }

  Future<void> guardarEmparejamientosYActualizarEstado(
      String torneoId, List<Map<String, String>> emparejamientos) async {
    final torneoRef =
        FirebaseFirestore.instance.collection('Torneos').doc(torneoId);

    try {
      await torneoRef.update({
        'emparejamientos': FieldValue.arrayUnion(emparejamientos),
        'Inscritos': FieldValue.delete(),
        'Estado': 'Por jugar',
      });
    } catch (e) {
      print('Error al actualizar el torneo: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final seleccionados = List<String>.from(torneo['Seleccionados'] ?? []);
    final torneoId = torneo['id'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 117, 52, 221),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Emparejamientos - ${torneo['Nombre']}',
          style: const TextStyle(color: Colors.white),
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
              'assets/fondo_admin.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Capa opaca
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          // Contenido principal
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Botón Realizar emparejamientos
                ElevatedButton(
                  onPressed: () async {
                    if (seleccionados.isEmpty) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Error'),
                          content: const Text(
                              'No hay jugadores seleccionados en este torneo.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cerrar'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      try {
                        List<Map<String, String>> emparejamientos =
                            generarEmparejamientos(seleccionados);

                        await guardarEmparejamientosYActualizarEstado(
                            torneoId, emparejamientos);

                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Emparejamientos guardados'),
                            content: const Text(
                                'Los emparejamientos se han guardado correctamente.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cerrar'),
                              ),
                            ],
                          ),
                        );
                      } catch (e) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Error'),
                            content: const Text(
                                'No se pudieron guardar los emparejamientos.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cerrar'),
                              ),
                            ],
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200], // Fondo gris claro
                    minimumSize: const Size(250, 60), // Tamaño uniforme
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0, // Sin sombra
                  ),
                  child: const Text(
                    'Realizar emparejamientos',
                    style: TextStyle(
                      color: Color(0xFF6B42A8), // Texto púrpura
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Botón Seleccionar Jugadores
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PlayerSelectionScreen(torneo: torneo),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    minimumSize: const Size(250, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Seleccionar Jugadores',
                    style: TextStyle(
                      color: Color(0xFF6B42A8),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
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

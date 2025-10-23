import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pairings_screen.dart'; // Importa la pantalla de emparejamientos

class SelectTournamentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 117, 52, 221),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Seleccionar Torneo',
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
          StreamBuilder(
            stream:
                FirebaseFirestore.instance.collection('Torneos').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No hay torneos disponibles'));
              }

              final torneos = snapshot.data!.docs;

              return ListView.builder(
                itemCount: torneos.length,
                itemBuilder: (context, index) {
                  final torneoDoc = torneos[index]; // Documento Firestore
                  final torneo = torneoDoc.data(); // Datos del torneo
                  final id = torneoDoc.id; // ID del documento
                  final nombre = torneo['Nombre'] ?? 'Torneo sin nombre';
                  final estado = torneo['Estado'] ?? 'Sin estado';
                  final fechaInicio =
                      torneo['Fecha_ini'] ?? 'Fecha no disponible';
                  final fechaFin = torneo['Fecha_fin'] ?? 'Fecha no disponible';

                  // Determinar la imagen del torneo
                  String imageAsset;
                  switch (nombre) {
                    case 'Torneo de Verano':
                      imageAsset = 'assets/verano.jpg';
                      break;
                    case 'Torneo de Invierno':
                      imageAsset = 'assets/invierno.jpg';
                      break;
                    case 'Torneo de Primavera':
                      imageAsset = 'assets/primavera.jpg';
                      break;
                    case 'Torneo de Otoño':
                      imageAsset = 'assets/otoño.jpg';
                      break;
                    default:
                      imageAsset = 'assets/default_tournament.jpg';
                  }

                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: InkWell(
                      onTap: () {
                        // Navegar a la pantalla de emparejamientos
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PairingsScreen(
                              torneo: {
                                ...torneo,
                                'id': id,
                              },
                            ),
                          ),
                        );
                      },
                      child: SizedBox(
                        height: 150,
                        child: Stack(
                          children: [
                            // Imagen del torneo
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  imageAsset,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            // Información superpuesta
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      nombre,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Estado: $estado',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      'Inicio: $fechaInicio - Fin: $fechaFin',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
}

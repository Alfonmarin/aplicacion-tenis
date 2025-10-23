import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aplicacion_tenis/screens/tournaments/tournament_stats_screen.dart';

class UserTournamentsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Mis Torneos',
            style: TextStyle(color: Colors.black),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 200, 211, 229),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Container(
        color: const Color.fromARGB(255, 200, 211, 229),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('Torneos').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final tournaments = snapshot.data!.docs;
            final List<Widget> enrolledTournaments = [];
            final List<Widget> upcomingTournaments = [];
            final List<Widget> playedTournaments = [];

            for (var tournament in tournaments) {
              final String name = tournament['Nombre'];
              final String endDateStr = tournament['Fecha_fin'];
              final String status = tournament['Estado'];
              final data = tournament.data() as Map<String, dynamic>;

              bool isRegistered = data.containsKey('Inscritos') &&
                  data['Inscritos'].contains(userId);

              String imageAsset;
              switch (name) {
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

              if (status == "Jugado y finalizado") {
                playedTournaments.add(_buildTournamentTile(
                  context,
                  name,
                  endDateStr,
                  imageAsset: imageAsset,
                  showStatsButton: true,
                ));
              } else if (status == "Por jugar") {
                upcomingTournaments.add(_buildTournamentTile(
                  context,
                  name,
                  endDateStr,
                  imageAsset: imageAsset,
                ));
              } else if (isRegistered) {
                enrolledTournaments.add(_buildTournamentTile(
                  context,
                  name,
                  endDateStr,
                  imageAsset: imageAsset,
                ));
              }
            }

            return ListView(
              children: [
                _buildSectionTitle('Inscrito'),
                ...enrolledTournaments,
                _buildSectionTitle('Por Jugar'),
                ...upcomingTournaments,
                _buildSectionTitle('Jugado'),
                ...playedTournaments,
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTournamentTile(BuildContext context, String name, String endDateStr,
      {String? imageAsset, bool showStatsButton = false}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          if (imageAsset != null)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.asset(
                imageAsset,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ListTile(
            title: Text(name),
            subtitle: Text("Fecha fin de inscripción: $endDateStr"),
          ),
          if (showStatsButton)
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TournamentStatsScreen(
                      tournamentName: name,
                    ),
                  ),
                );
              },
              child: const Text(
                "Ver Estadísticas",
                style: TextStyle(fontSize: 16, color: Colors.blue),
              ),
            ),
        ],
      ),
    );
  }
}

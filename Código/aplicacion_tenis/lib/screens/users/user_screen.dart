import 'package:aplicacion_tenis/screens/tournaments/user_tournament_screen.dart';
import 'package:aplicacion_tenis/screens/users/ranking_global_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_screen.dart';

class UserScreen extends StatefulWidget {
  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  void _onRegistered() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Usuario',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 3, 54, 112),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon:
                const Icon(Icons.account_circle, size: 30, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/gettyimages-600955998.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: const Color.fromARGB(255, 3, 54, 112).withOpacity(0.9),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 40.0),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.teal,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.sports_tennis,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              TournamentsScreen(onRegistered: _onRegistered)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 30,
                    ),
                    minimumSize: const Size(200, 70),
                  ),
                  child: const Text(
                    'Torneos',
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UsersScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 30,
                    ),
                    minimumSize: const Size(200, 70),
                  ),
                  child: const Text(
                    'Estadísticas',
                    style: TextStyle(color: Colors.black, fontSize: 18),
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

class TournamentsScreen extends StatefulWidget {
  final Function onRegistered;

  TournamentsScreen({required this.onRegistered});

  @override
  _TournamentsScreenState createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends State<TournamentsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Torneos',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 3, 54, 112),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Torneos').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final tournaments = snapshot.data!.docs;

          return ListView.builder(
            itemCount: tournaments.length,
            itemBuilder: (context, index) {
              final tournament = tournaments[index];
              final String name = tournament['Nombre'];
              final String endDateStr = tournament['Fecha_fin'];
              final DateTime endDate = _parseDate(endDateStr);
              final bool canRegister = DateTime.now().isBefore(endDate);

              String userId = FirebaseAuth.instance.currentUser!.uid;
              final data = tournament.data() as Map<String, dynamic>? ?? {};
              bool isRegistered = data.containsKey('Inscritos')
                  ? data['Inscritos'].contains(userId)
                  : false;

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

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SizedBox(
                  height: 200,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            imageAsset,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
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
                                name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Fecha fin de inscripción: $endDateStr",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isRegistered)
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      ),
                                    ElevatedButton(
                                      onPressed: canRegister && !isRegistered
                                          ? () {
                                              _registerForTournament(
                                                  tournament.id, name);
                                            }
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                      ),
                                      child: Text(
                                        isRegistered
                                            ? 'Inscrito'
                                            : 'Inscribirse',
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  DateTime _parseDate(String dateStr) {
    final parts = dateStr.split('/');
    return DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );
  }

  void _registerForTournament(String tournamentId, String tournamentName) {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    FirebaseFirestore.instance
        .collection('Torneos')
        .where('Inscritos', arrayContains: userId)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Ya estás inscrito en otro torneo")),
        );
        return;
      }

      FirebaseFirestore.instance
          .collection('Torneos')
          .doc(tournamentId)
          .update({
        'Inscritos': FieldValue.arrayUnion([userId]),
        'Estadisticas Jugadores.$userId': {
          'PuntosObtenidos': 0,
          'SetsGanados': 0,
          'JuegosGanados': 0,
          'JuegosPerdidos': 0,
        },
      }).then((_) {
        widget.onRegistered();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Te has inscrito correctamente al Torneo: $tournamentName")),
        );
        Navigator.pop(context);
      }).catchError((error) => print("Error al inscribirse: $error"));
    }).catchError((error) =>
            print("Error al verificar inscripción en otros torneos: $error"));
  }
}

class UsersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // Centra el título
        title: const Text(
          'Estadísticas',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 3, 54, 112),
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
              'assets/gettyimages-600955998.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Capa azul oscuro
          Positioned.fill(
            child: Container(
              color: const Color.fromARGB(255, 3, 54, 112).withOpacity(0.9),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserTournamentsScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 20),
                    minimumSize: const Size(250, 60),
                  ),
                  child: const Text(
                    'Actividad Torneos',
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ),
                const SizedBox(height: 20),
                // Botón para navegar al ranking global
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RankingGlobalScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 20),
                    minimumSize: const Size(250, 60),
                  ),
                  child: const Text(
                    'Ranking Global',
                    style: TextStyle(color: Colors.black, fontSize: 18),
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

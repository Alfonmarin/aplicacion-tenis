import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlayerSelectionScreen extends StatefulWidget {
  final Map<String, dynamic> torneo;

  PlayerSelectionScreen({required this.torneo});

  @override
  _PlayerSelectionScreenState createState() => _PlayerSelectionScreenState();
}

class _PlayerSelectionScreenState extends State<PlayerSelectionScreen> {
  List<String> inscritos = [];
  List<String> seleccionados = [];
  Map<String, String> jugadoresInfo = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchInscritos();
  }

  Future<void> fetchInscritos() async {
    try {
      DocumentSnapshot torneoSnapshot = await FirebaseFirestore.instance
          .collection('Torneos')
          .doc(widget.torneo['id'])
          .get();

      if (torneoSnapshot.exists) {
        final data = torneoSnapshot.data() as Map<String, dynamic>;
        final List<String> inscritosIds =
            List<String>.from(data['Inscritos'] ?? []);

        for (String jugadorId in inscritosIds) {
          DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
              .collection('Usuarios creados')
              .doc(jugadorId)
              .get();

          if (userSnapshot.exists) {
            final userData = userSnapshot.data() as Map<String, dynamic>;
            jugadoresInfo[jugadorId] =
                userData['nombreUsuario'] ?? 'Desconocido';
          }
        }

        setState(() {
          inscritos = inscritosIds;
          seleccionados = List<String>.from(data['Seleccionados'] ?? []);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching inscritos: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> saveSeleccionados() async {
    if (seleccionados.length == 16) {
      try {
        await FirebaseFirestore.instance
            .collection('Torneos')
            .doc(widget.torneo['id'])
            .update({'Seleccionados': seleccionados});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Seleccionados guardados exitosamente')),
        );
      } catch (e) {
        print('Error guardando seleccionados: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hubo un error al guardar los seleccionados')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Debes seleccionar exactamente 16 jugadores')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 117, 52, 221),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Seleccionar Jugadores - ${widget.torneo['Nombre']}',
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
          // Capa opaca blancuzca
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: inscritos.length,
                  itemBuilder: (context, index) {
                    final jugadorId = inscritos[index];
                    final isSelected = seleccionados.contains(jugadorId);
                    final nombreUsuario =
                        jugadoresInfo[jugadorId] ?? 'Jugador $jugadorId';

                    return ListTile(
                      title: Text(
                        nombreUsuario,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          isSelected
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: isSelected ? Colors.green : null,
                        ),
                        onPressed: () {
                          setState(() {
                            if (isSelected) {
                              seleccionados.remove(jugadorId);
                            } else if (seleccionados.length < 16) {
                              seleccionados.add(jugadorId);
                            }
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: saveSeleccionados,
                  child: const Text(
                    'Guardar Seleccionados',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color.fromARGB(255, 117, 52, 221), // Texto morado
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300], // Fondo gris claro
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(25), // Bordes redondeados
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

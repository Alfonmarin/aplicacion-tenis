import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateTournamentScreen extends StatefulWidget {
  @override
  _CreateTournamentScreenState createState() => _CreateTournamentScreenState();
}

class _CreateTournamentScreenState extends State<CreateTournamentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

  bool _isFormValid() {
    return _nameController.text.isNotEmpty &&
        _startDateController.text.isNotEmpty &&
        _endDateController.text.isNotEmpty;
  }

  Future<void> _selectDate(BuildContext context,
      TextEditingController controller, bool isStartDate) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    setState(() {
      if (picked != null) {
        controller.text = "${picked.day}/${picked.month}/${picked.year}";
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      }
    });
  }

  Future<void> _registerTournament() async {
    if (_formKey.currentState!.validate()) {
      final tournamentData = {
        "Nombre": _nameController.text,
        "Fecha_ini": _startDateController.text,
        "Fecha_fin": _endDateController.text,
        "Estado": "Recién creado",
      };
      await FirebaseFirestore.instance
          .collection("Torneos")
          .add(tournamentData);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 117, 52, 221),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Crear Torneo',
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              onChanged: () {
                setState(() {});
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre del torneo',
                      filled: true,
                      fillColor: Colors.grey[300],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingrese el nombre del torneo';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _startDateController,
                    readOnly: true,
                    onTap: () =>
                        _selectDate(context, _startDateController, true),
                    decoration: InputDecoration(
                      labelText: 'Fecha de inicio',
                      filled: true,
                      fillColor: Colors.grey[300],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingrese la fecha de inicio';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _endDateController,
                    readOnly: true,
                    onTap: () =>
                        _selectDate(context, _endDateController, false),
                    decoration: InputDecoration(
                      labelText: 'Fecha de fin',
                      filled: true,
                      fillColor: Colors.grey[300],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingrese la fecha de fin';
                      }
                      if (_startDate != null && _endDate != null) {
                        if (_endDate!.isAtSameMomentAs(_startDate!)) {
                          return 'La fecha de fin no puede ser la misma que la fecha de inicio';
                        }
                        if (_endDate!.isBefore(_startDate!)) {
                          return 'La fecha de fin debe ser posterior a la fecha de inicio';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _isFormValid() ? _registerTournament : null,
                    child: const Text('Registrar'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 60, vertical: 20),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

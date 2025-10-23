import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String nombre;
  final String apellidos;
  final String telefono;
  final String email;
  final String nombreUsuario;

  const EmailVerificationScreen({
    Key? key,
    required this.nombre,
    required this.apellidos,
    required this.telefono,
    required this.email,
    required this.nombreUsuario,
  }) : super(key: key);

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Método para guardar el usuario en Firestore
  Future<void> _saveUserData(User user) async {
    await _firestore.collection('Usuarios creados').doc(user.uid).set({
      'nombre': widget.nombre,
      'apellidos': widget.apellidos,
      'telefono': widget.telefono,
      'email': widget.email,
      'nombreUsuario': widget.nombreUsuario,
    });
  }

  // Método para verificar el correo
  Future<void> _checkEmailVerification() async {
    User? user = _auth.currentUser;
    await user?.reload();
    if (user != null && user.emailVerified) {
      await _saveUserData(user);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario registrado exitosamente.')),
      );
      Navigator.of(context)
          .popUntil((route) => route.isFirst); // Vuelve al inicio
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El correo electrónico no ha sido verificado aún.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificación de correo'),
        automaticallyImplyLeading: false, // Oculta el botón de retroceso
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Se ha enviado un correo de verificación. Verifícalo y presiona el botón de abajo para continuar.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkEmailVerification,
              child: const Text('Verificar email y completar registro'),
            ),
          ],
        ),
      ),
    );
  }
}

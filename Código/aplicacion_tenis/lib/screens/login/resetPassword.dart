import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResetPasswordRequestScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();

  Future<void> _sendPasswordResetEmail(BuildContext context) async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, ingrese un correo electrónico.')),
      );
      return;
    }

    try {
      // Enviar correo de restablecimiento de contraseña
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Correo enviado'),
          content: const Text(
              'Se ha enviado el correo de restablecimiento de contraseña. Por favor, revise su bandeja de entrada y siga las instrucciones.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(
                    context); // Volver a la pantalla de inicio de sesión
              },
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Ocurrió un error desconocido.';
      if (e.code == 'invalid-email') {
        errorMessage = 'El correo electrónico ingresado no es válido.';
      } else if (e.code == 'user-not-found') {
        errorMessage =
            'No se encontró ningún usuario con este correo electrónico.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ocurrió un error inesperado.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Restablecer Contraseña',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 200, 211, 229),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // Fondo azul blanco perlado
          Positioned.fill(
            child: Container(
              color: const Color.fromARGB(
                  255, 200, 211, 229), // Color azul blanco perlado
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Introduce el correo electrónico para enviar los pasos para reestablecer la contraseña.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    labelStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(color: Colors.black),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _sendPasswordResetEmail(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color.fromARGB(255, 3, 54, 112), // Fondo azul
                    foregroundColor: Colors.white, // Letras en blanco
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 15,
                    ),
                    minimumSize:
                        const Size(double.infinity, 50), // Botón más ancho
                  ),
                  child: const Text('Enviar'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Para manejar Firebase Firestore
import 'email_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance; // Instancia de Firestore
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  // Método para registrar al usuario
  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        User? user = userCredential.user;

        if (user != null) {
          // Guardar datos del usuario en Firestore
          await _firestore.collection('Usuarios creados').doc(user.uid).set({
            'nombre': _nameController.text.trim(),
            'apellidos': _surnameController.text.trim(),
            'telefono': _phoneController.text.trim(),
            'email': _emailController.text.trim(),
            'nombreUsuario': _usernameController.text.trim(),
            'puntosTotales': 0,
            'setsGanadosTotales': 0,
            'juegosGanadosTotales': 0,
            'juegosPerdidosTotales': 0,
          });

          // Enviar verificación de correo
          await user.sendEmailVerification();

          // Navegar a la pantalla de verificación de correo
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EmailVerificationScreen(
                nombre: _nameController.text.trim(),
                apellidos: _surnameController.text.trim(),
                telefono: _phoneController.text.trim(),
                email: _emailController.text.trim(),
                nombreUsuario: _usernameController.text.trim(),
              ),
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error en el registro: ${e.message}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Registro',
          style: TextStyle(
            color: Colors.black,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor:
            const Color.fromARGB(255, 200, 211, 229), // Fondo indicado
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
              color: const Color.fromARGB(255, 200, 211, 229), // Fondo indicado
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 30),
                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Nombre',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Introduce tu nombre';
                              }
                              if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚüÜñÑ\s-]+\$')
                                  .hasMatch(value)) {
                                return 'El nombre solo debe contener letras, espacios y guiones';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _surnameController,
                            decoration: const InputDecoration(
                              labelText: 'Apellidos',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Introduce tus apellidos';
                              }
                              if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚüÜñÑ\s-]+\$')
                                  .hasMatch(value)) {
                                return 'Los apellidos solo deben contener letras, espacios y guiones';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _phoneController,
                            decoration: const InputDecoration(
                              labelText: 'Teléfono',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Introduce tu teléfono';
                              }
                              if (!RegExp(r'^[0-9]+\$').hasMatch(value)) {
                                return 'El teléfono solo debe contener números';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Correo electrónico',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Introduce tu correo electrónico';
                              }
                              if (!RegExp(
                                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\$')
                                  .hasMatch(value)) {
                                return 'Introduce un correo electrónico válido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _usernameController,
                            decoration: const InputDecoration(
                              labelText: 'Nombre de usuario',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) => value!.isEmpty
                                ? 'Introduce un nombre de usuario'
                                : null,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _passwordController,
                            decoration: const InputDecoration(
                              labelText: 'Contraseña',
                              border: OutlineInputBorder(),
                            ),
                            obscureText: true,
                            validator: (value) => value!.isEmpty
                                ? 'Introduce una contraseña'
                                : null,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _confirmPasswordController,
                            decoration: const InputDecoration(
                              labelText: 'Repite la contraseña',
                              border: OutlineInputBorder(),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value!.isEmpty) return 'Repite tu contraseña';
                              if (value != _passwordController.text) {
                                return 'Las contraseñas no coinciden';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _registerUser,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                  255, 3, 54, 112), // Fondo azul
                              foregroundColor: Colors.white, // Letras en blanco
                              minimumSize: const Size(
                                  double.infinity, 50), // Botón ancho
                            ),
                            child: const Text('Registrarse'),
                          ),

                        ],
                      ),
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

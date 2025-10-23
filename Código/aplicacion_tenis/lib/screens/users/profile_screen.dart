import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final TextEditingController emailAuthController = TextEditingController();
  final TextEditingController passwordAuthController = TextEditingController();

  bool isLoading = true;
  bool isEdited = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('Usuarios creados')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;
          setState(() {
            nameController.text = userData['nombre'] ?? '';
            emailController.text = userData['email'] ?? '';
            usernameController.text = userData['nombreUsuario'] ?? '';
            lastNameController.text = userData['apellidos'] ?? '';
            phoneController.text = userData['telefono'] ?? '';
            isLoading = false;
          });
        } else {
          print('Documento de usuario no encontrado');
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print('Usuario no autenticado');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error al cargar los datos del usuario: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('Usuarios creados')
            .doc(user.uid)
            .update({
          'nombre': nameController.text,
          'email': emailController.text,
          'nombreUsuario': usernameController.text,
          'apellidos': lastNameController.text,
          'telefono': phoneController.text,
        });
        setState(() {
          isEdited = false;
        });
        _reloadPage();
      } catch (e) {
        print('Error al actualizar los datos del usuario: $e');
      }
    }
  }

  Future<void> _deleteUserAccount() async {
    bool confirmDelete = await _showConfirmationDialog();
    if (!confirmDelete) return;

    bool authenticated = await _authenticateUser();
    if (!authenticated) return;

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('Usuarios creados')
            .doc(user.uid)
            .delete();
        await user.delete();

        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Cuenta eliminada con éxito")));
      }
    } catch (e) {
      print('Error al eliminar la cuenta: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error al eliminar la cuenta")));
    }
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Confirmar eliminación"),
            content: Text(
                "¿Está seguro de que desea eliminar su cuenta? Esta acción es irreversible."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text("Cancelar"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text("Eliminar"),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<bool> _authenticateUser() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Autenticación requerida"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Introduzca su email y contraseña para confirmar."),
                TextField(
                  controller: emailAuthController,
                  decoration: InputDecoration(labelText: "Email"),
                ),
                TextField(
                  controller: passwordAuthController,
                  decoration: InputDecoration(labelText: "Contraseña"),
                  obscureText: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text("Cancelar"),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: emailAuthController.text,
                      password: passwordAuthController.text,
                    );
                    Navigator.of(context).pop(true);
                  } catch (e) {
                    print("Error de autenticación: $e");
                    Navigator.of(context).pop(false);
                  }
                },
                child: Text("Confirmar"),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _reloadPage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => EditProfileScreen()),
    );
  }

  void _onFieldChanged() {
    if (!isEdited) {
      setState(() {
        isEdited = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 200, 211, 229),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
              color: const Color.fromARGB(255, 200, 211, 229),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      child: Icon(
                        Icons.account_circle,
                        size: 80,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 40),
                    ProfileTextField(
                      controller: nameController,
                      label: 'Nombre',
                      onChanged: _onFieldChanged,
                    ),
                    const SizedBox(height: 20),
                    ProfileTextField(
                      controller: lastNameController,
                      label: 'Apellidos',
                      onChanged: _onFieldChanged,
                    ),
                    const SizedBox(height: 20),
                    ProfileTextField(
                      controller: emailController,
                      label: 'Correo Electrónico',
                      onChanged: _onFieldChanged,
                    ),
                    const SizedBox(height: 20),
                    ProfileTextField(
                      controller: usernameController,
                      label: 'Nombre de Usuario',
                      onChanged: _onFieldChanged,
                    ),
                    const SizedBox(height: 20),
                    ProfileTextField(
                      controller: phoneController,
                      label: 'Teléfono',
                      onChanged: _onFieldChanged,
                    ),
                    const SizedBox(height: 40),
                    if (isEdited)
                      ElevatedButton(
                        onPressed: _updateUserData,
                        child: const Text('Confirmar Cambios'),
                      ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _deleteUserAccount,
                      child: Text("Eliminar mi cuenta"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white, // Texto en blanco
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class ProfileTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final VoidCallback onChanged;

  const ProfileTextField({
    required this.controller,
    required this.label,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      child: TextFormField(
        controller: controller,
        onChanged: (_) => onChanged(),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[300],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

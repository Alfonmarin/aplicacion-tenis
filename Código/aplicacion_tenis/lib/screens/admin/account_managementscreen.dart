import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountManagementScreen extends StatefulWidget {
  @override
  _AccountManagementScreenState createState() =>
      _AccountManagementScreenState();
}

class _AccountManagementScreenState extends State<AccountManagementScreen> {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController passwordAuthController = TextEditingController();
  List<DocumentSnapshot> users = [];
  List<DocumentSnapshot> filteredUsers = [];
  List<DocumentSnapshot> selectedUsers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('Usuarios creados').get();

      setState(() {
        users = snapshot.docs;
        filteredUsers = users;
        isLoading = false;
      });
    } catch (e) {
      print('Error al cargar usuarios: $e');
    }
  }

  void _filterUsers(String query) {
    setState(() {
      filteredUsers = users.where((user) {
        final email = user['email']?.toLowerCase() ?? '';
        final username = user['nombreUsuario']?.toLowerCase() ?? '';
        return email.contains(query.toLowerCase()) ||
            username.contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<void> _deleteSelectedUsers() async {
    bool confirmDelete = await _showDeleteConfirmationDialog();
    if (!confirmDelete) return;

    try {
      for (var user in selectedUsers) {
        await FirebaseFirestore.instance
            .collection('Usuarios creados')
            .doc(user.id)
            .delete();
      }

      setState(() {
        users.removeWhere((user) => selectedUsers.contains(user));
        filteredUsers.removeWhere((user) => selectedUsers.contains(user));
        selectedUsers.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Usuarios eliminados exitosamente")),
      );
    } catch (e) {
      print('Error al eliminar usuarios: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al eliminar usuarios")),
      );
    }
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Confirmar eliminación"),
            content: Text(
                "¿Está seguro de que desea eliminar los usuarios seleccionados?"),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 117, 52, 221),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Gestión de Cuentas',
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
          Positioned.fill(
            child: Image.asset(
              'assets/fondo_admin.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: searchController,
                  onChanged: _filterUsers,
                  decoration: InputDecoration(
                    labelText: 'Buscar por correo o usuario',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Usuarios registrados: ${users.length}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    final isSelected = selectedUsers.contains(user);

                    return ListTile(
                      leading: Checkbox(
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              selectedUsers.add(user);
                            } else {
                              selectedUsers.remove(user);
                            }
                          });
                        },
                      ),
                      title: Text(
                        user['nombreUsuario'] ?? 'Usuario sin nombre',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(user['email'] ?? 'Sin correo'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteSelectedUsers(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: selectedUsers.isNotEmpty ? _deleteSelectedUsers : null,
        backgroundColor:
            selectedUsers.isNotEmpty ? Colors.red : Colors.grey[400],
        child: const Icon(Icons.delete),
      ),
    );
  }
}

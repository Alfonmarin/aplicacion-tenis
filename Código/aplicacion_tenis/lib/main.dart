import 'package:aplicacion_tenis/screens/users/user_screen.dart';
import 'package:flutter/material.dart';
import 'screens/login/login_screen.dart';
import 'screens/register/register_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/admin/admin_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      home: const HomeScreen(), // Aquí se inicia en HomeScreen
      routes: {
        '/home': (context) => const HomeScreen(),
        '/admin': (context) => AdminScreen(),
        '/user': (context) => UserScreen(),
        '/register': (context) => const RegisterScreen(),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isAnimated = false;

  @override
  void initState() {
    super.initState();
    // Iniciar la animación después de una pequeña demora
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isAnimated = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Imagen de fondo
          Positioned.fill(
            child: Image.asset(
              'assets/Logo_IS_ii-Photoroom.jpg', // Ruta de la imagen de fondo
              fit: BoxFit.cover,
            ),
          ),
          // Capa para oscurecer el fondo
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.4), // Fondo más oscuro
            ),
          ),
          // Contenido animado
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Stack(
              children: [
                // Texto "TENIS UPM"
                AnimatedPositioned(
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeInOut,
                  top: _isAnimated
                      ? 50
                      : MediaQuery.of(context).size.height / 2 - 100,
                  left: 0,
                  right: 0,
                  child: const Center(
                    child: Text(
                      'TENIS UPM',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white, // Texto en blanco
                        fontSize: 60, // Tamaño grande
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Botones "Registrarme" e "Iniciar sesión"
                AnimatedPositioned(
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeInOut,
                  top: _isAnimated
                      ? MediaQuery.of(context).size.height - 200
                      : MediaQuery.of(context).size.height / 2 + 100,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Registrarme',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                              255, 3, 54, 112), // Fondo azul
                          padding: const EdgeInsets.symmetric(
                              horizontal: 100, vertical: 20),
                          side: const BorderSide(color: Colors.blue),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Iniciar sesión',
                          style: TextStyle(
                            color: Colors.white, // Texto blanco
                            fontSize: 18, // Texto más grande
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.transparent, // Fondo translúcido
                          padding: const EdgeInsets.symmetric(
                              horizontal: 100, vertical: 20),
                          side: const BorderSide(color: Colors.brown),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
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

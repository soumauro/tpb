
import 'package:cobradortpb/presenter/autetication/createuser.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../navigator/navbar.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  static const router = '/splash';

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkUser(); // Verificar o usuário quando a página inicia
  }

  Future<void> _checkUser() async {
    // Verifica o estado de autenticação do usuário
    User? user = FirebaseAuth.instance.currentUser;
    await Future.delayed(const Duration(seconds: 2)); // Adiciona um pequeno atraso

    if (user != null) {
      Get.offNamed(NavigationBarPage.router); // Navega para a barra de navegação se o usuário estiver autenticado
    } else {
      Get.offNamed(CreateUserPage.router); // Navega para a página de login se não estiver autenticado
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blueAccent, Colors.lightBlue],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícone ou logotipo
              CircleAvatar(
                radius: 80,
                backgroundColor: Colors.white,
                child: ClipOval(
                  child: Image.asset(
                    'assets/icon.jpg',
                    fit: BoxFit.cover,
                    width: 150,
                    height: 150,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Texto estilizado
              const Text(
                'Bem-vindo ao CartaMoz!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              // Indicador de progresso
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

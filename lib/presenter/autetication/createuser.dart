import 'dart:convert';
import 'package:cobradortpb/infra/apiname.dart';
import 'package:cobradortpb/infra/models/collectores.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class CreateUserPage extends StatefulWidget {
  const CreateUserPage({super.key});
  static const router = '/creatUser';

  @override
  State<CreateUserPage> createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<CreateUserPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Controladores dos campos de email, senha e nome
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  // Variável para controlar a exibição da senha
  bool _obscurePassword = true;
  bool _isLoading = false;
  String _message = '';

  // Função para inserir usuário no banco de dados
  Future<void> insertUser(CollectorsModel collector) async {
    try {
      final response = await http.post(
        Uri.parse('$collectores/insert'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(collector.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Usuário inserido com sucesso!");
      } else {
        print("Falha ao inserir o usuário: ${response.statusCode}");
        print("Corpo da resposta: ${response.body}");
      }
    } catch (e) {
      print("Erro ao inserir usuário: $e");
    }
  }

  // Função para criar usuário no Firebase Auth
  Future<void> _createUser() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      if (!_validateFields()) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      CollectorsModel collectorExample = CollectorsModel(
        id: 1,
        createdAt: DateTime.now(),
        available: 0,
        collectorUuid: userCredential.user?.uid,
        name: _nameController.text.trim(),
      );
      insertUser(collectorExample);

      setState(() {
        _message = 'Usuário criado com sucesso: ${userCredential.user?.email}';
        _emailController.clear();
        _passwordController.clear();
        _nameController.clear();
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'weak-password') {
          _message = 'A senha é muito fraca.';
        } else if (e.code == 'email-already-in-use') {
          _message = 'Esse email já está sendo usado.';
        } else {
          _message = 'Erro: ${e.message}';
        }
      });
    } catch (e) {
      setState(() {
        _message = 'Erro inesperado: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Função para validar os campos do formulário
  bool _validateFields() {
    if (_emailController.text.isEmpty) {
      setState(() {
        _message = 'O campo de email é obrigatório.';
      });
      return false;
    }
    if (!_emailController.text.contains('@')) {
      setState(() {
        _message = 'Insira um email válido.';
      });
      return false;
    }
    if (_passwordController.text.isEmpty || _passwordController.text.length < 6) {
      setState(() {
        _message = 'A senha deve ter no mínimo 6 caracteres.';
      });
      return false;
    }
    if (_nameController.text.isEmpty) {
      setState(() {
        _message = 'O campo de nome é obrigatório.';
      });
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Usuário'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Campo de texto para Nome
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Campo de texto para Email
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            // Campo de texto para Senha com ícone de visibilidade
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Senha',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              obscureText: _obscurePassword,
            ),
            const SizedBox(height: 16),

            // Botão de criar usuário
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _createUser,
                    child: const Text('Criar Conta'),
                  ),

            const SizedBox(height: 16),

            // Exibição de mensagem
            Text(
              _message,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

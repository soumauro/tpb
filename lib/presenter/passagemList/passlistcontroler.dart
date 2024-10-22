import 'dart:convert';
import 'package:cobradortpb/infra/models/ticket.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

import '../../infra/apiname.dart';

class PassagemController extends GetxController {
  // Lista observável de passagens
  RxList<TicketModel> passagensList = <TicketModel>[].obs;

  // Variável de carregamento para controlar o estado
  var isLoading = false.obs;

  // URL da API para buscar passagens (ajuste para o seu caso)
  @override
  void onInit() {
    super.onInit();
    getPassagensUsuario();
  }

  // Função para buscar as passagens do usuário
  Future<void> getPassagensUsuario() async {
    try {
      // Obtém o usuário atual autenticado
      User? user = FirebaseAuth.instance.currentUser;

      // Verifica se o usuário está autenticado
      if (user != null) {
        String uid = user.uid; // UID do Firebase

        // Define a URL da API com o UID
        var url = Uri.parse('$ticketsUrl/$uid');

        // Inicia o estado de carregamento
        isLoading(true);

        // Faz a requisição HTTP GET
        var response = await http.get(
          url,
          headers: {'Content-Type': 'application/json'},
        );

        // Verifica se a requisição foi bem-sucedida
        if (response.statusCode == 200) {
          var jsonData = jsonDecode(response.body);

          // Se o formato da resposta é válido
          if (jsonData['data'] != null && jsonData['data'] is List) {
            List<dynamic> data = jsonData['data'];

            // Mapeia a lista de passagens e atualiza a observável
            passagensList
                .assignAll(data.map((e) => TicketModel.fromJson(e)).toList());
          } else {
            Get.snackbar(
              'Erro',
              'Estrutura de dados inválida da API',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red.withOpacity(0.5),
              colorText: Colors.white,
            );
          }
        } else {
          Get.snackbar(
            'Erro',
            'Erro na solicitação: ${response.statusCode}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withOpacity(0.5),
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          'Erro',
          'Usuário não autenticado',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.5),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao buscar passagens: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.5),
        colorText: Colors.white,
      );
    } finally {
      // Finaliza o estado de carregamento
      isLoading(false);
    }
  }
}

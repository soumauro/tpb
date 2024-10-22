import 'dart:convert';
import 'package:cobradortpb/infra/apiname.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../infra/models/rotas.dart';
import 'package:http/http.dart' as http;

class RotaController extends GetxController {
  // Lista de rotas carregadas
  var rotas = <RotaModel>[].obs;

  // Estado de carregamento
  var isLoading = false.obs;

  @override
  void onInit() {
  
    super.onInit();
    getRotas();
  }

  // Método para buscar rotas do banco de dados (ou API)
  Future<void> getRotas() async {
    try {
      var url = Uri.parse('$rotasUrl/all');

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

          // Mapeia a lista de rotas e atualiza a observável
          rotas.assignAll(data.map((e) => RotaModel.fromMap(e)).toList());
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
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao buscar rotas: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.5),
        colorText: Colors.white,
      );
    } finally {
      // Finaliza o estado de carregamento
      isLoading(false);
    }
  }

  // Método para buscar uma rota específica pelo UUID
  Future<RotaModel?> getRotaByUuid(String uuid) async {
    try {
      var url = Uri.parse('$rotasUrl/$uuid');
      var response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);

        if (jsonData['data'] != null) {
          return RotaModel.fromMap(jsonData['data']);
        } else {
          Get.snackbar(
            'Erro',
            'Rota não encontrada',
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
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao buscar rota: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.5),
        colorText: Colors.white,
      );
    }

    return null;
  }

  
}

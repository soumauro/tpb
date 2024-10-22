import 'dart:async';
import 'dart:convert';
import 'package:cobradortpb/infra/models/busmodel.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class Buscontroller extends GetxController {
  List<BusModel>? busList;
  late BusModel bus;
  Position? userPosition;
  StreamSubscription<Position>? positionStream;
  List <LatLng>  ?  paragens; 
  // Configurações de localização para obter alta precisão
  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,  // Atualizar após se mover 100 metros
  );
    CameraPosition kGooglePlex = const CameraPosition(
    target: LatLng(-19.831594, 34.845235),
    zoom: 14.4746,
  );

  @override
  void onInit() {
    super.onInit();
    getBusData('oiom'); // ID ou UUID do ônibus

    // Iniciar o stream de localização para monitorar a posição do usuário
    positionStream = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position? position) {
      if (position != null) {
        userPosition = position;
        print('Posição atual: ${position.latitude}, ${position.longitude}');
      } else {
        print('Posição desconhecida');
      }
    });
  }

  // Método para buscar os dados do ônibus pela API
  Future<void> getBusData(String userId) async {
    try {
      var url = Uri.parse(
          'https://chapa100.onrender.com/api/tpb/bus/collector/ojsodj'); // Endpoint da API
      var response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);

        if (jsonData['data'] != null && jsonData['data'] is List) {
          List<dynamic> data = jsonData['data'];
          busList = data.map((e) => BusModel.fromJson(e)).toList();

          if (busList!.isNotEmpty) {
            bus = busList![0]; // Pega o primeiro ônibus da lista
          
          }

          update(); // Atualiza o estado do controller para refletir os dados obtidos
        } else {
          _showErrorSnackbar('Estrutura de dados inválida da API');
        }
      } else {
        _showErrorSnackbar('Erro na solicitação: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorSnackbar('Erro ao fazer solicitação: $e');
    }
  }

  // Atualiza a localização do ônibus na API
  Future<void> updateBusLocation() async {
    try {
      if (busList != null && busList!.isNotEmpty && userPosition != null) {
        var data = {
          "location": {
            "latitude":  -19.831529,
            "longitude": 34.845235,
          }
        };
        String body = jsonEncode(data);

        var url = Uri.parse(
            'https://chapa100.onrender.com/api/tpb/bus/collector/${bus.busUuid}'); // Endpoint correto
        var response = await http.put(
          url,
          headers: {'Content-Type': 'application/json'},
          body: body,
        );

        if (response.statusCode == 200) {
          _showSuccessSnackbar('Localização do ônibus atualizada com sucesso');
        } else {
          _showErrorSnackbar('Erro ao atualizar a localização do ônibus: ${response.statusCode}');
        }
      } else {
        _showErrorSnackbar('Não foi possível obter a posição ou o ônibus não está na lista');
      }
    } catch (e) {
      _showErrorSnackbar('Erro ao atualizar a localização do ônibus: $e');
    }
  }

  // Exibe uma notificação de erro
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Erro',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.5),
      colorText: Colors.white,
    );
  }

  // Exibe uma notificação de sucesso
  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Sucesso',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withOpacity(0.5),
      colorText: Colors.white,
    );
  }

  @override
  void onClose() {
    // Cancelar o stream de localização quando o controlador for destruído
    positionStream?.cancel();
    super.onClose();
  }
}

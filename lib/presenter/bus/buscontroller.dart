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
  late BitmapDescriptor busIcon;
  late BitmapDescriptor paragemIcon;
  late BusModel bus;
  Position? userPosition;
  StreamSubscription<Position>? positionStream;
  List<LatLng>? paragens;
  
  // Configurações de localização para obter alta precisão
  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100, // Atualizar após se mover 100 metros
  );

  // CameraPosition inicial
  CameraPosition kGooglePlex = const CameraPosition(
    target: LatLng(-19.831594, 34.845235), // Fallback caso a localização não esteja disponível
    zoom: 14.4746,
  );

  @override
  void onInit() {
    super.onInit();
    _loadCustomMarkerIcons();
    _getUserLocation(); // Obter a localização atual do usuário
    getBusData('oiom'); // ID ou UUID do ônibus

    // Iniciar o stream de localização para monitorar a posição do usuário
    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      if (position != null) {
        userPosition = position;
        
        print('Posição atual: ${position.latitude}, ${position.longitude}');
        
        // Atualiza a posição da câmera para a localização do usuário
        kGooglePlex = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 14.4746,
        );
        update(); // Atualiza a interface
      } else {
        print('Posição desconhecida');
      }
    });
  }

  // Método para carregar ícones personalizados para os marcadores
  Future<void> _loadCustomMarkerIcons() async {
    busIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(40, 40)), // Tamanho do ícone
      'assets/bus.jpg',
    );

    paragemIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(20, 20)),
      'assets/house.png',
    );
    update(); // Atualiza o estado para aplicar os ícones
  }

  // Método para obter a localização atual do usuário
  Future<void> _getUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      userPosition = position;

      // Atualiza a câmera para a localização do usuário
      kGooglePlex = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 14.4746,
      );
      
      update(); // Atualiza o estado para refletir a nova posição
    } catch (e) {
      print('Erro ao obter a localização do usuário: $e');
    }
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
            "latitude": -19.831529,
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
          _showErrorSnackbar(
              'Erro ao atualizar a localização do ônibus: ${response.statusCode}');
        }
      } else {
        _showErrorSnackbar(
            'Não foi possível obter a posição ou o ônibus não está na lista');
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
LatLng? nearestParagem; // Guardará a paragem mais próxima

  // Calcula a paragem mais próxima com base na posição atual do usuário
  void findNearestParagem() {
    if (userPosition == null || bus.paragem == null || bus.paragem!.isEmpty) {
      _showErrorSnackbar('Não foi possível obter a localização ou paragens.');
      return;
    }

    double minDistance = double.infinity;

    // Percorre todas as paragens e calcula a distância para cada uma
    for (var paragem in bus.paragem!) {
      double distance = Geolocator.distanceBetween(
        userPosition!.latitude, // Posição atual do usuário
        userPosition!.longitude,
        paragem.x, // Latitude da paragem
        paragem.y, // Longitude da paragem
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearestParagem = LatLng(paragem.x, paragem.y); // Atualiza a paragem mais próxima
      }
    }

    update(); // Atualiza o estado para refletir a nova paragem mais próxima
  }

  
  @override
  void onClose() {
    // Cancelar o stream de localização quando o controlador for destruído
    positionStream?.cancel();
    super.onClose();
  }
}

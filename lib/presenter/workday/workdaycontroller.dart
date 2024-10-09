import 'dart:async';
import 'dart:convert';

import 'package:cobradortpb/infra/models/workdaymodel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:geolocator/geolocator.dart';

class WorkdayController extends GetxController {
  // Lista de objetos WorkdayModel
  List<WorkdayModel>? workday;
  late WorkdayModel _userWorkday;
  DateTime today = DateTime.now();

  // Variáveis para o Scanner de QR Code
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? qrController;
  String? qrText;

  // Variáveis para Geolocalização
  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );
  StreamSubscription<Position>? positionStream;
  Position? userPosition;

  @override
  void onInit() {
    super.onInit();

    getWorker('ojsodj');

    _determinePosition();

    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      if (position != null) {
        userPosition = position;
        print('Posição atual: ${position.latitude}, ${position.longitude}');
      } else {
        print('Posição desconhecida');
      }
    });
  }

  @override
  void onClose() {
    super.onClose();
    // Descartar o controlador do QR Code, se existir
    qrController?.dispose();
    // Cancelar a subscrição do stream de geolocalização, se existir
    positionStream?.cancel();
  }

  // Função chamada quando o QRView é criado
  void _onQRViewCreated(QRViewController controller) {
    qrController = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null && scanData.code != qrText) {
        qrText = scanData.code;
        controller.pauseCamera(); // Pausar a câmera após a leitura
        // Executar ação com o código QR
        // performActionWithQRCode(qrText!);
        updateWorkdy(1);
        update(); // Atualizar a UI
      }
    });
  }

  // Método para reiniciar o scanner de QR Code
  void restartScanner() {
    qrController?.resumeCamera(); // Reiniciar o leitor de QR
    qrText = null; // Resetar o texto do QR
    update(); // Atualizar a UI
  }

  // Função para exibir a caixa de diálogo do QR Code
  void showQRDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titlePadding: EdgeInsets.zero,
        contentPadding: const EdgeInsets.all(20),
        title: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: const Text(
            'Escanear QR Code',
            style: TextStyle(color: Colors.white),
          ),
        ),
        content: SizedBox(
          width: 300,
          height: 400,
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 4,
                child: QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                  overlay: QrScannerOverlayShape(
                    borderColor: Colors.blue,
                    borderRadius: 10,
                    borderLength: 30,
                    borderWidth: 10,
                    cutOutSize: 250,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                flex: 1,
                child: Center(
                  child: (qrText != null)
                      ? const Text(
                          'Ônibus escaneado e atualizado com sucesso',
                          style: TextStyle(color: Colors.green),
                        )
                      : const Text(
                          'Escaneie um código QR',
                          style: TextStyle(color: Colors.black),
                        ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (qrController != null) {
                    restartScanner();
                  }
                },
                child: const Text('Reiniciar Scanner'),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // Função para buscar dados do workday
  Future<void> getWorker(String userId) async {
    // String formattedDate = usarei o futuro
    //     "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    try {
      var url = Uri.parse(
          'https://chapa100.onrender.com/api/tpb/workday/$userId/2024-10-06');
      var response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['data'] != null && jsonData['data'] is List) {
          List<dynamic> data = jsonData['data'];
          workday = data.map((e) => WorkdayModel.fromJson(e)).toList();

          update();
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
        'Erro ao fazer solicitação: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.5),
        colorText: Colors.white,
      );
    }
  }

  // Função para atualizar o status do workday
  Future<void> updateWorkdy(int status) async {
    try {
      if (workday != null && workday!.isNotEmpty) {
        _userWorkday = workday![0];
        if (qrText == _userWorkday.busUuid) {
          // Converter o modelo WorkdayModel para JSON
          var datas = {
            "collectorUuid": _userWorkday.collectorUuid,
            "busUuid": _userWorkday.busUuid,
            "scheduleUuid": _userWorkday.scheduleUuid,
            "status": status
          };
          String body = jsonEncode(datas);

          var url = Uri.parse(
              'https://chapa100.onrender.com/api/tpb/workday/${_userWorkday.mouthDay}'); // Ajuste para o endpoint correto
          var response = await http.put(
            url,
            headers: {'Content-Type': 'application/json'},
            body: body,
          );

          if (response.statusCode == 200) {
            Get.snackbar(
              'Sucesso',
              'Status do workday atualizado com sucesso',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green.withOpacity(0.5),
              colorText: Colors.white,
            );
            // Re-fetch workday data, se necessário
            getWorker('ojsodj');
          } else {
            Get.snackbar(
              'Erro',
              'Erro ao atualizar o workday: ${response.statusCode}',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red.withOpacity(0.5),
              colorText: Colors.white,
            );
          }
        } else {
          Get.snackbar(
            'Erro',
            'Código QR não corresponde ao ônibus',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withOpacity(0.5),
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          'Erro',
          'Nenhum workday encontrado para atualizar',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.5),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao atualizar o workday: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.5),
        colorText: Colors.white,
      );
    }
  }

  // Função para determinar a posição do usuário
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar se os serviços de localização estão habilitados
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar(
        'Erro',
        'Serviços de localização estão desabilitados.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.5),
        colorText: Colors.white,
      );
      return Future.error('Location services are disabled.');
    }

    // Verificar permissões de localização
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar(
          'Erro',
          'Permissões de localização negadas.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.5),
          colorText: Colors.white,
        );
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar(
        'Erro',
        'Permissões de localização permanentemente negadas.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.5),
        colorText: Colors.white,
      );
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // Obter a posição atual do usuário
    return await Geolocator.getCurrentPosition();
  }
}

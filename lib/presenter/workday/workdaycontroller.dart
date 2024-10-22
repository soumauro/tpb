import 'dart:async';
import 'dart:convert';

import 'package:cobradortpb/infra/apiname.dart';
import 'package:cobradortpb/infra/models/workdaymodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:geolocator/geolocator.dart';

import '../../infra/models/trasportpasse.dart';

class WorkdayController extends GetxController {
  // Lista de objetos WorkdayModel
  List<WorkdayModel>? workday;
  late WorkdayModel userWorkday;
  DateTime today = DateTime.now();
  List<Pass>? passList;
  late Pass userpass;
    // Variáveis para o Scanner e autenticar o passDe transport
  final GlobalKey qrKeyPass = GlobalKey(debugLabel: 'QR');
  QRViewController? qrControllerPass;
  String? qrTextPass;

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

  // Timer para atualização automática da localização a cada 2 minutos
  Timer? locationUpdateTimer;

  @override
  void onInit() {
    super.onInit();

    getWorker();  // Obtém as informações do dia de trabalho do usuário

    _determinePosition();  // Obtém a posição atual

    // Escuta as mudanças de posição e atualiza a localização
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

  @override
  void onClose() {
    super.onClose();
    qrController?.dispose();  // Descartar o controlador do QR Code
    positionStream?.cancel();  // Cancelar a subscrição do stream de geolocalização
    locationUpdateTimer?.cancel();  // Cancelar o timer de atualização de localização
  }

  // Função chamada quando o QRView é criado
 void _onQRViewCreated(QRViewController controller) {
  qrController = controller;
  controller.scannedDataStream.listen((scanData) {
    if (scanData.code != null && scanData.code != qrText) {
      qrText = scanData.code;
      if (qrText == userWorkday.busUuid) {
        controller.pauseCamera();  
        update();  
        updateWorkdy(1);  
      } else {
        controller.pauseCamera();  
        update();
        
        Get.snackbar(
          'Erro',
          'Código QR inválido ou não corresponde ao ônibus atual $qrText ${userWorkday.busUuid}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.5),
          colorText: Colors.white,
        );
      }
    }
  });
}

      
 
  // Método para reiniciar o scanner de QR Code
  void restartScanner() {
    qrController?.resumeCamera();  // Reiniciar o leitor de QR
    qrText = null;  // Resetar o texto do QR
    update();  // Atualizar a UI
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
  Future<void> getWorker() async {
    String formattedDate = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuário não está logado.');
      }
      String uid = user.uid;
      var url = Uri.parse('https://chapa100.onrender.com/api/tpb/workday/$uid/$formattedDate');
      var response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['data'] != null && jsonData['data'] is List) {
          List<dynamic> data = jsonData['data'];
          workday = data.map((e) => WorkdayModel.fromJson(e)).toList();
          userWorkday = workday!.first;
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

  void startWorkday() {
  // Verificar se o código QR escaneado é igual ao busUuid do dia de trabalho
  if ( identical(qrText,userWorkday.busUuid )) {
    // Se for igual, atualize o status do workday (inicie o dia de trabalho)
    updateWorkdy(1);  // Status 1 indica que o trabalho foi iniciado

    // Iniciar o timer para atualizar a localização a cada 2 minutos
    // locationUpdateTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
    //   updateBusLocation();  // Atualizar a localização do ônibus
    // });
  } else {
    // Se o QR Code não corresponder ao busUuid, exibir mensagem de erro
    Get.snackbar(
      'Erro',
      'Código QR inválido ou não corresponde ao ônibus atual',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.5),
      colorText: Colors.white,
    );
  }
}


  // Função para atualizar a localização do ônibus
  Future<void> updateBusLocation() async {
    try {
      if (workday != null && workday!.isNotEmpty && userPosition != null) {
        userWorkday = workday![0];

        // Dados de localização para enviar ao servidor
        var data = {
          "latitude": userPosition!.latitude,
          "longitude": userPosition!.longitude,
          "busUuid": userWorkday.busUuid,
        };
        String body = jsonEncode(data);

        var url = Uri.parse('https://chapa100.onrender.com/api/tpb/location/update');
        var response = await http.put(
          url,
          headers: {'Content-Type': 'application/json'},
          body: body,
        );

        if (response.statusCode == 200) {
          print('Localização do ônibus atualizada com sucesso');
        } else {
          print('Erro ao atualizar a localização: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Erro ao atualizar localização: $e');
    }
  }

  // Função para iniciar/atualizar o dia de trabalho no servidor
  Future<void> updateWorkdy(int status) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuário não está logado.');
      }
//      String formattedDate = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

      // Dados para enviar ao servidor
       var data = {
            "collectorUuid": userWorkday.collectorUuid,
            "busUuid": userWorkday.busUuid,
            "scheduleUuid": userWorkday.scheduleUuid,
            "status": status
          };
      String body = jsonEncode(data);

      var url = Uri.parse('https://chapa100.onrender.com/api/tpb/workday/${userWorkday.mouthDay}');
      var response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        Get.snackbar(
          'Sucesso',
          'Dia de trabalho atualizado',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.5),
          colorText: Colors.white,
        );
        print('Dia de trabalho atualizado com sucesso');
      } else {
        Get.snackbar(
          'Erro',
          'Erro ao atualizar o dia de trabalho: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.5),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao atualizar o dia de trabalho: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.5),
        colorText: Colors.white,
      );
    }
  }

  // Função para determinar a posição atual do usuário
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar(
        'Erro',
        'Serviço de localização desabilitado. Habilite o serviço para continuar.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.5),
        colorText: Colors.white,
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar(
          'Erro',
          'Permissão de localização negada.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.5),
          colorText: Colors.white,
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar(
        'Erro',
        'Permissão de localização permanentemente negada. Vá para as configurações do aplicativo e habilite a permissão.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.5),
        colorText: Colors.white,
      );
      return;
    }

    // Localização obtida com sucesso
    userPosition = await Geolocator.getCurrentPosition();
  }

}

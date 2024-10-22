// ignore_for_file: sort_child_properties_last

import 'package:cobradortpb/infra/models/trasportpasse.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PassQRScannerDialog extends StatefulWidget {
  const PassQRScannerDialog({super.key});

  @override
  PassQRScannerDialogState createState() => PassQRScannerDialogState();
}

class PassQRScannerDialogState extends State<PassQRScannerDialog> {
  final GlobalKey qrKeyPass = GlobalKey(debugLabel: 'QR');
  QRViewController? qrController;
  String? qrText;
  Pass? userpass;
  bool isLoading = false;
  bool isSuccess = false;
  String? errorMessage;

  @override
  void dispose() {
    qrController?.dispose();
    super.dispose();
  }

  void _onQRPassViewCreated(QRViewController controller) {
    setState(() {
      qrController = controller;
    });

    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null && scanData.code != qrText) {
        setState(() {
          qrText = scanData.code;
        });

        controller.pauseCamera();
        scanPass(qrText!);
      }
    });
  }

  Future<void> scanPass(String qrCode) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      var url = Uri.parse(
          'https://chapa100.onrender.com/api/tpb/transportPass/$qrCode');
      var response = await http.get(url);
      final data = json.decode(response.body);

      if (response.statusCode == 200 &&
          data['data'] != null &&
          data['data'].isNotEmpty) {
        setState(() {
          userpass = Pass.fromJson(data['data'][0]);
          isSuccess = true;
        });
        Get.snackbar(
          'Sucesso',
          'Ônibus escaneado e atualizado com sucesso',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.5),
          colorText: Colors.white,
        );
      } else {
        throw Exception('Erro ao verificar o passe ou dados não encontrados.');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Falha ao verificar passe: $e';
        isLoading = false;
      });
      Get.snackbar(
        'Erro',
        errorMessage!,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.5),
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void restartScanner() {
    qrController?.resumeCamera();
    setState(() {
      qrText = null;
      userpass = null;
      errorMessage = null;
      isSuccess = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
          'Escanear QR Code do Pass',
          style: TextStyle(color: Colors.white),
        ),
      ),
      content: SizedBox(
        width: 300,
        height: 400,
        child: isSuccess
            ? Column(
                children: [
                  Text('Nome: ${userpass!.name}'),
                  Text('Passe: ${userpass!.passName}'),
                  Text(
                      'Tipo: ${userpass!.passType == 1 ? 'Normal' : 'Especial'}'),
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                      userpass!.photoUrl ?? '',
                    ),
                    radius: 54,
                  ),
                  DateTime.now().isAfter(userpass!.endAt!) ?
                    const Text(
                      'Passe inválido',
                      style: TextStyle(color: Colors.red),
                    )
                  :  Column(children: [
                     OutlinedButton.icon(onPressed: (){}, label: const Text("Usar Passe"), icon: const Icon(Icons.bus_alert),),
                     OutlinedButton.icon(onPressed: (){Get.back();}, label: const Text("Cancelar"), icon: const Icon(Icons.close),),

                  ],)
                  ,
                ],
              )
            : Column(
                children: <Widget>[
                  Expanded(
                    flex: 4,
                    child: QRView(
                      key: qrKeyPass,
                      onQRViewCreated: _onQRPassViewCreated,
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
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : errorMessage != null
                              ? Text(
                                  errorMessage!,
                                  style: const TextStyle(color: Colors.red),
                                )
                              : qrText != null && userpass != null
                                  ? Column(
                                      children: [
                                        const Text(
                                          'Ônibus escaneado com sucesso',
                                          style: TextStyle(color: Colors.green),
                                        ),
                                        Text(
                                            userpass!.name ?? 'Passe sem nome'),
                                      ],
                                    )
                                  : const Text(
                                      'Escaneie um código QR',
                                      style: TextStyle(color: Colors.black),
                                    ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: restartScanner,
                    child: const Text('Reiniciar Scanner'),
                  ),
                ],
              ),
      ),
    );
  }
}

// Função para abrir o diálogo
void showPassQRDialog(BuildContext context) {
  Get.dialog(
    const PassQRScannerDialog(),
    barrierDismissible: false,
  );
}

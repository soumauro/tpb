import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
class Qrscanner extends StatefulWidget {
  const Qrscanner({super.key});
  static const router = '/qrcodeReader';

  @override
  State<Qrscanner> createState() => _QrscannerState();
}

class _QrscannerState extends State<Qrscanner> {
   final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? qrText;

    void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        qrText = scanData.code;
      });
    });
  }

  // Este método é chamado quando a tela é reconstruída, útil para dispositivos Android que podem precisar de permissões de câmera
  // @override
  // void reassemble() {
  //   super.reassemble();
  //   if (controller != null) {
  //     controller!.pauseCamera();
  //     controller!.resumeCamera();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(backgroundColor: Colors.deepPurple,
      appBar: AppBar(backgroundColor: Colors.amber,
        title: const Text('Scanner QR Code'),
      ),
      body: Column(
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
                cutOutSize: 300,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (qrText != null)
                  ? Text('Código QR: $qrText')
                  : const Text('Escaneie um código QR'),
            ),
          ),
        ],
      ),
    );
  }
}
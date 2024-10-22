import 'dart:async';
import 'dart:convert';

import 'package:cobradortpb/infra/apiname.dart';
import 'package:cobradortpb/infra/models/busmodel.dart';
import 'package:cobradortpb/infra/models/passagem.dart';
import 'package:cobradortpb/infra/widgets/paymentresponse.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';

import '../../infra/models/ticket.dart';
import '../../infra/widgets/confirmticketcard.dart';

class ParagemController extends GetxController {
  // Lista de objetos WorkdayModel
  ///List<WorkdayModel>? workday;
  RxList<PassagemModel> passagensList = <PassagemModel>[].obs;
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
  ///var levar coisas do onibus
  var selectedbus = Rxn<BusModel>();
  
  // Variáveis para controlar a seleção no BottomSheet
  var selectedPassagem = Rxn<PassagemModel>();
  var selectedQuantidade = 0.obs;

  // Variável para controlar a validade do número de telefone
  var isValidPhone = false.obs;

  // Variável para controlar o estado de carregamento
  var isLoading = false.obs;
  var waitingForConfirmation = false.obs;

  // Form Key e Controller para o formulário de pagamento
  final formKey = GlobalKey<FormState>();
  final TextEditingController phoneController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
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

    // Listener para o campo de telefone para validar em tempo real
    phoneController.addListener(() {
      if (RegExp(r'^(84|85)[0-9]{7}$').hasMatch(phoneController.text)) {
        isValidPhone.value = true;
      } else {
        isValidPhone.value = false;
      }
    });
  }

  @override
  void onClose() {
    super.onClose();
    qrController?.dispose();
    positionStream?.cancel();
    phoneController.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    qrController = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null && scanData.code != qrText) {
        qrText = scanData.code;
        controller.pauseCamera();
        getPassagemInfo();
      }
    });
  }

  // Método para reiniciar o scanner de QR Code
  void restartScanner() {
    qrController?.resumeCamera();
    qrText = null;
    update();
  }

  // Função para exibir a caixa do BottomSheet
// Função para exibir a caixa do BottomSheet
  void showBottomSheetCard() {
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(Get.context!).size.height * 0.9,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Comprar Bilhete',
                  style: TextStyle(
                    fontSize: 26, // Aumenta o tamanho da fonte
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Divider(thickness: 1.5),
              const SizedBox(height: 10),
              
              const Text(
                'Escolha o destino:',
                style: TextStyle(
                  fontSize: 18, // Melhorar visibilidade
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              Obx(() {
                if (passagensList.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhuma passagem disponível.',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: passagensList.length,
                  itemBuilder: (context, index) {
                    final element = passagensList[index];
                    return Obx(() {
                      return Card(
                        color: Colors.white,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: Icon(
                            Icons.directions_bus,
                            color: selectedPassagem.value?.uuid == element.uuid
                                ? Colors.blueAccent
                                : Colors.grey,
                          ),
                          title: Text(
                            '${element.startAt} - ${element.endAt}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black, // Melhor contraste
                            ),
                          ),
                          trailing: Text(
                            '${element.price} MTN',
                            style: const TextStyle(color: Colors.black54),
                          ),
                          onTap: () {
                            selectedPassagem.value = element;
                            update();
                            Get.snackbar(
                              "Passagem Selecionada",
                              '${element.startAt} - ${element.endAt}',
                              backgroundColor: Colors.greenAccent,
                              snackPosition: SnackPosition.BOTTOM,
                              colorText: Colors.white,
                            );
                          },
                        ),
                      );
                    });
                  },
                );
              }),
              const SizedBox(height: 20),
              const Text(
                'Escolha o número de passagens:',
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
              const SizedBox(height: 10),
              Obx(() {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(5, (index) {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: selectedQuantidade.value == index + 1
                            ? Colors.blueAccent
                            : Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () {
                        selectedQuantidade.value = index + 1;
                      },
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: selectedQuantidade.value == index + 1
                              ? Colors.white
                              : Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }),
                );
              }),
              const SizedBox(height: 20),
              Obx(() {
                double total = 0;
                if (selectedPassagem.value != null &&
                    selectedQuantidade.value > 0) {
                  total =
                      selectedPassagem.value!.price! * selectedQuantidade.value;
                }
                return Center(
                  child: Text(
                    'Valor Total: ${total.toStringAsFixed(2)} MTN',
                    style: const TextStyle(
                      fontSize: 22, // Aumenta a fonte do valor total
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                );
              }),
              const SizedBox(height: 30),
              const Text(
                'Pagamento',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 15),
              Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Insira o número de telefone do seu M-Pesa:',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        labelText: 'Número de Telefone',
                        prefixIcon:
                            const Icon(Icons.phone, color: Colors.blueAccent),
                        hintText: 'Ex: 841234567',
                        hintStyle: TextStyle(color: Colors.grey.shade600),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Colors.redAccent, // Cor do erro
                            width: 2,
                          ),
                        ),
                      ),
                      style: const TextStyle(color: Colors.black87),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira um número de telefone';
                        } else if (!RegExp(r'^(84|85)[0-9]{7}$')
                            .hasMatch(value)) {
                          return 'Número inválido. Deve começar com 84 ou 85 e ter 9 dígitos';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Obx(() {
                      bool isEnabled = selectedPassagem.value != null &&
                          selectedQuantidade.value > 0 &&
                          isValidPhone.value;

                      return Center(
                        child: ElevatedButton(
                          onPressed: isEnabled && !isLoading.value
                              ? makePayment
                              : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 50,
                              vertical: 15,
                            ),
                            backgroundColor: isEnabled
                                ? Colors.blueAccent
                                : Colors
                                    .redAccent, // Muda a cor para vermelho se desabilitado
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: isLoading.value
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Pagar',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
    );
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

Future<void> getPassagemInfo() async {
  try {
    // URLs para buscar passagens e informações do ônibus
    var url = Uri.parse('$passagens/bus/$qrText');
    var urlBus = Uri.parse('$busUrl/$qrText');
    
    // Fazendo requisição para buscar passagens
    var response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );
    
    // Fazendo requisição para buscar informações do ônibus
    var responsebus = await http.get(
      urlBus,
      headers: {'Content-Type': 'application/json'},
    );

    // Verifica se as respostas foram bem-sucedidas
    if (response.statusCode == 200 && responsebus.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var jsonDataBus = jsonDecode(responsebus.body);

      // Processa os dados de passagens
      if (jsonData['data'] != null && jsonData['data'] is List) {
        List<dynamic> data = jsonData['data'];
        passagensList.assignAll(data.map((e) => PassagemModel.fromJson(e)).toList());

        // Processa os dados do ônibus (verifique se 'dataBus' é um objeto ou lista)
        if (jsonDataBus != null && jsonDataBus['data'] != null) {
          var busData = jsonDataBus['data'][0];

          // Atualiza o valor de selectedbus com o modelo de ônibus
          selectedbus.value = BusModel.fromJson(busData);
        }

        // Atualiza a UI e abre o BottomSheet
        Get.back(); // Fecha o diálogo de QR Code
        showBottomSheetCard(); // Abre o BottomSheet com as passagens
      } else {
        Get.snackbar(
          'Erro',
          'Estrutura de dados inválida da API de passagens',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.5),
          colorText: Colors.white,
        );
      }
    } else {
      // Tratamento de erro caso a requisição não seja bem-sucedida
      Get.snackbar(
        'Erro',
        'Erro na solicitação: ${response.statusCode} ou ${responsebus.statusCode}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.5),
        colorText: Colors.white,
      );
    }
  } catch (e) {
    // Tratamento de erro em caso de exceção
    Get.snackbar(
      'Erro',
      'Erro ao fazer solicitação: $e',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.5),
      colorText: Colors.white,
    );
  }
}

  Future<void> makePayment() async {
    if (!formKey.currentState!.validate()) return;
    var ticketUid = Uuid().v4().toString();
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Usuário não está logado.');
    }
    String uid = user.uid;
    double total = selectedPassagem.value!.price! * selectedQuantidade.value;
    var ticket = TicketModel(
            id: 1,
            createdAt: DateTime.now(),
            available: 1,
            uuid: ticketUid ,
            startAt: selectedPassagem.value!.startAt!,
            endAt: selectedPassagem.value!.endAt!,
            busUuid: selectedbus.value!.busUuid!,
            userClientUuid: uid,
            collectorUuid: selectedPassagem.value!.collectorUid!,
            price: total,
            collectorCheck: 0,
            fiscalCheck: 0,
            scheduleUuid: selectedbus.value!.scheduleUuid!,
            pessoas: selectedQuantidade.value)
        .toJson();
    // Variáveis locais para controle de estado
    var isLoadi = true;
    var resp = false;
    paymentResponse(isLoadi, resp, phoneController.text, total);

    if (selectedPassagem.value == null || selectedQuantidade.value == 0) {
      Get.snackbar(
        'Erro',
        'Por favor, selecione uma passagem e a quantidade.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.5),
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      waitingForConfirmation.value = false;

      final response = await http.post(
        Uri.parse(
            'https://96yixq0fh9.execute-api.us-east-2.amazonaws.com/default'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': '258${phoneController.text}',
          //'amount': total.toStringAsFixed(2),
          'amount': "1",
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = response.body;
        if (responseBody.contains('INS-0')) {
          // Atualizar o status localmente após pagamento
          resp = true;
          await http.post(
            Uri.parse('$ticketsUrl/insert'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(ticket),
          );
          Get.snackbar(
            'Sucesso',
            'Pagamento realizado com sucesso.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withOpacity(0.5),
            colorText: Colors.white,
          );

          // Resetar as seleções após o pagamento
          selectedPassagem.value = null;
          selectedQuantidade.value = 0;
          phoneController.clear();
          confirmtiketCard( TicketModel.fromJson(ticket));
        } else {
          resp = false;
          _showErrorSnackBar('Erro no pagamento. Tente novamente.');
        }
      } else {
        resp = false;
        _showErrorSnackBar('Erro ao processar o pagamento.');
      }
    } catch (e) {
      _showErrorSnackBar('Erro: $e');
      resp = false;
    } finally {
      isLoadi = false;
      isLoading.value = false;
      waitingForConfirmation.value = false;
      paymentResponse(isLoadi, resp, phoneController.text, total);
    }
  }

  void _showErrorSnackBar(String message) {
    Get.snackbar(
      'Erro',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.5),
      colorText: Colors.white,
    );
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

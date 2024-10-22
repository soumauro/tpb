import 'dart:convert';
import 'package:cobradortpb/infra/models/buypass.dart';
import 'package:cobradortpb/infra/models/passprice.dart';
import 'package:cobradortpb/infra/widgets/paymentresponse.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../infra/models/trasportpasse.dart';
import '../../../infra/apiname.dart';

class TransportPassController extends GetxController {
  var transportPass = Rxn<Pass>();
  var selectedPassPrice = Rxn<PassPrice>();
  var passPriceList = <PassPrice>[].obs;
  var isLoading = false.obs;
  var isLoadingPayment = false.obs;
  var passListLoading = false.obs;
  var buypass = false.obs;
  var selectedQuantidade = 0.obs;
  var isValidPhone = false.obs;
  var waitingForConfirmation = false.obs;

  final formKey = GlobalKey<FormState>();
  final TextEditingController phoneController = TextEditingController();
  var error = ''.obs;

  final String baseUrl = transportPassUrl;

  @override
  void onInit() {
    super.onInit();
    fetchTransportPass();
  }

  Future<void> fetchTransportPass() async {
    isLoading.value = true;
    error.value = '';

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuário não está logado.');
      }
      String uid = user.uid;
      final url = Uri.parse('$transportPassUrl/$uid');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data == null || data['data'] == null || data['data'].isEmpty) {
          transportPass.value = null;
        } else {
          transportPass.value = Pass.fromJson(data['data'][0]);
        }
      } else {
        throw Exception('Falha ao buscar dados: ${response.statusCode}');
      }
    } catch (e) {
      error.value = e.toString();
      transportPass.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPassPrice() async {
    passListLoading.value = true;
    error.value = '';

    try {
      final url = Uri.parse('$passPriceUrl/all');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data == null || data['data'] == null || data['data'].isEmpty) {
          passPriceList.clear();
        } else {
          passPriceList.assignAll(
            (data['data'] as List)
                .map((jsonItem) => PassPrice.fromJson(jsonItem))
                .toList(),
          );
        }
      } else {
        throw Exception('Falha ao buscar dados: ${response.statusCode}');
      }
    } catch (e) {
      error.value = e.toString();
      passPriceList.clear();
    } finally {
      passListLoading.value = false;
      update();
    }
  }

  Future<void> makePayment() async {
    if (!formKey.currentState!.validate()) return;
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Usuário não está logado.');
    }
    String uid = user.uid;

    // Variáveis locais para controle de estado
    var isLoading = true;
    var resp = false;
    ////dados da compra
    var buydata = BuyPass(
            available: 1,
            createdAt: DateTime.now(),
            uuid: const Uuid().v4().toString(),
            userUuid: uid,
            endAt: DateTime.now(),
            passType: selectedPassPrice.value!.passType,
            trajectory: selectedPassPrice.value!.trajectory,
            amount: selectedPassPrice.value!.price ?? 0,
            passName: selectedPassPrice.value!.name ?? '')
        .toMap();

    // Chama o paymentResponse enquanto carrega o pagamento
    paymentResponse(
        isLoading, resp, phoneController.text, selectedPassPrice.value!.price!);

    // Verifica se uma passagem foi selecionada corretamente
    if (selectedPassPrice.value == null ||
        selectedPassPrice.value!.price! <= 0) {
      Get.snackbar(
        'Erro',
        'Por favor, selecione uma passagem válida.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.5),
        colorText: Colors.white,
      );
      return;
    }

    try {
      // Define o estado como "Carregando"
      isLoadingPayment.value = true;
      waitingForConfirmation.value = false;

      // Faz a solicitação de pagamento
      final response = await http.post(
        Uri.parse(
            'https://96yixq0fh9.execute-api.us-east-2.amazonaws.com/default'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': '258${phoneController.text}',
          //'amount': selectedPassPrice.value!.price.toString(),
          'amount': "1", // Coloque o valor real aqui
        }),
      );

      // Verifica o status da resposta do pagamento
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = response.body;
        if (responseBody.contains('INS-0')) {
          resp = true; // Pagamento bem-sucedido
          await http.post(
            Uri.parse('$buypassUrl/insert'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(buydata),
          );
          Get.snackbar(
            'Pagamento bem-sucedido',
            'Seu pagamento foi concluído.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withOpacity(0.5),
            colorText: Colors.white,
          );
          fetchTransportPass();
        } else {
          resp = false; // Falha no pagamento
          Get.snackbar(
            'Falha no pagamento',
            'O pagamento não foi concluído. Por favor, tente novamente.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange.withOpacity(0.5),
            colorText: Colors.white,
          );
        }
      } else {
        resp = false;
        Get.snackbar(
          'Erro no pagamento',
          'Houve um problema com o pagamento. Tente novamente.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.5),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      resp = false;
      Get.snackbar(
        'Erro',
        'Falha ao processar o pagamento: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.5),
        colorText: Colors.white,
      );
    } finally {
      isLoading = false; // Pagamento finalizado
      isLoadingPayment.value = false;

      // Chama o paymentResponse novamente para exibir o resultado final
      paymentResponse(isLoading, resp, phoneController.text,
          selectedPassPrice.value!.price!);
    }
  }

  void usePass() {
    Get.bottomSheet(
      SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(
              20), // Adiciona padding em volta de todo o conteúdo
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Imagem do Passe
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  transportPass.value!.photoUrl ?? '',
                  height: 180, // Altura ajustada da imagem
                  width: double.infinity, // Largura para preencher o container
                  fit: BoxFit.cover, // Ajuste da imagem dentro do container
                ),
              ),
              const SizedBox(height: 20), // Espaçamento entre imagem e texto

              // Data de término
              Text(
                'Validade até: ${transportPass.value!.endAt != null ? DateFormat('dd/MM/yyyy').format(transportPass.value!.endAt!) : 'N/A'}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(
                  height: 20), // Espaçamento entre o texto e o QR code

              // QR Code
              QrImageView(
                data: transportPass.value!.userUuid ?? '',
                version: QrVersions.auto,
                embeddedImage: const AssetImage("assets/icon.jpg"),
                embeddedImageStyle: const QrEmbeddedImageStyle(
                  size: Size(
                      40, 40), // Ajuste do tamanho da imagem dentro do QR code
                ),
                size: 180, // Tamanho ajustado do QR code
                backgroundColor: Colors.white, // Cor de fundo do QR code
              ),
              const SizedBox(height: 20), // Espaçamento entre QR code e o botão

              // Botão para usar o passe
              ElevatedButton(
                onPressed: () {
                  // Implementação para usar o passe
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  backgroundColor: Colors.blueAccent,
                ),
                child: const Text(
                  'Usar Passe',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void passListCard() {
    Get.bottomSheet(
      SingleChildScrollView(
        child: Container(
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
          child: Obx(() {
            if (!buypass.value) {
              if (passListLoading.value) {
                return const Center(child: CircularProgressIndicator());
              } else if (passPriceList.isEmpty) {
                return const Center(child: Text('Nenhum dado encontrado.'));
              } else {
                return ListView.builder(
                  itemCount: passPriceList.length,
                  itemBuilder: (context, index) {
                    final pass = passPriceList[index];
                    return Card(
                      child: ListTile(
                        title: Text(pass.name ?? 'Sem nome'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Preço: ${pass.price ?? 'Indisponível'}'),
                            Text(
                                'Tipo: ${pass.passType == 1 ? 'Normal' : 'Especial'}'),
                          ],
                        ),
                        trailing: const Text('Comprar'),
                        onTap: () {
                          selectedPassPrice.value = pass;
                          buypass.value = true;
                        },
                      ),
                    );
                  },
                );
              }
            } else {
              return Column(
                children: [
                  Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Comprar passe",
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Tipo: ${selectedPassPrice.value!.passType == 1 ? 'Normal' : 'Especial'}",
                          style: const TextStyle(
                              fontSize: 18, color: Colors.black87),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Trajetória: ${selectedPassPrice.value!.name}",
                          style: const TextStyle(
                              fontSize: 18, color: Colors.black87),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Tarifa : ${selectedPassPrice.value!.price} mtn",
                          style: const TextStyle(
                              fontSize: 18, color: Colors.black87),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Insira o número de telefone do seu M-Pesa:',
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                        const SizedBox(height: 6),
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
                              prefixIcon: const Icon(Icons.phone,
                                  color: Colors.blueAccent),
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
                            onChanged: (value) {
                              if (RegExp(r'^(84|85)[0-9]{7}$')
                                  .hasMatch(value)) {
                                isValidPhone.value = true;
                              } else {
                                isValidPhone.value = false;
                              }
                            }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Obx(() {
                    bool isEnabled = isValidPhone.value;

                    return Center(
                      child: ElevatedButton(
                        onPressed: isEnabled && !isLoadingPayment.value
                            ? makePayment
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 15,
                          ),
                          backgroundColor:
                              isEnabled ? Colors.blueAccent : Colors.redAccent,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: isLoadingPayment.value
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
              );
            }
          }),
        ),
      ),
    );
  }
}

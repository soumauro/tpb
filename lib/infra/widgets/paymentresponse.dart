import 'package:flutter/material.dart';
import 'package:get/get.dart';

void paymentResponse(
    bool isLoading, bool response, String phoneNumber, double amount) {
  Get.bottomSheet(
    SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(Get.context!).size.height * 0.9,
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
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
        child: isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Processando Pagamento",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Você receberá uma notificação push no telefone:",
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    phoneNumber,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Quantia a pagar:",
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "$amount MTN",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Insira o seu PIN para confirmar a compra",
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  const CircularProgressIndicator(),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    response ? "Pagamento Bem-sucedido" : "Falha no Pagamento",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: response ? Colors.green : Colors.redAccent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Icon(
                    response ? Icons.check_circle_outline : Icons.error_outline,
                    size: 80,
                    color: response ? Colors.green : Colors.redAccent,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    response
                        ? "Obrigado pela sua compra!"
                        : "O pagamento não foi concluído. Tente novamente.",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () {
                      Get.back(); // Fecha o bottom sheet
                    },
                    icon: const Icon(Icons.close),
                    label: const Text("Fechar"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 15,
                      ),
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    ),
  );
}

import 'package:cobradortpb/presenter/passagemList/passlistpage.dart';
import 'package:cobradortpb/routers/router_imports.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ParagemPage extends StatelessWidget {
  static const router = '/qrcodeReader';
  const ParagemPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagamento de Passagens'),
      ),
      body: GetBuilder<ParagemController>(
        builder: (ctl) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),  // Adicionando padding para espaçamento
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  
                  // Título ou descrição informativa
                  const Text(
                    'Pague suas passagens de forma rápida e segura!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 10),

                  // Descrição adicional sobre o processo de leitura do QR Code
                  const Text(
                    'Clique em "Iniciar" para escanear o código QR presente no ônibus e faça o pagamento diretamente com o seu telefone.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Botão para iniciar o scanner de QR Code
                  ElevatedButton.icon(
                    onPressed: () {
                      ctl.showQRDialog(context);
                    },
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Iniciar Leitura do QR Code'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Indicador de carregamento enquanto o QR Code é lido (opcional)
                  if (ctl.isLoading.value)
                    const CircularProgressIndicator(),
                ElevatedButton.icon(onPressed: () {Get.toNamed(PassagemPagList.router);}, 
                icon: const Icon(Icons.lock_clock),
                    
                label: const Text('Histórico de Compras e Recibos'),
                style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

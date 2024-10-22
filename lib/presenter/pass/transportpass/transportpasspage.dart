import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../transportpass/transportcontroller.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart'; // Para formatação de datas

class TransportPassPage extends StatelessWidget {
  const TransportPassPage({super.key});

  static const router = '/transportpassPage';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Passe de Transporte'),
      ),
      body: SingleChildScrollView(
        child: GetBuilder<TransportPassController>(
          builder: (controller) {
            return Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.error.isNotEmpty) {
                return Center(
                  child: Text(
                    'Erro: ${controller.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              if (controller.transportPass.value == null) {
                // Nenhum documento encontrado
                return Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Aqui você pode adicionar a lógica de criação de passe.
                    },
                    child: const Text('Criar Passe de Transporte'),
                  ),
                );
              }

              // Exibe os detalhes do TransportPass
              final pass = controller.transportPass.value!;
              final endAtDate = pass
                  .endAt; //!= null ? DateTime.parse(pass.endAt!) : null; // Converte endAt para DateTime
              final currentDate = DateTime.now(); // Data atual
              final isExpired = endAtDate != null &&
                  currentDate
                      .isAfter(endAtDate); // Verifica se o passe está expirado

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        pass.passName ?? 'Passe de Transporte',
                        style: const TextStyle(
                            fontSize: 24.0, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Container para adicionar bordas arredondadas à imagem
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  12), // Borda arredondada
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey
                                      .withOpacity(0.5), // Sombra suave
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  12), // Mesma borda arredondada
                              child: Image.network(
                                pass.photoUrl ?? '',
                                width: 150,
                                height: 150,
                                fit: BoxFit
                                    .cover, // Mantém a imagem centralizada e cobre toda a área
                              ),
                            ),
                          ),
                          const SizedBox(
                              width:
                                  16), // Espaçamento horizontal entre a imagem e o QR code
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  12), // Borda arredondada para o Card
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(
                                  8), // Adiciona espaçamento interno ao Card
                              child: QrImageView(
                                data: '${pass.userUuid}',
                                version: QrVersions.auto,
                                size: 120, // Tamanho ajustado do QR code
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),
                      Text('Nome: ${pass.name}',
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 5),
                      Text('Disponível: ${pass.available}',
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 5),
                      Text('Tipo de Passe: ${pass.passType}',
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 5),
                      Text('Trajetória: ${pass.passName ?? '---'}',
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 10),
                      Text(
                        'Criado em: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(pass.createdAt!.toIso8601String()))}',
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      Text(
                        'Última Atualização: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(pass.lastUpdate!.toIso8601String()))}',
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      Text(
                        'Termina em: ${endAtDate != null ? DateFormat('dd/MM/yyyy').format(endAtDate) : 'N/A'}',
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),

                      // Verifica o estado do endAt para mostrar o botão correto
                      if (isExpired)
                        ElevatedButton(
                          onPressed: () {
                            controller.fetchPassPrice();
                            controller.passListCard();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                          child: const Text('Recarregar Passe'),
                        )
                      else
                        ElevatedButton(
                          onPressed: () {
                           controller.usePass();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text('Usar Passe'),
                        ),
                    ],
                  ),
                ),
              );
            });
          },
        ),
      ),
    );
  }
}

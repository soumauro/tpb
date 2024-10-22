import 'package:cobradortpb/presenter/passagemList/passlistcontroler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../infra/widgets/confirmticketcard.dart';

class PassagemPagList extends StatefulWidget {
  static const router = '/PassagemPagList';
  const PassagemPagList({super.key});

  @override
  State<PassagemPagList> createState() => _PassagensPageState();
}

class _PassagensPageState extends State<PassagemPagList> {
  final PassagemController controller = Get.put(PassagemController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Passagens'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Aciona a função para buscar as passagens do usuário
              controller.getPassagensUsuario();
            },
          ),
        ],
      ),
      body: Obx(() {
        // Verifica se está em estado de carregamento
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Se a lista de passagens está vazia, mostra uma mensagem
        if (controller.passagensList.isEmpty) {
          return const Center(child: Text('Nenhuma passagem encontrada.'));
        }

        // Caso contrário, exibe a lista de passagens
        return ListView.builder(
          itemCount: controller.passagensList.length,
          itemBuilder: (context, index) {
            var passagem = controller.passagensList[index];
            return Card(
              margin: const EdgeInsets.all(10),
              child: ListTile(
                title: Text(
                    'verificado: ${passagem.collectorCheck == 0 ? 'Não' : 'Sim'}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Preço: ${passagem.price} MZN'),
                    Text('Origem: ${passagem.startAt}'),
                    Text('Destino: ${passagem.endAt}'),
                    Text('Data: ${passagem.createdAt}'),
                    Text('Número de Pessoas: ${passagem.pessoas}'),
                  ],
                ),
                trailing: Icon(
                  passagem.collectorCheck == 1
                      ? Icons.check_circle
                      : Icons.cancel,
                  color:
                      passagem.collectorCheck == 1 ? Colors.green : Colors.red,
                ),
                onTap: () {
                  passagem.collectorCheck == 1
                      ? null
                      : confirmtiketCard(passagem);
                },
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Aciona a função para buscar as passagens do usuário
          controller.getPassagensUsuario();
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

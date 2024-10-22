import 'package:cobradortpb/presenter/bus/buspage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'rotacontroler.dart';


class RotaPage extends StatefulWidget {
   static const router = '/rotapage';
  const RotaPage({super.key});

  @override
  State<RotaPage> createState() => _RotaPageState();
}

class _RotaPageState extends State<RotaPage> {
  final RotaController rotaController = Get.put(RotaController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rotas Disponíveis'),
      ),
      body: Obx(() {
        if (rotaController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (rotaController.rotas.isEmpty) {
          return const Center(child: Text('Nenhuma rota disponível.'));
        }

        return ListView.builder(
          itemCount: rotaController.rotas.length,
          itemBuilder: (context, index) {
            final rota = rotaController.rotas[index];
            return Card(
              child: ListTile(
                title: Text('${rota.inicio} - ${rota.finalRota}'),
                subtitle: Text('Via: ${rota.via} | Total: ${rota.total}'),
                onTap: () {
                  // Ação ao clicar em uma rota
                  Get.toNamed(Buspage.router);
                },
              ),
            );
          },
        );
      }),
      
    );
  }
}

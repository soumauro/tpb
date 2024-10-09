import 'package:cobradortpb/routers/router_imports.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WorkdayPage extends StatelessWidget {
  static const router = '/qrcodeReader';
  const WorkdayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TURNOS'),
      ),
      body: GetBuilder<WorkdayController>(
        builder: (ctl) {
          // Verifique se `workday` está nulo
          if (ctl.workday == null) {
            // Exibe um indicador de carregamento enquanto os dados estão sendo buscados
            return const Center(child: CircularProgressIndicator());
          } else {
            // Quando os dados forem carregados, exiba-os
            return SingleChildScrollView(
              child: Column(
                children: [
                  
                  const Text('ho ho ho'),
                  Text('${ctl.workday}'), 
                  Text('${ctl.userPosition}'),
                  ElevatedButton(onPressed: (){ctl.showQRDialog(context);}, child: const Text('Iniciar'))
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
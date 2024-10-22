import 'package:cobradortpb/presenter/pass/creatingpass/makepass.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'transportpass/transportpasspage.dart';

class PasseMenu extends StatelessWidget {
  const PasseMenu({super.key});
  static const router = '/passMenu';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Card(child: ListTile(title: const Text("Criar passe de transport"),
          onTap: () {
            Get.toNamed(CreatingPassPage.router);
          },),),
          Card(child: ListTile(title: const Text("Meu passe"),
          onTap: () {
            Get.toNamed(TransportPassPage.router);
          },),),
        ],
      ),
    ) ;
  }
}
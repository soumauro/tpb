import 'package:cobradortpb/presenter/bus/buspage.dart';
import 'package:cobradortpb/presenter/rotas/rotaspage.dart';
import 'package:cobradortpb/routers/router_imports.dart';
import 'package:flutter/material.dart';

import '../pass/transportpass/transportpasspage.dart';

class NavigationBarPage extends StatefulWidget {
  const NavigationBarPage({super.key});
  static const router = '/inicio';

  @override
  State<NavigationBarPage> createState() => _NavigationBarPageState();
}

class _NavigationBarPageState extends State<NavigationBarPage> {
  // Mantém o índice da página atual
  int currentPageIndex = 0;
  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      const ParagemPage(),
      const RotaPage(),
      const TransportPassPage(),
      Container(
        child: Text('perfil'),
      ),
      Container(
        child: Text('perfil'),
      ),
      //const Qrscanner(),
      Container(
        child: Text('perfil'),
      ),
    ];

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.amber,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'turno',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.traffic),
            icon: Icon(Icons.traffic_outlined),
            label: 'autocarro',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.history),
            icon: Icon(Icons.history_edu_outlined),
            label: 'Passe',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.settings),
            icon: Icon(Icons.settings_outlined),
            label: 'Sobre Nós',
          ),
        ],
      ),
      // Usando IndexedStack para manter o estado das páginas
      body: IndexedStack(
        index: currentPageIndex,
        children: pages,
      ),
    );
  }
}

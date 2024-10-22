import 'package:cobradortpb/presenter/autetication/createuser.dart';
import 'package:cobradortpb/presenter/bus/busbindings.dart';
import 'package:cobradortpb/presenter/bus/buspage.dart';
import 'package:cobradortpb/presenter/navigator/navbar.dart';
import 'package:cobradortpb/presenter/navigator/navbarbindings.dart';
import 'package:cobradortpb/presenter/pass/creatingpass/makepass.dart';
import 'package:cobradortpb/presenter/pass/passmenu.dart';
import 'package:cobradortpb/presenter/pass/transportpass/transportpasspage.dart';
import 'package:cobradortpb/presenter/qrscanner/qrscanner.dart';
import 'package:cobradortpb/presenter/rotas/rotaspage.dart';
import 'package:get/route_manager.dart';
import '../presenter/pass/transportpass/tranasportpassbindigs.dart';
import '../presenter/passagemList/passlistpage.dart';
import './router_imports.dart';

class AppPages {
  const AppPages._();

  static final pages = <GetPage>[
    GetPage(
      name: CreateUserPage.router,
      page: () => const CreateUserPage(),
    ),
    GetPage(
        name: NavigationBarPage.router,
        page: () => const NavigationBarPage(),
        binding: Navbarbindings()),
    GetPage(
        name: TransportPassPage.router,
        page: () => const TransportPassPage(),
        binding: Tranasportpassbindigs()),
    GetPage(
      name: Qrscanner.router,
      page: () => const Qrscanner(),
    ),
    GetPage(
        name: ParagemPage.router,
        page: () => const ParagemPage(),
        binding: WorkdayBindings()),
    GetPage(
        name: Buspage.router,
        page: () => const Buspage(),
        binding: BusBindings()),
    GetPage(
        name: PasseMenu.router,
        page: () => const PasseMenu(),
    ),
    GetPage(
        name: CreatingPassPage.router,
        page: () => const CreatingPassPage(),
    ),
    GetPage(
        name: PassagemPagList.router,
        page: () => const PassagemPagList(),
    ),
    GetPage(
        name: RotaPage.router,
        page: () => const RotaPage(),
    ),
  ];
}

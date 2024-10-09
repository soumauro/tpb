
import 'package:cobradortpb/presenter/autetication/createuser.dart';
import 'package:cobradortpb/presenter/bus/busbindings.dart';
import 'package:cobradortpb/presenter/bus/buspage.dart';
import 'package:cobradortpb/presenter/navigator/navbar.dart';
import 'package:cobradortpb/presenter/navigator/navbarbindings.dart';
import 'package:cobradortpb/presenter/qrscanner/qrscanner.dart';
import 'package:get/route_manager.dart';
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
    binding: Navbarbindings()
   
    ),
    GetPage(
      name: Qrscanner.router,
      page: () => const Qrscanner(),
   
    ),
    GetPage(
      name: WorkdayPage.router,
      page: () => const WorkdayPage(),
      binding: WorkdayBindings()
   
    ),
    GetPage(
      name: Buspage.router,
      page: () => const Buspage(),
      binding: BusBindings()
   
    ),
      ];
}

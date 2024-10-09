import 'package:cobradortpb/presenter/bus/buscontroller.dart';
import 'package:get/get.dart';
import '../../routers/router_imports.dart';
class Navbarbindings implements Bindings {

   @override
  void dependencies() {
    Get.put(WorkdayController());
    Get.put(Buscontroller());
  }
  
}
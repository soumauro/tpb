import 'package:cobradortpb/presenter/bus/buscontroller.dart';
import 'package:cobradortpb/presenter/pass/transportpass/transportcontroller.dart';
import 'package:get/get.dart';
import '../../routers/router_imports.dart';

class Navbarbindings implements Bindings {
  @override
  void dependencies() {
    Get.put(ParagemController());
    Get.put(Buscontroller());
    Get.put(TransportPassController());

  }
}

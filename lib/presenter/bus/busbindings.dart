import 'package:cobradortpb/presenter/bus/buscontroller.dart';
import 'package:get/get.dart';

class BusBindings implements Bindings {

  @override
  void dependencies() {
    Get.put(Buscontroller());
  }
  
}
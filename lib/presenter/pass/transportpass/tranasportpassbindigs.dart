import 'package:cobradortpb/presenter/pass/transportpass/transportcontroller.dart';
import 'package:get/get.dart';

class Tranasportpassbindigs implements Bindings {
  @override
  void dependencies() {
    Get.put(TransportPassController());
  }
}

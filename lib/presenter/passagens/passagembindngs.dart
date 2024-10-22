import 'package:cobradortpb/presenter/passagens/passagemcontroller.dart';
import 'package:get/get.dart';

class WorkdayBindings implements Bindings {
  @override
  void dependencies() {
    Get.put(ParagemController());
  }
}

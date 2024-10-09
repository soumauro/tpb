import 'package:cobradortpb/presenter/workday/workdaycontroller.dart';
import 'package:get/get.dart';

class WorkdayBindings implements Bindings {

  @override
  void dependencies() {
    Get.put(WorkdayController());
  }
  
}
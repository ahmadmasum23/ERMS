import 'package:get/get.dart';

import '../modules/admin/bindings/admin_binding.dart';
import '../modules/admin/views/admin_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/operator/bindings/operator_binding.dart';
import '../modules/operator/views/operator_view.dart';
import '../modules/borrower/bindings/borrower_binding.dart';
import '../modules/borrower/views/borrower_view.dart';

part 'app_routes.dart';

class AppPages {  
  AppPages._();

  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: _Paths.OPERATOR,
      page: () => const OperatorView(),
      binding: OperatorBinding(),
    ),
    GetPage(
      name: _Paths.BORROWER,
      page: () => const BorrowerView(),
      binding: BorrowerBinding(),
    ),
    GetPage(
      name: _Paths.ADMIN,
      page: () => AdminView(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => LoginView(),
      binding: LoginBinding(),
    ),
  ];
}
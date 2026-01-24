part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const OPERATOR = _Paths.OPERATOR;
  static const BORROWER = _Paths.BORROWER;
  static const ADMIN = _Paths.ADMIN;
  static const LOGIN = _Paths.LOGIN;
  static const REGISTER = _Paths.REGISTER;
}

abstract class _Paths {
  _Paths._();
  static const OPERATOR = '/operator';
  static const BORROWER = '/borrower';
  static const ADMIN = '/admin';
  static const LOGIN = '/login';
  static const REGISTER = '/register';
}
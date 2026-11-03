import 'package:get/get.dart';
import 'Pages/index.dart';

class AppRoutes {
  static const String initial = '/';

  static final List<GetPage> routes = [
    GetPage(
      name: initial,
      page: () => const TheCommand(),
      transition: Transition.fadeIn,
    ),
  ];
}


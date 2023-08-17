import 'package:get_it/get_it.dart';

import 'package:injectable/injectable.dart';
import 'package:mobile_web/core/di/injectable.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: r'$initGetIt',
  generateForDir: ['lib'],
)
Future<void> configureDependencies() async {
  getIt.$initGetIt();
  await getIt.allReady();
}
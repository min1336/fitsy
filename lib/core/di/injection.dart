import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

final sl = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  // build_runner 실행 후 injection.config.dart가 자동 생성됨
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app.dart';
import 'app/config/global_bloc_observer.dart';
import 'core/api_client.dart';
import 'core/di/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = GlobalBlocObserver();
  await initDependencies();
  runApp(HrisApp(api: sl<ApiClient>()));
}

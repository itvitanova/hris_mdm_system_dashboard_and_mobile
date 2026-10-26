import 'package:flutter/material.dart';
import 'app.dart';
import 'core/api_client.dart';
import 'core/di/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(HrisApp(api: sl<ApiClient>()));
}

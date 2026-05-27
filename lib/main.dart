import 'package:flutter/material.dart';
import 'app.dart';
import 'data/seed.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SeedData.inicializarSeNecessario();
  runApp(const App());
}

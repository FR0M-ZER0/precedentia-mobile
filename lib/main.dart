import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/precedents/data/models/precedent_model.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(PrecedentModelAdapter());

  await Hive.openBox<PrecedentModel>('accessed_precedents');

  runApp(const App());
}

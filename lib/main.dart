import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/precedents/data/models/precedent_model.dart';
import 'features/petitions/data/models/petition_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(PrecedentModelAdapter());
  Hive.registerAdapter(PetitionModelAdapter());

  await Hive.openBox<PrecedentModel>('accessed_precedents');
  await Hive.openBox<PetitionModel>('petitions');

  await dotenv.load(fileName: ".env");

  runApp(const App());
}

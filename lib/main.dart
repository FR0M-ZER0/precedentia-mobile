import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/precedents/data/models/precedent_model.dart';
import 'features/precedents/data/datasource/precedents_local_datasource.dart'; 
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(PrecedentModelAdapter());
  
  // Abre a caixa
  final box = await Hive.openBox<PrecedentModel>('accessed_precedents');

  // ==========================================
  //  INiCIO DO TESTE
  // ==========================================
  final localDataSource = PrecedentsLocalDataSourceImpl(precedentBox: box);

  // 1. Criamos um precedente falso
  final mockPrecedent = PrecedentModel(
    id: '12345',
    titulo: 'Habeas Corpus Preventivo',
    ementa: 'Concessão de ordem para evitar prisão arbitrária...',
    dataAcesso: DateTime.now(),
  );

  // 2. Salvamos no Hive
  await localDataSource.saveAccessedPrecedent(mockPrecedent);
  print('✅ 1. Precedente salvo com sucesso no Hive!');

  // 3. Buscamos do Hive
  final historico = await localDataSource.getAccessedPrecedents();
  print('✅ 2. Histórico recuperado! Total de itens: ${historico.length}');
  print('✅ 3. Título do item mais recente: ${historico.first.titulo}');
  // ==========================================
  // FIM DO TESTE
  // ==========================================

  runApp(const App());
}
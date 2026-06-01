import 'dart:developer' as developer;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../domain/usecases/generate_petition_usecase.dart';

class GenerationPetitionFormController extends ChangeNotifier {
  final GeneratePetitionUseCase _generatePetitionUseCase;

  GenerationPetitionFormController(this._generatePetitionUseCase);

  final formKey = GlobalKey<FormState>();

  final descricaoAutorController = TextEditingController();
  final descricaoReuController = TextEditingController();
  final resumoController = TextEditingController();
  final pedidosInputController = TextEditingController();
  final valorCausaController = TextEditingController();
  final pedidosFocusNode = FocusNode();

  String tipoAcao = '';
  String? selectedTribunal;
  final List<PlatformFile> resumoArquivos = [];
  bool temTutelaUrgencia = false;
  bool temJusticaGratuita = false;
  final List<String> pedidos = [];

  void addPedido(String value) {
    if (value.trim().isNotEmpty && !pedidos.contains(value.trim())) {
      pedidos.add(value.trim());
      pedidosInputController.clear();
      notifyListeners();
    }
    pedidosFocusNode.requestFocus();
  }

  void removePedido(String pedido) {
    pedidos.remove(pedido);
    notifyListeners();
  }

  void toggleTutelaUrgencia(bool? value) {
    temTutelaUrgencia = value ?? false;
    notifyListeners();
  }

  void toggleJusticaGratuita(bool? value) {
    temJusticaGratuita = value ?? false;
    notifyListeners();
  }

  void setResumoArquivos(List<PlatformFile> files) {
    final pdfs = files.where((file) {
      return file.extension?.toLowerCase() == 'pdf';
    }).toList();

    for (final file in pdfs) {
      final alreadyExists = resumoArquivos.any(
        (item) => item.name == file.name,
      );

      if (!alreadyExists) {
        resumoArquivos.add(file);
      }
    }

    notifyListeners();
  }

  void removeResumoArquivo(PlatformFile file) {
    resumoArquivos.remove(file);
    notifyListeners();
  }

  void submitForm({
    required Function(String) onError,
    required Function(Future) onSuccess,
  }) {
    if (!formKey.currentState!.validate()) {
      onError('Preencha os campos obrigatórios.');
      return;
    }

    final resumoTexto = resumoController.text.trim();
    if (resumoTexto.isEmpty && resumoArquivos.isEmpty) {
      onError('Informe o resumo dos fatos ou anexe pelo menos um PDF.');
      return;
    }

    if (pedidos.isEmpty) {
      onError('Adicione pelo menos um pedido.');
      return;
    }

    final future = _generatePetitionUseCase(
      authorDescription: descricaoAutorController.text.trim(),
      defendantDescription: descricaoReuController.text.trim(),
      actionType: tipoAcao,
      tribunal: selectedTribunal!,
      factsSummary: resumoTexto,
      requests: pedidos,
      valueOfCause: valorCausaController.text.trim(),
      urgentRelief: temTutelaUrgencia,
      freeJustice: temJusticaGratuita,
      pdfs: resumoArquivos,
    );

    // Adicionar listener para printar o resultado
    future.then(
      (result) {
        developer.log(
          'Resultado da geração de petição: $result',
          name: 'GenerationPetitionFormController',
        );
      },
      onError: (error) {
        developer.log(
          'Erro na geração de petição: $error',
          error: error,
          name: 'GenerationPetitionFormController',
        );
      },
    );

    onSuccess(future);
  }

  void disposeControllers() {
    descricaoAutorController.dispose();
    descricaoReuController.dispose();
    resumoController.dispose();
    pedidosInputController.dispose();
    valorCausaController.dispose();
    pedidosFocusNode.dispose();
  }
}

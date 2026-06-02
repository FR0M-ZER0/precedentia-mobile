import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:precedentia_mobile/core/network/dio_client.dart';
import 'package:precedentia_mobile/core/storage/secure_storage_service.dart';
import 'package:precedentia_mobile/core/theme/app_colors.dart';
import 'package:precedentia_mobile/core/widgets/base_template.dart';
import 'package:precedentia_mobile/features/petitions/presentation/widgets/petition_switch_tile.dart';

import '../constants/petition_form_constants.dart';

class SendPetitionTextPage extends StatefulWidget {
  const SendPetitionTextPage({super.key});

  @override
  State<SendPetitionTextPage> createState() => _SendPetitionTextPageState();
}

class _SendPetitionTextPageState extends State<SendPetitionTextPage> {
  final _formKey = GlobalKey<FormState>();

  final _descricaoAutorController = TextEditingController();
  final _descricaoReuController = TextEditingController();
  final _resumoController = TextEditingController();
  final _pedidosInputController = TextEditingController();
  final _valorCausaController = TextEditingController();
  final _pedidosFocusNode = FocusNode();

  String _tipoAcao = '';
  String? _selectedTribunal;
  final List<PlatformFile> _resumoArquivos = [];
  bool _temTutelaUrgencia = false;
  bool _temJusticaGratuita = false;
  final List<String> _pedidos = [];

  bool _isLoading = false;

  @override
  void dispose() {
    _descricaoAutorController.dispose();
    _descricaoReuController.dispose();
    _resumoController.dispose();
    _pedidosInputController.dispose();
    _valorCausaController.dispose();
    _pedidosFocusNode.dispose();
    super.dispose();
  }

  void _addPedido(String value) {
    if (value.trim().isNotEmpty && !_pedidos.contains(value.trim())) {
      setState(() => _pedidos.add(value.trim()));
      _pedidosInputController.clear();
    }
    _pedidosFocusNode.requestFocus();
  }

  void _removePedido(String pedido) {
    setState(() => _pedidos.remove(pedido));
  }

  Future<void> _pickResumoArquivo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
      withData: true,
    );
    if (result != null) {
      setState(() {
        for (final file in result.files) {
          final alreadyExists = _resumoArquivos.any((f) => f.name == file.name);
          if (!alreadyExists) _resumoArquivos.add(file);
        }
      });
    }
  }

  Stream<Map<String, dynamic>> _buildSseStream({
    required int userId,
    required String type,
    required String facts,
    required String tribunal,
    required List<String> requests,
  }) async* {
    final uri = Uri.parse(
      '${DioClient.precedentiaApiUrl}/analysis/send-petition',
    );

    final body = jsonEncode({
      'user_id': userId,
      'type': type,
      'facts': facts,
      'tribunal': tribunal,
      'requests': requests,
    });

    developer.log(
      'Enviando para $uri\nBody: $body',
      name: 'SendPetitionTextPage',
    );

    final request = http.Request('POST', uri)
      ..headers['Content-Type'] = 'application/json'
      ..headers['Accept'] = 'text/event-stream'
      ..body = body;

    final response = await http.Client().send(request);

    if (response.statusCode != 200) {
      final errorBody = await response.stream.bytesToString();
      throw Exception('Erro ${response.statusCode}: $errorBody');
    }

    String? eventName;
    final dataBuffer = StringBuffer();

    await for (final line
        in response.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter())) {
      if (line.startsWith('event:')) {
        eventName = line.substring('event:'.length).trim();
      } else if (line.startsWith('data:')) {
        dataBuffer.write(line.substring('data:'.length).trim());
      } else if (line.isEmpty && dataBuffer.isNotEmpty) {
        final parsed =
            jsonDecode(dataBuffer.toString()) as Map<String, dynamic>;
        final event = {'event': eventName ?? 'message', ...parsed};

        developer.log(
          'Evento SSE [${eventName ?? 'message'}]: $event',
          name: 'SendPetitionTextPage',
        );

        yield event;

        eventName = null;
        dataBuffer.clear();
      }
    }
  }

  Future<void> _onPublish() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackError('Preencha os campos obrigatórios.');
      return;
    }
    if (_resumoController.text.trim().isEmpty && _resumoArquivos.isEmpty) {
      _showSnackError('Informe o resumo dos fatos ou anexe pelo menos um PDF.');
      return;
    }
    if (_pedidos.isEmpty) {
      _showSnackError('Adicione pelo menos um pedido.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = await SecureStorageService.readUserId();

      final controller = StreamController<Map<String, dynamic>>();

      _buildSseStream(
        userId: userId ?? 1,
        type: _tipoAcao,
        facts: _resumoController.text.trim(),
        tribunal: _selectedTribunal!,
        requests: _pedidos,
      ).listen(
        controller.add,
        onError: controller.addError,
        onDone: controller.close,
      );

      if (!mounted) return;

      context.push(
        '/selecao-precedente',
        extra: {
          'stream': controller.stream,
          'author_description': _descricaoAutorController.text.trim(),
          'defendant_description': _descricaoReuController.text.trim(),
          'action_type': _tipoAcao,
          'tribunal': _selectedTribunal!,
          'facts_summary': _resumoController.text.trim(),
          'requests': _pedidos,
          'value_of_cause': _valorCausaController.text.trim(),
          'urgent_relief': _temTutelaUrgencia,
          'free_justice': _temJusticaGratuita,
          'files': _resumoArquivos,
        },
      );
    } catch (e, st) {
      developer.log(
        'Erro ao enviar petição: $e',
        stackTrace: st,
        name: 'SendPetitionTextPage',
      );
      if (mounted) _showSnackError('Erro ao enviar petição: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.detailsColor),
    );
  }

  InputDecoration _customInputDecoration(String hint, TextTheme textTheme) {
    return InputDecoration(
      hintText: hint,
      hintStyle: textTheme.bodyMedium?.copyWith(
        color: AppColors.altDarkColor.withValues(alpha: 0.7),
      ),
      filled: true,
      fillColor: AppColors.altLightColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: AppColors.mainDarkColor,
          width: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BasePageTemplate(
      title: 'Geração de petição inicial',
      subtitle: 'Gere o arquivo PDF da petição inicial',
      onBackPress: () => context.pop(),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            TextFormField(
              controller: _descricaoAutorController,
              maxLines: 3,
              style: textTheme.bodyMedium,
              decoration: _customInputDecoration(
                'Descrição do autor',
                textTheme,
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Campo obrigatório'
                  : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _descricaoReuController,
              maxLines: 3,
              style: textTheme.bodyMedium,
              decoration: _customInputDecoration('Descrição do réu', textTheme),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Campo obrigatório'
                  : null,
            ),
            const SizedBox(height: 16),

            Autocomplete<String>(
              optionsBuilder: (value) => value.text.isEmpty
                  ? const Iterable<String>.empty()
                  : PetitionFormConstants.sugestoesAcao.where(
                      (acao) =>
                          acao.toLowerCase().contains(value.text.toLowerCase()),
                    ),
              onSelected: (selection) => setState(() => _tipoAcao = selection),
              fieldViewBuilder: (context, textController, focusNode, _) {
                return TextFormField(
                  controller: textController,
                  focusNode: focusNode,
                  style: textTheme.bodyMedium,
                  onChanged: (value) => _tipoAcao = value,
                  decoration: _customInputDecoration('Tipo de ação', textTheme),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Campo obrigatório'
                      : null,
                );
              },
            ),
            const SizedBox(height: 16),

            Autocomplete<String>(
              optionsBuilder: (value) => value.text.isEmpty
                  ? const Iterable<String>.empty()
                  : PetitionFormConstants.tribunais.where(
                      (t) => t.toLowerCase().contains(value.text.toLowerCase()),
                    ),
              onSelected: (selection) =>
                  setState(() => _selectedTribunal = selection),
              fieldViewBuilder: (context, textController, focusNode, _) {
                return TextFormField(
                  controller: textController,
                  focusNode: focusNode,
                  style: textTheme.bodyMedium,
                  onChanged: (value) => _selectedTribunal = value,
                  decoration: _customInputDecoration('Tribunal', textTheme),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Campo obrigatório'
                      : null,
                );
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _resumoController,
              maxLines: 5,
              style: textTheme.bodyMedium,
              decoration: _customInputDecoration('Resumo dos fatos', textTheme),
              validator: (value) =>
                  (_resumoArquivos.isNotEmpty ||
                      (value != null && value.trim().isNotEmpty))
                  ? null
                  : 'Informe o resumo ou anexe pelo menos um PDF',
            ),
            const SizedBox(height: 12),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _pickResumoArquivo,
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    label: Text(
                      _resumoArquivos.isEmpty
                          ? 'Anexar PDFs'
                          : 'Adicionar mais PDFs',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.mainDarkColor,
                      side: const BorderSide(color: AppColors.mainDarkColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                if (_resumoArquivos.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _resumoArquivos.map((file) {
                      return Chip(
                        avatar: const Icon(
                          Icons.picture_as_pdf_outlined,
                          size: 18,
                        ),
                        label: Text(file.name, overflow: TextOverflow.ellipsis),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () =>
                            setState(() => _resumoArquivos.remove(file)),
                        backgroundColor: AppColors.altLightColor,
                        side: const BorderSide(color: AppColors.mainDarkColor),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            InputDecorator(
              decoration: _customInputDecoration(
                'Pedidos',
                textTheme,
              ).copyWith(contentPadding: const EdgeInsets.all(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: _pedidos.map((pedido) {
                      return Chip(
                        label: Text(
                          pedido,
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.mainWhiteColor,
                          ),
                        ),
                        backgroundColor: AppColors.altDarkColor,
                        deleteIconColor: AppColors.mainWhiteColor,
                        onDeleted: () => _removePedido(pedido),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide.none,
                        ),
                      );
                    }).toList(),
                  ),
                  KeyboardListener(
                    focusNode: FocusNode(),
                    onKeyEvent: (event) {
                      if (event is KeyDownEvent &&
                          event.logicalKey == LogicalKeyboardKey.enter) {
                        _addPedido(_pedidosInputController.text);
                      }
                    },
                    child: TextField(
                      controller: _pedidosInputController,
                      focusNode: _pedidosFocusNode,
                      style: textTheme.bodyMedium,
                      decoration: InputDecoration(
                        hintText: _pedidos.isEmpty
                            ? 'Digite um pedido e aperte Enter'
                            : 'Adicionar outro...',
                        hintStyle: textTheme.bodyMedium?.copyWith(
                          color: AppColors.altDarkColor.withValues(alpha: 0.6),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.only(top: 8),
                      ),
                      onSubmitted: _addPedido,
                      textInputAction: TextInputAction.done,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _valorCausaController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: textTheme.bodyMedium,
              decoration: _customInputDecoration('Valor da causa', textTheme),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Campo obrigatório'
                  : null,
            ),
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.altLightColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  PetitionSwitchTile(
                    title: 'Tutela de urgência',
                    value: _temTutelaUrgencia,
                    onChanged: (v) => setState(() => _temTutelaUrgencia = v),
                    textTheme: textTheme,
                  ),
                  const Divider(height: 1),
                  PetitionSwitchTile(
                    title: 'Justiça gratuita',
                    value: _temJusticaGratuita,
                    onChanged: (v) => setState(() => _temJusticaGratuita = v),
                    textTheme: textTheme,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _onPublish,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.altLightColor,
                  foregroundColor: AppColors.mainDarkColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        'Gerar petição inicial',
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.mainDarkColor,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

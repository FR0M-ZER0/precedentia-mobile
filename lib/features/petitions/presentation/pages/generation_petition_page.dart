import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:precedentia_mobile/core/theme/app_colors.dart';
import 'package:precedentia_mobile/core/widgets/base_template.dart';
import 'package:precedentia_mobile/features/petitions/presentation/widgets/petition_switch_tile.dart';

import '../../data/datasource/petition_text_remote_datasource.dart';
import '../../data/repositories/petition_text_repository_impl.dart';
import '../../domain/usecases/send_petition_usecase.dart';
import '../constants/petition_form_constants.dart';
import '../controllers/generation_petition_controller.dart';

class SendPetitionTextPage extends StatefulWidget {
  const SendPetitionTextPage({super.key});

  @override
  State<SendPetitionTextPage> createState() => _SendPetitionTextPageState();
}

class _SendPetitionTextPageState extends State<SendPetitionTextPage> {
  late final GenerationPetitionController _controller;

  @override
  void initState() {
    super.initState();
    final useCase = SendPetitionTextUseCase(
      PetitionTextRepositoryImpl(PetitionRemoteDatasourceImpl()),
    );
    _controller = GenerationPetitionController(useCase);
  }

  @override
  void dispose() {
    _controller.disposeControllers();
    super.dispose();
  }

  void _onPublish() {
    _controller.submitForm(
      onError: (message) => _showSnackError(message),
      onSuccess: (future) =>
          context.push('/carregando-precedentes', extra: future),
    );
  }

  void _showSnackError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.detailsColor),
    );
  }

  Future<void> _pickResumoArquivo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
      withData: true,
    );

    if (result != null) {
      _controller.setResumoArquivos(result.files);
    }
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
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          return Form(
            key: _controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                TextFormField(
                  controller: _controller.descricaoAutorController,
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
                  controller: _controller.descricaoReuController,
                  maxLines: 3,
                  style: textTheme.bodyMedium,
                  decoration: _customInputDecoration(
                    'Descrição do réu',
                    textTheme,
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Campo obrigatório'
                      : null,
                ),
                const SizedBox(height: 16),

                Autocomplete<String>(
                  optionsBuilder: (value) => value.text.isEmpty
                      ? const Iterable<String>.empty()
                      : PetitionFormConstants.sugestoesAcao.where(
                          (acao) => acao.toLowerCase().contains(
                            value.text.toLowerCase(),
                          ),
                        ),
                  onSelected: (selection) => _controller.tipoAcao = selection,
                  fieldViewBuilder: (context, textController, focusNode, _) {
                    return TextFormField(
                      controller: textController,
                      focusNode: focusNode,
                      style: textTheme.bodyMedium,
                      onChanged: (value) => _controller.tipoAcao = value,
                      decoration: _customInputDecoration(
                        'Tipo de ação',
                        textTheme,
                      ),
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
                          (t) => t.toLowerCase().contains(
                            value.text.toLowerCase(),
                          ),
                        ),
                  onSelected: (selection) =>
                      _controller.selectedTribunal = selection,
                  fieldViewBuilder: (context, textController, focusNode, _) {
                    return TextFormField(
                      controller: textController,
                      focusNode: focusNode,
                      style: textTheme.bodyMedium,
                      onChanged: (value) =>
                          _controller.selectedTribunal = value,
                      decoration: _customInputDecoration('Tribunal', textTheme),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Campo obrigatório'
                          : null,
                    );
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _controller.resumoController,
                  maxLines: 5,
                  style: textTheme.bodyMedium,
                  decoration: _customInputDecoration(
                    'Resumo dos fatos',
                    textTheme,
                  ),
                  validator: (value) =>
                      (_controller.resumoArquivos.isNotEmpty ||
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
                          _controller.resumoArquivos.isEmpty
                              ? 'Anexar PDFs'
                              : 'Adicionar mais PDFs',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.mainDarkColor,
                          side: const BorderSide(
                            color: AppColors.mainDarkColor,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),

                    if (_controller.resumoArquivos.isNotEmpty) ...[
                      const SizedBox(height: 12),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _controller.resumoArquivos.map((file) {
                          return Chip(
                            avatar: const Icon(
                              Icons.picture_as_pdf_outlined,
                              size: 18,
                            ),
                            label: Text(
                              file.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            onDeleted: () =>
                                _controller.removeResumoArquivo(file),
                            backgroundColor: AppColors.altLightColor,
                            side: const BorderSide(
                              color: AppColors.mainDarkColor,
                            ),
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
                        children: _controller.pedidos.map((pedido) {
                          return Chip(
                            label: Text(
                              pedido,
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.mainWhiteColor,
                              ),
                            ),
                            backgroundColor: AppColors.altDarkColor,
                            deleteIconColor: AppColors.mainWhiteColor,
                            onDeleted: () => _controller.removePedido(pedido),
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
                            _controller.addPedido(
                              _controller.pedidosInputController.text,
                            );
                          }
                        },
                        child: TextField(
                          controller: _controller.pedidosInputController,
                          focusNode: _controller.pedidosFocusNode,
                          style: textTheme.bodyMedium,
                          decoration: InputDecoration(
                            hintText: _controller.pedidos.isEmpty
                                ? 'Digite um pedido e aperte Enter'
                                : 'Adicionar outro...',
                            hintStyle: textTheme.bodyMedium?.copyWith(
                              color: AppColors.altDarkColor.withValues(
                                alpha: 0.6,
                              ),
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.only(top: 8),
                          ),
                          onSubmitted: _controller.addPedido,
                          textInputAction: TextInputAction.done,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _controller.valorCausaController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: textTheme.bodyMedium,
                  decoration: _customInputDecoration(
                    'Valor da causa',
                    textTheme,
                  ),
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
                        value: _controller.temTutelaUrgencia,
                        onChanged: _controller.toggleTutelaUrgencia,
                        textTheme: textTheme,
                      ),

                      const Divider(height: 1),

                      PetitionSwitchTile(
                        title: 'Justiça gratuita',
                        value: _controller.temJusticaGratuita,
                        onChanged: _controller.toggleJusticaGratuita,
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
                    onPressed: _onPublish,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.altLightColor,
                      foregroundColor: AppColors.mainDarkColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
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
          );
        },
      ),
    );
  }
}

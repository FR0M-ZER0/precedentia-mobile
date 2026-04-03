import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/base_template.dart';

class SendPetitionTextPage extends StatefulWidget {
  const SendPetitionTextPage({super.key});

  @override
  State<SendPetitionTextPage> createState() => _SendPetitionTextPageState();
}

class _SendPetitionTextPageState extends State<SendPetitionTextPage> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _resumoController = TextEditingController();
  final TextEditingController _pedidosInputController = TextEditingController();
  
  String? _selectedTribunal;
  final List<String> _pedidos = []; // badges

  // mockando lista até definir tribunais
  final List<String> _tribunais = [
    'Supremo Tribunal Federal',
    'Superior Tribunal de Justiça',
    'TJSP (e afins)',
    'TRF1 ...',
    'TRT1 ...'
  ];

  // Mock tbm até definir
  final List<String> _sugestoesAcao = [
    'Ação de Indenização por Danos Morais',
    'Ação de Cobrança',
    'Ação de Despejo',
    'Ação de Alimentos',
    'Mandado de Segurança',
    'Habeas Corpus'
  ];

  // Add badge
  void _addPedido(String value) {
    if (value.trim().isNotEmpty && !_pedidos.contains(value.trim())) {
      setState(() {
        _pedidos.add(value.trim());
      });
      _pedidosInputController.clear();
    }
  }

  void _removePedido(String pedido) {
    setState(() {
      _pedidos.remove(pedido);
    });
  }

  void _submitForm() {
    final textTheme = Theme.of(context).textTheme;

    if (_formKey.currentState!.validate()) {
      if (_pedidos.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Adicione pelo menos um pedido.', style: textTheme.bodyMedium?.copyWith(color: AppColors.mainWhiteColor)),
            backgroundColor: AppColors.detailsColor,
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Petição enviada com sucesso!', style: textTheme.bodyMedium?.copyWith(color: AppColors.mainDarkColor)),
          backgroundColor: AppColors.accentColor,
          duration: const Duration(seconds: 2),
        ),
      );

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) context.push('/carregando-precedentes');
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Preencha os campos obrigatórios.', style: textTheme.bodyMedium?.copyWith(color: AppColors.mainWhiteColor)),
          backgroundColor: AppColors.detailsColor,
        ),
      );
    }
  }

  InputDecoration _customInputDecoration(String hint, TextTheme textTheme, {String? label}) {
    return InputDecoration(
      hintText: hint,
      labelText: label,
      hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.altDarkColor.withOpacity(0.7)),
      labelStyle: textTheme.bodyMedium?.copyWith(color: AppColors.mainDarkColor, fontWeight: FontWeight.w500),
      filled: true,
      fillColor: AppColors.altLightColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.mainDarkColor, width: 1.5),
      ),
    );
  }

  @override
  void dispose() {
    _resumoController.dispose();
    _pedidosInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BasePageTemplate(
      title: 'Envie dados da petição inicial',
      subtitle: 'Escreva os dados da petição inicial nos campos abaixo',
      onBackPress: () => context.pop(),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<String>.empty();
                }
                return _sugestoesAcao.where((acao) => acao
                    .toLowerCase()
                    .contains(textEditingValue.text.toLowerCase()));
              },
              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                return TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  style: textTheme.bodyMedium, 
                  decoration: _customInputDecoration('Tipo de ação', textTheme),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Campo obrigatório' : null,
                );
              },
              onSelected: (String selection) {
              },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              decoration: _customInputDecoration('Selecione um valor', textTheme, label: 'Tribunal'),
              style: textTheme.bodyMedium, 
              value: _selectedTribunal,
              items: _tribunais.map((String tribunal) {
                return DropdownMenuItem<String>(
                  value: tribunal,
                  child: Text(tribunal, style: textTheme.bodyMedium), 
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedTribunal = newValue;
                });
              },
              validator: (value) =>
                  value == null ? 'Selecione um tribunal' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _resumoController,
              maxLines: 6,
              style: textTheme.bodyMedium, 
              decoration: _customInputDecoration('Resumo dos fatos', textTheme),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),

            InputDecorator(
              decoration: _customInputDecoration('Pedidos', textTheme).copyWith(
                contentPadding: const EdgeInsets.all(12),
              ),
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
                          style: textTheme.bodySmall?.copyWith(color: AppColors.mainWhiteColor),
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
                  TextField(
                    controller: _pedidosInputController,
                    style: textTheme.bodyMedium, 
                    decoration: InputDecoration(
                      hintText: _pedidos.isEmpty ? 'Digite um pedido e aperte Enter' : 'Adicionar outro...',
                      hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.altDarkColor.withOpacity(0.6)), // Padroniza o hint
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.only(top: 8),
                    ),
                    onSubmitted: _addPedido,
                    textInputAction: TextInputAction.done,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.altLightColor, 
                  foregroundColor: AppColors.mainDarkColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Enviar',
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
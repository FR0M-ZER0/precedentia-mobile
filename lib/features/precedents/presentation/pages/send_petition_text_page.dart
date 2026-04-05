import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/base_template.dart';
import '../../data/datasource/petition_text_remote_datasource.dart';
import '../../data/repositories/petition_text_repository_impl.dart';
import '../../domain/usecases/send_petition_text_usecase.dart';

class SendPetitionTextPage extends StatefulWidget {
  const SendPetitionTextPage({super.key});

  @override
  State<SendPetitionTextPage> createState() => _SendPetitionTextPageState();
}

class _SendPetitionTextPageState extends State<SendPetitionTextPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _resumoController = TextEditingController();
  final TextEditingController _pedidosInputController = TextEditingController();

  String _tipoAcao = '';
  String? _selectedTribunal;
  final FocusNode _pedidosFocusNode = FocusNode();
  final List<String> _pedidos = [];

  late final SendPetitionTextUseCase _sendPetitionTextUseCase =
      SendPetitionTextUseCase(
        PetitionRepositoryImpl(PetitionRemoteDatasourceImpl()),
      );

  final List<String> _tribunais = [
    // Tribunais Superiores
    'STF - Supremo Tribunal Federal',
    'STJ - Superior Tribunal de Justiça',
    'TST - Tribunal Superior do Trabalho',
    'TSE - Tribunal Superior Eleitoral',
    'STM - Superior Tribunal Militar',
    // Tribunais Regionais Federais
    'TRF1', 'TRF2', 'TRF3', 'TRF4', 'TRF5',
    // Tribunais de Justiça
    'TJAC', 'TJAL', 'TJAP', 'TJAM', 'TJBA', 'TJCE', 'TJDFT', 'TJES',
    'TJGO', 'TJMA', 'TJMT', 'TJMS', 'TJMG', 'TJPA', 'TJPB', 'TJPR',
    'TJPE', 'TJPI', 'TJRJ', 'TJRN', 'TJRS', 'TJRO', 'TJRR', 'TJSC',
    'TJSP', 'TJSE', 'TJTO',
    // Tribunais Regionais do Trabalho
    'TRT1',  'TRT2',  'TRT3',  'TRT4',  'TRT5',  'TRT6',  'TRT7',
    'TRT8',  'TRT9',  'TRT10', 'TRT11', 'TRT12', 'TRT13', 'TRT14',
    'TRT15', 'TRT16', 'TRT17', 'TRT18', 'TRT19', 'TRT20', 'TRT21',
    'TRT22', 'TRT23', 'TRT24',
    // Tribunais Regionais Eleitorais
    'TREAC', 'TREAL', 'TREAP', 'TREAM', 'TREBA', 'TRECE', 'TREDF',
    'TREES', 'TREGO', 'TREMA', 'TREMT', 'TREMS', 'TREMG', 'TREPA',
    'TREPB', 'TREPR', 'TREPE', 'TREPI', 'TRERJ', 'TRERN', 'TRERS',
    'TRERO', 'TRERR', 'TRESC', 'TRESP', 'TRESE', 'TRETO',
    // Tribunais Militares Estaduais
    'TJMMG', 'TJMRS', 'TJMSP',
  ];

  final List<String> _sugestoesAcao = [
    // Cível
    'Ação de Indenização por Danos Morais',
    'Ação de Indenização por Danos Materiais',
    'Ação de Cobrança',
    'Ação de Despejo',
    'Ação de Reintegração de Posse',
    'Ação de Manutenção de Posse',
    'Ação Reivindicatória',
    'Ação de Usucapião',
    'Ação de Rescisão Contratual',
    'Ação Revisional de Contrato',
    'Ação de Consignação em Pagamento',
    'Ação de Prestação de Contas',
    'Ação Monitória',
    'Ação de Execução de Título Extrajudicial',
    // Família e Sucessões
    'Ação de Alimentos',
    'Ação de Divórcio',
    'Ação de Guarda e Visitação',
    'Ação de Reconhecimento de União Estável',
    'Ação de Inventário e Partilha',
    'Ação de Investigação de Paternidade',
    'Ação de Destituição do Poder Familiar',
    // Constitucional / Remédios
    'Mandado de Segurança',
    'Mandado de Injunção',
    'Habeas Corpus',
    'Habeas Data',
    'Ação Popular',
    'Ação Civil Pública',
    // Tributário
    'Ação Anulatória de Débito Fiscal',
    'Ação de Repetição de Indébito Tributário',
    'Embargos à Execução Fiscal',
    'Mandado de Segurança Tributário',
    // Trabalhista
    'Reclamação Trabalhista',
    'Ação de Reconhecimento de Vínculo Empregatício',
    'Ação de Horas Extras',
    'Ação de Rescisão Indireta',
    // Previdenciário
    'Ação de Concessão de Aposentadoria',
    'Ação de Concessão de Auxílio-Doença',
    'Ação Revisional de Benefício Previdenciário',
    'Ação de Concessão de BPC/LOAS',
    // Consumidor
    'Ação de Obrigação de Fazer contra Plano de Saúde',
    'Ação Indenizatória por Fraude Bancária',
    'Ação de Revisão de Contrato Bancário',
    // Administrativo
    'Ação de Improbidade Administrativa',
    'Ação Indenizatória contra o Estado',
    'Mandado de Segurança contra ato administrativo',
  ];

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

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      _showSnackError('Preencha os campos obrigatórios.');
      return;
    }

    if (_pedidos.isEmpty) {
      _showSnackError('Adicione pelo menos um pedido.');
      return;
    }

    final future = _sendPetitionTextUseCase(
      type: _tipoAcao,
      facts: _resumoController.text,
      tribunal: _selectedTribunal!,
      requests: _pedidos,
    );

    if (!mounted) return;
    context.push('/carregando-precedentes', extra: future);
  }

  void _showSnackError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.detailsColor),
    );
  }

  InputDecoration _customInputDecoration(
    String hint,
    TextTheme textTheme, {
    String? label,
  }) {
    return InputDecoration(
      hintText: hint,
      labelText: label,
      hintStyle: textTheme.bodyMedium?.copyWith(
        color: AppColors.altDarkColor.withValues(alpha: 0.7),
      ),
      labelStyle: textTheme.bodyMedium?.copyWith(
        color: AppColors.mainDarkColor,
        fontWeight: FontWeight.w500,
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
  void dispose() {
    _resumoController.dispose();
    _pedidosInputController.dispose();
    _pedidosFocusNode.dispose();
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
                return _sugestoesAcao.where(
                  (acao) => acao.toLowerCase().contains(
                    textEditingValue.text.toLowerCase(),
                  ),
                );
              },
              onSelected: (String selection) {
                setState(() => _tipoAcao = selection);
              },
              fieldViewBuilder:
                  (context, controller, focusNode, onFieldSubmitted) {
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      style: textTheme.bodyMedium,
                      onChanged: (value) => _tipoAcao = value,
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
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<String>.empty();
                }
                return _tribunais.where(
                  (tribunal) => tribunal.toLowerCase().contains(
                    textEditingValue.text.toLowerCase(),
                  ),
                );
              },
              onSelected: (String selection) {
                setState(() => _selectedTribunal = selection);
              },
              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                return TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  style: textTheme.bodyMedium,
                  onChanged: (value) => _selectedTribunal = value,
                  decoration: _customInputDecoration(
                    'Tribunal',
                    textTheme,
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Campo obrigatório'
                      : null,
                );
              },
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
                    onKeyEvent: (KeyEvent event) {
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

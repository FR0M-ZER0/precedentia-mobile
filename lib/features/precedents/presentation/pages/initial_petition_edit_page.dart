import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/base_template.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class InitialPetitionEditPage extends StatefulWidget {
  const InitialPetitionEditPage({super.key});

  @override
  State<InitialPetitionEditPage> createState() =>
      _InitialPetitionEditPageState();
}

class _InitialPetitionEditPageState extends State<InitialPetitionEditPage> {
  late TextEditingController _mainController;
  late TextEditingController _promptController;

  static const String _mockPetitionData = '''# Petição Inicial

## Partes Envolvidas

**Autor:** João Góes  
**Réu:** Empresa Batman Ltda.

---

## Dos Fatos

O autor, na qualidade de consumidor, adquiriu produto fabricado pelo réu no dia 15 de janeiro de 2024, pagando o valor de R\$ 1.500,00.

O produto apresentou defeito grave em sua estrutura, inviabilizando seu uso conforme o propósito esperado. Apesar de todas as tentativas de resolução amigável com a empresa ré, a mesma recusou-se a fazer a substituição ou devolução do valor.

---

## Fundamento Legal

O caso se enquadra nos termos do **Código de Defesa do Consumidor (Lei 8.078/1990)**, especificamente:

- Artigo 6º - Direitos básicos do consumidor
- Artigo 18 - Obrigação de reparação do vício

---

## Pedidos

Pelo exposto, requer-se:

1. Condenação do réu ao pagamento de indenização por danos morais no valor de R\$ 5.000,00
2. Condenação ao pagamento de danos materiais referentes ao produto defeituoso
3. Condenação ao pagamento de custas processuais

---

## Valor da Causa

R\$ 6.500,00
''';

  @override
  void initState() {
    super.initState();
    _mainController = TextEditingController(text: _mockPetitionData);
    _promptController = TextEditingController();
  }

  void _wrapSelection(String left, String right) {
    final text = _mainController.text;
    final sel = _mainController.selection;
    final start = sel.start >= 0 ? sel.start : text.length;
    final end = sel.end >= 0 ? sel.end : text.length;
    final selected = text.substring(start, end);
    final newText = text.replaceRange(start, end, '$left$selected$right');
    _mainController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + left.length + selected.length + right.length),
    );
  }

  void _prefixLines(String prefix) {
    final text = _mainController.text;
    final sel = _mainController.selection;
    final start = sel.start >= 0 ? sel.start : 0;
    final end = sel.end >= 0 ? sel.end : 0;
    final before = text.substring(0, start);
    final middle = text.substring(start, end);
    final after = text.substring(end);
    final transformed = middle
        .split('\n')
        .map((line) => line.trim().isEmpty ? line : '$prefix$line')
        .join('\n');
    final newText = before + transformed + after;
    _mainController.value = TextEditingValue(
      text: newText,
      selection: TextSelection(baseOffset: start, extentOffset: start + transformed.length),
    );
  }

  Future<void> _insertLink() async {
    final sel = _mainController.selection;
    final selected = sel.isValid ? _mainController.text.substring(sel.start, sel.end) : '';
    final url = await showDialog<String>(
      context: context,
      builder: (c) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Inserir link'),
          content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'https://')),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancelar')),
            TextButton(onPressed: () => Navigator.pop(c, controller.text.trim()), child: const Text('OK')),
          ],
        );
      },
    );
    if (url != null && url.isNotEmpty) {
      final text = selected.isNotEmpty ? '[$selected]($url)' : '[]( $url )';
      final start = sel.start >= 0 ? sel.start : _mainController.text.length;
      final end = sel.end >= 0 ? sel.end : start;
      final newText = _mainController.text.replaceRange(start, end, text);
      _mainController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: start + text.length),
      );
    }
  }

  Future<void> _insertImage() async {
    final url = await showDialog<String>(
      context: context,
      builder: (c) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Inserir imagem (URL)'),
          content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'https://')),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancelar')),
            TextButton(onPressed: () => Navigator.pop(c, controller.text.trim()), child: const Text('OK')),
          ],
        );
      },
    );
    if (url != null && url.isNotEmpty) {
      final markdown = '![]( $url )';
      final sel = _mainController.selection;
      final start = sel.start >= 0 ? sel.start : _mainController.text.length;
      final end = sel.end >= 0 ? sel.end : start;
      final newText = _mainController.text.replaceRange(start, end, markdown);
      _mainController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: start + markdown.length),
      );
    }
  }

  Future<void> _generatePdfAndShare() async {
    final doc = pw.Document();
    final lines = _mainController.text.split('\n');

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return [
            for (final line in lines)
              if (line.startsWith('# '))
                pw.Header(level: 0, text: line.replaceFirst('# ', ''))
              else if (line.startsWith('## '))
                pw.Header(level: 1, text: line.replaceFirst('## ', ''))
              else if (line.startsWith('### '))
                pw.Header(level: 2, text: line.replaceFirst('### ', ''))
              else if (line.startsWith('- '))
                pw.Bullet(text: line.replaceFirst('- ', ''))
              else if (RegExp(r'^\d+\. ').hasMatch(line))
                pw.Text(line)
              else
                pw.Paragraph(text: line),
          ];
        },
      ),
    );

    final bytes = await doc.save();
    await Printing.sharePdf(bytes: bytes, filename: 'peticao_inicial.pdf');
  }

  @override
  void dispose() {
    _mainController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BasePageTemplate(
      title: 'Geração de petição inicial',
      subtitle: 'Edite o arquivo ou faça o download',
      onBackPress: () => context.pop(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 360,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.altLightColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: 'H1',
                          onPressed: () => _prefixLines('# '),
                          icon: const Text('H1', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        IconButton(
                          tooltip: 'Bold',
                          onPressed: () => _wrapSelection('**', '**'),
                          icon: const Icon(Icons.format_bold),
                        ),
                        IconButton(
                          tooltip: 'Italic',
                          onPressed: () => _wrapSelection('_', '_'),
                          icon: const Icon(Icons.format_italic),
                        ),
                        IconButton(
                          tooltip: 'Underline',
                          onPressed: () => _wrapSelection('<u>', '</u>'),
                          icon: const Icon(Icons.format_underlined),
                        ),
                        IconButton(
                          tooltip: 'Bulleted list',
                          onPressed: () => _prefixLines('- '),
                          icon: const Icon(Icons.format_list_bulleted),
                        ),
                        IconButton(
                          tooltip: 'Numbered list',
                          onPressed: () => _prefixLines('1. '),
                          icon: const Icon(Icons.format_list_numbered),
                        ),
                        IconButton(
                          tooltip: 'Link',
                          onPressed: _insertLink,
                          icon: const Icon(Icons.link),
                        ),
                        IconButton(
                          tooltip: 'Image',
                          onPressed: _insertImage,
                          icon: const Icon(Icons.image),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: TextField(
                        controller: _mainController,
                        maxLines: null,
                        expands: true,
                        keyboardType: TextInputType.multiline,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.mainDarkColor,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Escreva ou cole a petição em markdown aqui...',
                          hintStyle: textTheme.bodyMedium?.copyWith(
                            color: AppColors.altDarkColor.withValues(alpha: 0.6),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFDDE3EE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 72, 12),
                  child: TextField(
                    controller: _promptController,
                    maxLines: null,
                    expands: false,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.mainDarkColor,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Digite as alterações',
                      hintStyle: textTheme.bodyMedium?.copyWith(
                        color: AppColors.altDarkColor.withValues(alpha: 0.6),
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: IconButton(
                    onPressed: () {
                      if (_promptController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Digite um prompt antes de enviar'),
                            backgroundColor: AppColors.detailsColor,
                          ),
                        );
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Prompt enviado (mock)')),
                      );
                    },
                    icon: const Icon(Icons.send),
                    color: AppColors.altDarkColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              onPressed: _generatePdfAndShare,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: AppColors.mainDarkColor,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.download),
              label: Text(
                'Baixar',
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.mainDarkColor,
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

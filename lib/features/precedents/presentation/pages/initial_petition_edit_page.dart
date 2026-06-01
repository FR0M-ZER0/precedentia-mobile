import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/base_template.dart';

class InitialPetitionEditPage extends StatefulWidget {
  const InitialPetitionEditPage({super.key});

  @override
  State<InitialPetitionEditPage> createState() =>
      _InitialPetitionEditPageState();
}

class _InitialPetitionEditPageState extends State<InitialPetitionEditPage> {
  late EditorState _editorState;
  late TextEditingController _promptController;

  static const String _mockPetitionMarkdown = '''# Petição Inicial

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
    _promptController = TextEditingController();
    _editorState = EditorState(
      document: markdownToDocument(_mockPetitionMarkdown),
    );
  }

  @override
  void dispose() {
    _editorState.dispose();
    _promptController.dispose();
    super.dispose();
  }

  /// Markdown puro atual — use para enviar ao backend
  String get _currentMarkdown => documentToMarkdown(_editorState.document);

  // ── Helpers de formatação inline ──────────────────────────────────

  /// Aplica/remove um atributo inline na seleção atual (bold, italic, underline…)
  void _toggleInlineFormat(String attribute) {
    final selection = _editorState.selection;
    if (selection == null || selection.isCollapsed) return;

    // Verifica se todos os nós selecionados já têm o atributo
    final nodes = _editorState.getNodesInSelection(selection);
    final allHave = nodes.every((node) {
      final delta = node.delta;
      if (delta == null) return false;
      return delta.everyAttributes((attrs) => attrs[attribute] == true);
    });

    final transaction = _editorState.transaction;
    transaction.formatText(
      nodes.first,
      selection.startIndex,
      selection.length,
      {attribute: !allHave},
    );
    _editorState.apply(transaction);
  }

  /// Muda o tipo do bloco onde o cursor está (heading, bulletedList, etc.)
  void _changeBlockType(String type, {Map<String, dynamic>? attributes}) {
    final selection = _editorState.selection;
    if (selection == null) return;
    final node = _editorState.getNodeAtPath(selection.start.path);
    if (node == null) return;

    final transaction = _editorState.transaction;
    transaction.updateNode(node, {'type': type, ...?attributes});
    _editorState.apply(transaction);
  }

  Future<void> _insertLink() async {
    final selection = _editorState.selection;
    if (selection == null || selection.isCollapsed) return;

    final url = await showDialog<String>(
      context: context,
      builder: (c) {
        final ctrl = TextEditingController();
        return AlertDialog(
          title: const Text('Inserir link'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(hintText: 'https://'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(c, ctrl.text.trim()),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (url != null && url.isNotEmpty) {
      final nodes = _editorState.getNodesInSelection(selection);
      if (nodes.isEmpty) return;
      final transaction = _editorState.transaction;
      transaction.formatText(
        nodes.first,
        selection.startIndex,
        selection.length,
        {AppFlowyRichTextKeys.href: url},
      );
      _editorState.apply(transaction);
    }
  }

  Future<void> _generatePdfAndShare() async {
    final doc = pw.Document();
    final lines = _currentMarkdown.split('\n');

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
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
        ],
      ),
    );

    final bytes = await doc.save();
    await Printing.sharePdf(bytes: bytes, filename: 'peticao_inicial.pdf');
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final editorStyle = EditorStyle.desktop(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      textStyleConfiguration: TextStyleConfiguration(
        text: textTheme.bodyMedium!.copyWith(color: AppColors.mainDarkColor),
        bold: const TextStyle(fontWeight: FontWeight.bold),
        italic: const TextStyle(fontStyle: FontStyle.italic),
        underline: const TextStyle(decoration: TextDecoration.underline),
        href: const TextStyle(
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
        code: TextStyle(
          fontFamily: 'monospace',
          backgroundColor: Colors.grey.shade200,
        ),
      ),
    );

    return BasePageTemplate(
      title: 'Geração de petição inicial',
      subtitle: 'Edite o arquivo ou faça o download',
      onBackPress: () => context.pop(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // ── Editor WYSIWYG ────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 420,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.altLightColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // Toolbar
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        // Headings
                        PopupMenuButton<int>(
                          tooltip: 'Título',
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            child: Text(
                              'H',
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.mainDarkColor,
                              ),
                            ),
                          ),
                          onSelected: (level) {
                            final sel = _editorState.selection;
                            if (sel == null) return;
                            final node = _editorState.getNodeAtPath(
                              sel.start.path,
                            );
                            if (node == null) return;
                            final tx = _editorState.transaction;
                            tx.updateNode(node, {'level': level});
                            _editorState.apply(tx);
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 1, child: Text('H1')),
                            PopupMenuItem(value: 2, child: Text('H2')),
                            PopupMenuItem(value: 3, child: Text('H3')),
                          ],
                        ),
                        // Bold
                        IconButton(
                          tooltip: 'Negrito',
                          onPressed: () =>
                              _toggleInlineFormat(AppFlowyRichTextKeys.bold),
                          icon: const Icon(Icons.format_bold),
                        ),
                        // Italic
                        IconButton(
                          tooltip: 'Itálico',
                          onPressed: () =>
                              _toggleInlineFormat(AppFlowyRichTextKeys.italic),
                          icon: const Icon(Icons.format_italic),
                        ),
                        // Underline
                        IconButton(
                          tooltip: 'Sublinhado',
                          onPressed: () => _toggleInlineFormat(
                            AppFlowyRichTextKeys.underline,
                          ),
                          icon: const Icon(Icons.format_underlined),
                        ),
                        // Bulleted list
                        IconButton(
                          tooltip: 'Lista com marcadores',
                          onPressed: () =>
                              _changeBlockType(BulletedListBlockKeys.type),
                          icon: const Icon(Icons.format_list_bulleted),
                        ),
                        // Numbered list
                        IconButton(
                          tooltip: 'Lista numerada',
                          onPressed: () =>
                              _changeBlockType(NumberedListBlockKeys.type),
                          icon: const Icon(Icons.format_list_numbered),
                        ),
                        // Link
                        IconButton(
                          tooltip: 'Link',
                          onPressed: _insertLink,
                          icon: const Icon(Icons.link),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  // Editor ocupa o restante
                  Expanded(
                    child: AppFlowyEditor(
                      editorState: _editorState,
                      editorStyle: editorStyle,
                      blockComponentBuilders: standardBlockComponentBuilderMap,
                      commandShortcutEvents: standardCommandShortcutEvents,
                      characterShortcutEvents: standardCharacterShortcutEvents,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── Campo de prompt ───────────────────────────────────────
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

                      // Markdown puro pronto para enviar ao backend:
                      final markdownAtual = _currentMarkdown;
                      debugPrint('Markdown:\n$markdownAtual');

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

          // ── Botão de download ─────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _generatePdfAndShare,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.altLightColor,
                foregroundColor: AppColors.mainDarkColor,
                elevation: 0,
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

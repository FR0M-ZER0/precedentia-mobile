import 'dart:convert';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:precedentia_mobile/core/network/dio_client.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/base_template.dart';

class InitialSentenceEditPage extends StatefulWidget {
  final String content;
  final int sentenceId;

  const InitialSentenceEditPage({
    super.key,
    required this.content,
    required this.sentenceId,
  });

  @override
  State<InitialSentenceEditPage> createState() =>
      _InitialSentenceEditPageState();
}

class _InitialSentenceEditPageState extends State<InitialSentenceEditPage> {
  late EditorState _editorState;
  late TextEditingController _promptController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _promptController = TextEditingController();
    _editorState = EditorState(document: markdownToDocument(widget.content));
  }

  @override
  void dispose() {
    _editorState.dispose();
    _promptController.dispose();
    super.dispose();
  }

  String get _currentMarkdown => documentToMarkdown(_editorState.document);

  void _toggleInlineFormat(String attribute) {
    final selection = _editorState.selection;
    if (selection == null || selection.isCollapsed) return;

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

  Future<void> _submitEdit() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite um prompt antes de enviar'),
          backgroundColor: AppColors.detailsColor,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final baseUrl = DioClient.instance.options.baseUrl.replaceAll(
        RegExp(r'/$'),
        '',
      );
      final dioHeaders = DioClient.instance.options.headers;
      final response = await http.post(
        Uri.parse('$baseUrl/sentences/edit'),
        headers: {
          'Content-Type': 'application/json',
          if (dioHeaders['Authorization'] != null)
            'Authorization': dioHeaders['Authorization'] as String,
        },
        body: jsonEncode({
          'sentence_id': widget.sentenceId,
          'content': _currentMarkdown,
          'change': prompt,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final updatedContent = data['content'] as String;

        setState(() {
          _editorState.dispose();
          _editorState = EditorState(
            document: markdownToDocument(updatedContent),
          );
          _promptController.clear();
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sentença atualizada com sucesso')),
          );
        }
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Erro desconhecido');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao editar sentença: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _generatePdfAndShare() async {
    final doc = pw.Document();
    final font = await PdfGoogleFonts.nunitoRegular();
    final fontBold = await PdfGoogleFonts.nunitoBold();
    final fontItalic = await PdfGoogleFonts.nunitoItalic();

    final lines = _currentMarkdown.split('\n');

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 64, vertical: 72),
        theme: pw.ThemeData.withFont(
          base: font,
          bold: fontBold,
          italic: fontItalic,
        ),
        build: (context) {
          final widgets = <pw.Widget>[];

          for (final line in lines) {
            if (line.trim().isEmpty) {
              widgets.add(pw.SizedBox(height: 8));
            } else if (line.startsWith('### ')) {
              widgets.add(
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 12, bottom: 4),
                  child: pw.Text(
                    line.replaceFirst('### ', ''),
                    style: pw.TextStyle(
                      font: fontBold,
                      fontSize: 13,
                      color: PdfColors.grey800,
                    ),
                  ),
                ),
              );
            } else if (line.startsWith('## ')) {
              widgets.add(
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 16, bottom: 6),
                  child: pw.Text(
                    line.replaceFirst('## ', ''),
                    style: pw.TextStyle(
                      font: fontBold,
                      fontSize: 15,
                      color: PdfColors.grey900,
                    ),
                  ),
                ),
              );
            } else if (line.startsWith('# ')) {
              widgets.add(
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 20, bottom: 8),
                  child: pw.Text(
                    line.replaceFirst('# ', ''),
                    style: pw.TextStyle(
                      font: fontBold,
                      fontSize: 18,
                      color: PdfColors.black,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              );
            } else if (line.startsWith('- ') || line.startsWith('* ')) {
              widgets.add(
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 16, bottom: 4),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '• ',
                        style: pw.TextStyle(font: font, fontSize: 11),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          line.replaceFirst(RegExp(r'^[-*] '), ''),
                          style: pw.TextStyle(
                            font: font,
                            fontSize: 11,
                            lineSpacing: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else if (RegExp(r'^\d+\. ').hasMatch(line)) {
              widgets.add(
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 16, bottom: 4),
                  child: pw.Text(
                    line,
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 11,
                      lineSpacing: 2,
                    ),
                  ),
                ),
              );
            } else {
              widgets.add(
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 6),
                  child: pw.Text(
                    line,
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 11,
                      lineSpacing: 2,
                    ),
                    textAlign: pw.TextAlign.justify,
                  ),
                ),
              );
            }
          }

          return widgets;
        },
      ),
    );

    final bytes = await doc.save();
    await Printing.sharePdf(bytes: bytes, filename: 'sentenca.pdf');
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
      title: 'Geração de sentença',
      subtitle: 'Edite o arquivo ou faça o download',
      onBackPress: () => context.pop(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

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
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
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
                        IconButton(
                          tooltip: 'Negrito',
                          onPressed: () =>
                              _toggleInlineFormat(AppFlowyRichTextKeys.bold),
                          icon: const Icon(Icons.format_bold),
                        ),
                        IconButton(
                          tooltip: 'Itálico',
                          onPressed: () =>
                              _toggleInlineFormat(AppFlowyRichTextKeys.italic),
                          icon: const Icon(Icons.format_italic),
                        ),
                        IconButton(
                          tooltip: 'Sublinhado',
                          onPressed: () => _toggleInlineFormat(
                            AppFlowyRichTextKeys.underline,
                          ),
                          icon: const Icon(Icons.format_underlined),
                        ),
                        IconButton(
                          tooltip: 'Lista com marcadores',
                          onPressed: () =>
                              _changeBlockType(BulletedListBlockKeys.type),
                          icon: const Icon(Icons.format_list_bulleted),
                        ),
                        IconButton(
                          tooltip: 'Lista numerada',
                          onPressed: () =>
                              _changeBlockType(NumberedListBlockKeys.type),
                          icon: const Icon(Icons.format_list_numbered),
                        ),
                        IconButton(
                          tooltip: 'Link',
                          onPressed: _insertLink,
                          icon: const Icon(Icons.link),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1),

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
                    enabled: !_isLoading,
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
                  child: _isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          onPressed: _submitEdit,
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
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _generatePdfAndShare,
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

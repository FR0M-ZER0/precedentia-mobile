import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/base_template.dart';
import 'package:precedentia_mobile/features/precedents/presentation/pages/precedents_results_page.dart'
    show PrecedentResultCard;

class AnalysisProcessPage extends StatefulWidget {
  final Stream<Map<String, dynamic>> stream;

  const AnalysisProcessPage({super.key, required this.stream});

  @override
  State<AnalysisProcessPage> createState() => _AnalysisProcessPageState();
}

class _AnalysisProcessPageState extends State<AnalysisProcessPage> {
  final List<Map<String, dynamic>> _precedents = [];
  Map<String, dynamic>? _processData;
  bool _isDone = false;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _listenToStream();
  }

  void _listenToStream() {
    _subscription = widget.stream.listen(
      (event) {
        final eventName = event['event'] as String?;

        if (eventName == 'process_data') {
          setState(() => _processData = event);
        } else if (eventName == 'precedent') {
          setState(() => _precedents.add(event));
        } else if (eventName == 'done' || eventName == 'error') {
          setState(() => _isDone = true);
          if (eventName == 'error' && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(event['message'] ?? 'Erro desconhecido')),
            );
          }
        }
      },
      onError: (_) {
        if (mounted) setState(() => _isDone = true);
      },
      onDone: () {
        if (mounted) setState(() => _isDone = true);
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  String _getProbabilidade(String applicability) {
    switch (applicability) {
      case 'applicable':
        return 'Aplicável';
      case 'possible_applicability':
        return 'Possivelmente aplicável';
      case 'low_applicability':
        return 'Pouco aplicável';
      default:
        return 'Não aplicável';
    }
  }

  Color _getProbabilidadeColor(String applicability) {
    switch (applicability) {
      case 'applicable':
        return AppColors.accentColor;
      case 'possible_applicability':
        return Colors.green.shade600;
      case 'low_applicability':
        return AppColors.detailsColor;
      default:
        return Colors.red.shade700;
    }
  }

  Future<void> _generatePdfAndShare(BuildContext context) async {
    final doc = pw.Document();
    final data = _processData;

    final pedidos =
        (data?['pedidos'] as List?)?.map((e) => e.toString()).toList() ?? [];

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(level: 0, text: 'Análise do processo'),
          if (data?['tipo'] != null)
            pw.Paragraph(text: 'Tipo: ${data!['tipo']}'),
          if (data?['tribunal'] != null)
            pw.Paragraph(text: 'Tribunal: ${data!['tribunal']}'),
          pw.Header(level: 1, text: 'Partes'),
          pw.Paragraph(
            text: 'Autor: ${data?['autor'] ?? '-'}\nRéu: ${data?['reu'] ?? '-'}',
          ),
          if ((data?['fatos'] as String?)?.isNotEmpty == true) ...[
            pw.Header(level: 1, text: 'Fatos'),
            pw.Paragraph(text: data!['fatos']),
          ],
          if (pedidos.isNotEmpty) ...[
            pw.Header(level: 1, text: 'Pedidos'),
            ...pedidos.map((p) => pw.Bullet(text: p)),
          ],
          if ((data?['contestacao'] as String?)?.isNotEmpty == true) ...[
            pw.Header(level: 1, text: 'Contestação'),
            pw.Paragraph(text: data!['contestacao']),
          ],
        ],
      ),
    );

    final bytes = await doc.save();
    await Printing.sharePdf(bytes: bytes, filename: 'analise_processo.pdf');
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (_processData == null && !_isDone) {
      return BasePageTemplate(
        title: 'Análise do processo',
        onBackPress: () => context.pop(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Lottie.asset(
                'assets/animations/loading.json',
                width: 120,
                height: 120,
              ),
              const Text('Analisando processo...'),
            ],
          ),
        ),
      );
    }

    if (_processData == null && _isDone) {
      return BasePageTemplate(
        title: 'Análise do processo',
        onBackPress: () => context.pop(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Lottie.asset(
                'assets/animations/not_found.json',
                width: 70,
                height: 70,
              ),
              const Text('Não foi possível analisar o processo'),
            ],
          ),
        ),
      );
    }

    final data = _processData!;
    final pedidos =
        (data['pedidos'] as List?)?.map((e) => e.toString()).toList() ?? [];

    return BasePageTemplate(
      title: 'Análise do processo',
      onBackPress: () => context.pop(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.altLightColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (data['tipo'] != null) ...[
                  Text(
                    data['tipo'] as String,
                    style: textTheme.titleSmall?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                if (data['tribunal'] != null) ...[
                  Text(
                    data['tribunal'] as String,
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
                Text(
                  'Partes',
                  style: textTheme.titleSmall?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Autor: ',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: (data['autor'] as String?) ?? '-',
                        style: textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Réu: ',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: (data['reu'] as String?) ?? '-',
                        style: textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                if ((data['fatos'] as String?)?.isNotEmpty == true) ...[
                  const SizedBox(height: 18),
                  Text(
                    'Fatos',
                    style: textTheme.titleSmall?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    data['fatos'] as String,
                    style: textTheme.bodyMedium,
                  ),
                ],
                if (pedidos.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Text(
                    'Pedidos',
                    style: textTheme.titleSmall?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: pedidos.map((p) => _BulletText(text: p)).toList(),
                  ),
                ],
                if ((data['contestacao'] as String?)?.isNotEmpty == true) ...[
                  const SizedBox(height: 18),
                  Text(
                    'Contestação',
                    style: textTheme.titleSmall?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    data['contestacao'] as String,
                    style: textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Precedentes recomendados',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (_precedents.isNotEmpty)
            Text(
              '${_precedents.length} precedente(s)${_isDone ? '' : ' — buscando mais...'}',
              style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            ),
          const SizedBox(height: 16),
          if (_precedents.isEmpty && !_isDone)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Column(
                  children: [
                    Lottie.asset(
                      'assets/animations/loading.json',
                      width: 80,
                      height: 80,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Buscando precedentes...',
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (_precedents.isEmpty && _isDone)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  'Nenhum precedente encontrado',
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _precedents.length + (_isDone ? 0 : 1),
              separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                if (index == _precedents.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Lottie.asset(
                        'assets/animations/loading.json',
                        width: 80,
                        height: 80,
                      ),
                    ),
                  );
                }

                final item = _precedents[index];
                final applicability = (item['applicability'] as String?) ?? '';

                return PrecedentResultCard(
                  tribunal: (item['tribunal'] as String?) ?? '',
                  siglaTribunal: (item['tribunal'] as String?) ?? '',
                  codigoPrecedente: (item['name'] as String?) ?? '',
                  descricao: (item['description'] as String?) ?? '',
                  situacao: (item['situation'] as String?) ?? '',
                  species: (item['species'] as String?) ?? '',
                  lastUpdate: (item['last_update'] as String?) ?? '',
                  probabilidade: _getProbabilidade(applicability),
                  probabilidadeColor: _getProbabilidadeColor(applicability),
                );
              },
            ),
          if (_isDone && _precedents.isNotEmpty) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => _generatePdfAndShare(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.altLightColor,
                  foregroundColor: AppColors.mainDarkColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.download, color: AppColors.mainDarkColor),
                    const SizedBox(width: 12),
                    const Text('Gerar minuta'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }
}

class _BulletText extends StatelessWidget {
  final String text;

  const _BulletText({required this.text});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6, right: 8),
            child: CircleAvatar(
              radius: 4,
              backgroundColor: AppColors.mainDarkColor,
            ),
          ),
          Expanded(child: Text(text, style: textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

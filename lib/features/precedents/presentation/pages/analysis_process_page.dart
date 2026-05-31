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

        if (eventName == 'precedent') {
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

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(level: 0, text: 'Análise do processo'),
          pw.Paragraph(
            text:
                'Resumo:\nLorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce et varius risus, vel vulputate nibh. Phasellus vel sapien id risus pellentesque bibendum. Cras lobortis condimentum tortor aliquam feugiat. Mauris semper pretium nisi, eget finibus lectus.',
          ),
          pw.Header(level: 1, text: 'Partes'),
          pw.Paragraph(text: 'Autor: Fulano da Silva\nRéu: Siclano Jr.'),
          pw.Header(level: 1, text: 'Recursos'),
          pw.Bullet(text: 'Recurso 1'),
          pw.Bullet(text: 'Recurso 2'),
          pw.Bullet(text: 'Recurso 3'),
          pw.Header(level: 1, text: 'Manifestações'),
          pw.Paragraph(
            text:
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce et varius risus, vel vulputate nibh. Phasellus vel sapien id risus pellentesque bibendum. Cras lobortis condimentum tortor aliquam feugiat. Mauris semper pretium nisi, eget finibus lectus.',
          ),
        ],
      ),
    );

    final bytes = await doc.save();
    await Printing.sharePdf(bytes: bytes, filename: 'analise_processo.pdf');
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (_precedents.isEmpty && !_isDone) {
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

    if (_precedents.isEmpty && _isDone) {
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
              const Text('Nenhum precedente encontrado'),
            ],
          ),
        ),
      );
    }

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
                Text(
                  'Resumo',
                  style: textTheme.titleSmall?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce et varius risus, vel vulputate nibh. Phasellus vel sapien id risus pellentesque bibendum. Cras lobortis condimentum tortor aliquam feugiat. Mauris semper pretium nisi, eget finibus lectus.',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 18),
                Text(
                  'Partes',
                  style: textTheme.titleSmall?.copyWith(
                    fontSize: 18,
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
                        text: 'Fulano da Silva',
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
                        text: 'Siclano Jr.',
                        style: textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Recursos',
                  style: textTheme.titleSmall?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _BulletText(text: 'Recurso 1'),
                    _BulletText(text: 'Recurso 2'),
                    _BulletText(text: 'Recurso 3'),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'Manifestações',
                  style: textTheme.titleSmall?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce et varius risus, vel vulputate nibh. Phasellus vel sapien id risus pellentesque bibendum. Cras lobortis condimentum tortor aliquam feugiat. Mauris semper pretium nisi, eget finibus lectus.',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      Text('• Danos morais'),
                      Text('• Indenização'),
                      Text('• Reparação'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Precedentes recomendados',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '${_precedents.length} precedente(s)${_isDone ? '' : ' — buscando mais...'}',
            style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),

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

          if (_isDone) ...[
            const SizedBox(height: 24),
            RichText(
              text: TextSpan(
                style: textTheme.bodyMedium,
                children: [
                  TextSpan(
                    text: 'Resumo: ',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(
                    text:
                        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus rutrum, leo id fermentum fermentum, augue lectus placerat ligula, a ornare eros odio sed ex. Etiam consequat pretium mollis. Duis purus, ultricies in maximus nec, placerat at diam.',
                  ),
                ],
              ),
            ),
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

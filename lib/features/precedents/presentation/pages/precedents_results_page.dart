import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/base_template.dart';

class PrecedentsResultsPage extends StatefulWidget {
  final Map<String, dynamic> data;

  const PrecedentsResultsPage({super.key, required this.data});

  @override
  State<PrecedentsResultsPage> createState() => _PrecedentsResultsPageState();
}

class _PrecedentsResultsPageState extends State<PrecedentsResultsPage> {
  late List<Map<String, dynamic>> _allResults;
  late List<Map<String, dynamic>> _filteredResults;

  String? _situacaoFilter;
  String? _speciesFilter;
  String? _tribunalFilter;
  _DateSort _dateSort = _DateSort.none;

  @override
  void initState() {
    super.initState();
    _allResults = List<Map<String, dynamic>>.from(
      (widget.data['results'] as List<dynamic>?) ?? [],
    );
    _filteredResults = List.from(_allResults);
  }

  DateTime _parseDate(String date) {
    try {
      final parts = date.split('/');
      return DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
    } catch (_) {
      return DateTime(2000);
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredResults = _allResults.where((item) {
        final situacaoOk =
            _situacaoFilter == null || item['situation'] == _situacaoFilter;
        final speciesOk =
            _speciesFilter == null || item['species'] == _speciesFilter;
        final tribunalOk =
            _tribunalFilter == null || item['tribunal'] == _tribunalFilter;
        return situacaoOk && speciesOk && tribunalOk;
      }).toList();

      if (_dateSort == _DateSort.newest) {
        _filteredResults.sort(
          (a, b) => _parseDate(
            (b['last_update'] as String?) ?? '',
          ).compareTo(_parseDate((a['last_update'] as String?) ?? '')),
        );
      } else if (_dateSort == _DateSort.oldest) {
        _filteredResults.sort(
          (a, b) => _parseDate(
            (a['last_update'] as String?) ?? '',
          ).compareTo(_parseDate((b['last_update'] as String?) ?? '')),
        );
      }
    });
  }

  void _clearFilters() {
    setState(() {
      _situacaoFilter = null;
      _speciesFilter = null;
      _tribunalFilter = null;
      _dateSort = _DateSort.none;
      _filteredResults = List.from(_allResults);
    });
  }

  List<String> _uniqueValues(String key) {
    return _allResults
        .map((e) => e[key] as String?)
        .whereType<String>()
        .toSet()
        .toList()
      ..sort();
  }

  bool get _hasActiveFilters =>
      _situacaoFilter != null ||
      _speciesFilter != null ||
      _tribunalFilter != null ||
      _dateSort != _DateSort.none;

  void _showFilterBottomSheet(BuildContext context) {
    String? tempSituacao = _situacaoFilter;
    String? tempSpecies = _speciesFilter;
    String? tempTribunal = _tribunalFilter;
    _DateSort tempDateSort = _dateSort;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filtrar resultados',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          _clearFilters();
                          Navigator.pop(context);
                        },
                        child: const Text('Limpar tudo'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _FilterDropdown(
                    label: 'Situação',
                    value: tempSituacao,
                    options: _uniqueValues('situation'),
                    onChanged: (v) => setSheetState(() => tempSituacao = v),
                  ),
                  const SizedBox(height: 12),

                  _FilterDropdown(
                    label: 'Tipo de precedente',
                    value: tempSpecies,
                    options: _uniqueValues('species'),
                    onChanged: (v) => setSheetState(() => tempSpecies = v),
                  ),
                  const SizedBox(height: 12),

                  _FilterDropdown(
                    label: 'Tribunal',
                    value: tempTribunal,
                    options: _uniqueValues('tribunal'),
                    onChanged: (v) => setSheetState(() => tempTribunal = v),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Ordenar por data',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _DateSortChip(
                        label: 'Padrão',
                        selected: tempDateSort == _DateSort.none,
                        onTap: () =>
                            setSheetState(() => tempDateSort = _DateSort.none),
                      ),
                      const SizedBox(width: 8),
                      _DateSortChip(
                        label: 'Mais recentes',
                        icon: Icons.arrow_upward_rounded,
                        selected: tempDateSort == _DateSort.newest,
                        onTap: () => setSheetState(
                          () => tempDateSort = _DateSort.newest,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _DateSortChip(
                        label: 'Mais antigos',
                        icon: Icons.arrow_downward_rounded,
                        selected: tempDateSort == _DateSort.oldest,
                        onTap: () => setSheetState(
                          () => tempDateSort = _DateSort.oldest,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _situacaoFilter = tempSituacao;
                          _speciesFilter = tempSpecies;
                          _tribunalFilter = tempTribunal;
                          _dateSort = tempDateSort;
                        });
                        _applyFilters();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mainDarkColor,
                        foregroundColor: AppColors.mainWhiteColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Aplicar filtros'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _nomeTribunal(String sigla) {
    const nomes = {
      'STF': 'Supremo Tribunal Federal',
      'STJ': 'Superior Tribunal de Justiça',
      'TST': 'Tribunal Superior do Trabalho',
      'TSE': 'Tribunal Superior Eleitoral',
      'STM': 'Superior Tribunal Militar',
      // ... abreviações padrão do judiciário ...
      'TJSP': 'Tribunal de Justiça de São Paulo',
    };
    return nomes[sigla] ?? sigla;
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

  @override
  Widget build(BuildContext context) {
    // === EXTRAINDO OS DADOS DO ARQUIVO ENVIADO COM TRATAMENTO DE TIPOS ===
    final queryData = widget.data['query'] as Map<String, dynamic>? ?? {};
    
    final String fileName = queryData['filename']?.toString() ?? 'peticao_inicial_1.pdf';
    final String facts = queryData['facts']?.toString() ?? 'Resumo dos fatos não disponível no momento.';
    
    // Extraímos a sigla do tribunal da query (com STJ de fallback igual a sua imagem)
    final String rawTribunal = queryData['tribunal']?.toString() ?? 'STJ';
    final String tribunalFormatado = _nomeTribunal(rawTribunal); // Transforma em nome completo se necessário
    
    List<String> requests = [];
    final rawRequests = queryData['requests'];
    
    if (rawRequests is String) {
      if (rawRequests.trim().isNotEmpty) {
        requests = rawRequests.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }
    } else if (rawRequests is List) {
      requests = rawRequests.map((e) => e.toString()).toList();
    }

    if (requests.isEmpty) {
      requests = ['Danos morais', 'Reparação', 'Indenização'];
    }

    if (_allResults.isEmpty) {
      return const Center(child: Text('Nenhum precedente encontrado.'));
    }

    return BasePageTemplate(
      title: 'Precedentes jurídicos',
      onBackPress: () => context.pop(),
      floatingActionButton: Stack(
        children: [
          FloatingActionButton(
            mini: true,
            onPressed: () => _showFilterBottomSheet(context),
            backgroundColor: AppColors.detailsColor,
            child: const Icon(Icons.filter_list_rounded, color: Colors.white),
          ),
          if (_hasActiveFilters)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.accentColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==========================================
          // CARD CLICÁVEL DO ARQUIVO ENVIADO
          // ==========================================
          _QueryDocumentCard(
            fileName: fileName,
            facts: facts,
            requests: requests,
            tribunal: rawTribunal, // Usando a sigla no card para ficar igual a foto (STJ)
          ),
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              '${_filteredResults.length} de ${_allResults.length} precedentes encontrados',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            ),
          ),

          if (_filteredResults.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 40),
                child: Text('Nenhum resultado para os filtros selecionados.'),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredResults.length,
              separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = _filteredResults[index];
                final String applicability =
                    (item['applicability'] as String?) ?? '';

                return GestureDetector(
                  onTap: () => context.push(
                    '/precedents/details/${item['id']}',
                    extra: {
                      ...item,
                      'query_facts': widget.data['query']?['facts'] ?? '',
                    },
                  ),
                  child: PrecedentResultCard(
                    tribunal: _nomeTribunal(item['tribunal'] as String),
                    siglaTribunal: item['tribunal'] as String,
                    codigoPrecedente: item['name'] as String,
                    descricao: item['description'] as String,
                    situacao: item['situation'] as String,
                    species: item['species'] as String,
                    lastUpdate: (item['last_update'] as String?) ?? '',
                    probabilidade: _getProbabilidade(applicability),
                    probabilidadeColor: _getProbabilidadeColor(applicability),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

// ==========================================================
// WIDGET ATUALIZADO: CARD DO ARQUIVO (Agora clicável e com Tribunal)
// ==========================================================
class _QueryDocumentCard extends StatelessWidget {
  final String fileName;
  final String facts;
  final List<String> requests;
  final String tribunal;

  const _QueryDocumentCard({
    required this.fileName,
    required this.facts,
    required this.requests,
    required this.tribunal,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      // === NAVEGAÇÃO PARA A TELA DE RESUMO COMPLETO ===
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DocumentSummaryPage(
              fileName: fileName,
              tribunal: tribunal,
              facts: facts,
              requests: requests,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE6E9EF),
          borderRadius: BorderRadius.circular(12),
          // Sombra sutil para indicar que é clicável
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 75,
                  height: 95,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      const Center(
                        child: Icon(Icons.insert_drive_file_outlined, color: Colors.black12, size: 36),
                      ),
                      Positioned(
                        bottom: 0, left: 0, right: 0,
                        child: Container(
                          color: Colors.black.withOpacity(0.4),
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                          child: Text(
                            fileName,
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // === TÍTULO ALTERADO PARA O TRIBUNAL ===
                      Text(
                        tribunal,
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.mainDarkColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        facts,
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade800,
                          height: 1.4,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Toque para ver o resumo completo',
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            if (requests.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Wrap(
                  spacing: 24,
                  runSpacing: 8,
                  children: requests.map((req) => _BulletPoint(text: req)).toList(),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;
  const _BulletPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Flexible(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ... Filtros e DateSort mantidos exatamente como antes
enum _DateSort { none, newest, oldest }
class _FilterDropdown extends StatelessWidget { /* igual */
  final String label; final String? value; final List<String> options; final ValueChanged<String?> onChanged;
  const _FilterDropdown({required this.label, required this.value, required this.options, required this.onChanged});
  @override Widget build(BuildContext context) { return DropdownButtonFormField<String>(initialValue: value, isExpanded: true, style: Theme.of(context).textTheme.bodyMedium, decoration: InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)), items: [const DropdownMenuItem(value: null, child: Text('Todos')), ...options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))], onChanged: onChanged); }
}
class _DateSortChip extends StatelessWidget { /* igual */
  final String label; final IconData? icon; final bool selected; final VoidCallback onTap;
  const _DateSortChip({required this.label, required this.selected, required this.onTap, this.icon});
  @override Widget build(BuildContext context) { return GestureDetector(onTap: onTap, child: AnimatedContainer(duration: const Duration(milliseconds: 180), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: selected ? AppColors.mainDarkColor : AppColors.altLightColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: selected ? AppColors.mainDarkColor : AppColors.altDarkColor.withValues(alpha: 0.3))), child: Row(mainAxisSize: MainAxisSize.min, children: [if (icon != null) ...[Icon(icon, size: 14, color: selected ? AppColors.mainWhiteColor : AppColors.altDarkColor), const SizedBox(width: 4)], Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: selected ? AppColors.mainWhiteColor : AppColors.altDarkColor, fontWeight: FontWeight.w600))]))); }
}
class PrecedentResultCard extends StatelessWidget { /* igual */
  final String tribunal, siglaTribunal, codigoPrecedente, situacao, descricao, species, lastUpdate, probabilidade; final Color probabilidadeColor;
  const PrecedentResultCard({super.key, required this.tribunal, required this.siglaTribunal, required this.codigoPrecedente, required this.situacao, required this.descricao, required this.species, required this.lastUpdate, required this.probabilidade, required this.probabilidadeColor});
  @override Widget build(BuildContext context) { final isSuspended = situacao.toLowerCase() == 'suspenso'; return Opacity(opacity: isSuspended ? 0.55 : 1.0, child: Container(decoration: BoxDecoration(color: AppColors.mainWhiteColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: isSuspended ? Colors.grey.shade400 : Colors.grey.shade300), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]), clipBehavior: Clip.antiAlias, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [if (isSuspended) Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 5), color: Colors.grey.shade400, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.pause_circle_outline_rounded, size: 13, color: Colors.grey.shade800), const SizedBox(width: 4), Text('Precedente suspenso', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey.shade800, fontWeight: FontWeight.w600))])), IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Container(width: 120, color: AppColors.altLightColor, padding: const EdgeInsets.all(12.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(tribunal, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.altDarkColor, height: 1.2)), const SizedBox(height: 8), Text(siglaTribunal, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.mainDarkColor)), Container(height: 4, width: double.infinity, color: AppColors.mainDarkColor, margin: const EdgeInsets.only(top: 4))]), const SizedBox(height: 16), if (lastUpdate.isNotEmpty) Text(lastUpdate, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.altDarkColor))])), Expanded(child: Padding(padding: const EdgeInsets.all(12.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(codigoPrecedente, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600)), const SizedBox(height: 6), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: AppColors.altLightColor, borderRadius: BorderRadius.circular(4), border: Border.all(color: AppColors.altDarkColor.withValues(alpha: 0.3))), child: Text(species, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.altDarkColor, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)), const SizedBox(height: 8), Text(descricao, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.altDarkColor, height: 1.4), maxLines: 4, overflow: TextOverflow.ellipsis), const SizedBox(height: 12), Align(alignment: Alignment.bottomRight, child: Text(probabilidade, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600, color: probabilidadeColor)))])))]))]))); }
}


// ==========================================================
// NOVA TELA: RESUMO COMPLETO DO DOCUMENTO
// ==========================================================
class DocumentSummaryPage extends StatelessWidget {
  final String fileName;
  final String tribunal;
  final String facts;
  final List<String> requests;

  const DocumentSummaryPage({
    super.key,
    required this.fileName,
    required this.tribunal,
    required this.facts,
    required this.requests,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BasePageTemplate(
      title: 'Resumo Completo',
      onBackPress: () => Navigator.of(context).pop(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.altLightColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.altDarkColor.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.picture_as_pdf_rounded, color: AppColors.mainDarkColor, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fileName,
                          style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tribunal Alvo: $tribunal',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.mainDarkColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Seção de Fatos
            Text(
              'Fatos e Fundamentos',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.mainDarkColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              facts,
              style: textTheme.bodyMedium?.copyWith(
                height: 1.6,
                color: Colors.grey.shade800,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 24),

            // Seção de Pedidos
            Text(
              'Pedidos Identificados',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.mainDarkColor,
              ),
            ),
            const SizedBox(height: 16),
            
            if (requests.isEmpty)
              Text('Nenhum pedido extraído.', style: textTheme.bodyMedium)
            else
              ...requests.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_outline, 
                      size: 20, 
                      color: AppColors.accentColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        r,
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade800,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
              
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
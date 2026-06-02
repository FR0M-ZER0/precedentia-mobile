import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/base_template.dart';

class PrecedentsResultsPage extends StatefulWidget {
  final Stream<Map<String, dynamic>> stream;
  const PrecedentsResultsPage({super.key, required this.stream});

  @override
  State<PrecedentsResultsPage> createState() => _PrecedentsResultsPageState();
}

class _PrecedentsResultsPageState extends State<PrecedentsResultsPage> {
  final List<Map<String, dynamic>> _allResults = [];
  List<Map<String, dynamic>> _filteredResults = [];
  bool _isDone = false;
  String? _queryFacts;
  String? _queryType;
  String? _queryTribunal;
  List<String> _queryRequests = [];

  StreamSubscription? _subscription;

  String? _situacaoFilter;
  String? _speciesFilter;
  String? _tribunalFilter;
  String? _applicabilityFilter;
  _DateSort _dateSort = _DateSort.none;
  _ApplicabilitySort _applicabilitySort = _ApplicabilitySort.none;

  @override
  void initState() {
    super.initState();
    _filteredResults = _allResults;
    _listenToStream();
  }

  void _listenToStream() {
    _subscription = widget.stream.listen(
      (event) {
        final eventName = event['event'] as String?;

        if (eventName == 'precedent') {
          setState(() {
            _allResults.add(event);
            _applyFilters();
          });
        } else if (eventName == 'search_complete' ||
            eventName == 'rerank_complete') {
        } else if (eventName == 'done') {
          debugPrint('evento done recebido: $event');
          final query = event['query'] as Map<String, dynamic>?;
          final rawRequests = query?['requests'];
          setState(() {
            _isDone = true;
            _queryFacts = query?['facts'] as String?;
            _queryType = query?['type'] as String?;
            _queryTribunal = query?['tribunal'] as String?;
            _queryRequests = rawRequests is List
                ? List<String>.from(rawRequests)
                : (rawRequests as String?)?.isNotEmpty == true
                ? [rawRequests!]
                : [];
          });
        } else if (eventName == 'error') {
          setState(() => _isDone = true);
          if (mounted) {
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
    _filteredResults = _allResults.where((item) {
      final situacaoOk =
          _situacaoFilter == null || item['situation'] == _situacaoFilter;
      final speciesOk =
          _speciesFilter == null || item['species'] == _speciesFilter;
      final tribunalOk =
          _tribunalFilter == null || item['tribunal'] == _tribunalFilter;
      final applicabilityOk =
          _applicabilityFilter == null ||
          item['applicability'] == _applicabilityFilter;
      return situacaoOk && speciesOk && tribunalOk && applicabilityOk;
    }).toList();

    if (_applicabilitySort == _ApplicabilitySort.bestFirst) {
      const order = {
        'applicable': 0,
        'possible_applicability': 1,
        'low_applicability': 2,
        'not_applicable': 3,
      };
      _filteredResults.sort((a, b) {
        final aVal = order[a['applicability']] ?? 99;
        final bVal = order[b['applicability']] ?? 99;
        return aVal.compareTo(bVal);
      });
    }

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
  }

  void _clearFilters() {
    setState(() {
      _situacaoFilter = null;
      _speciesFilter = null;
      _tribunalFilter = null;
      _applicabilityFilter = null;
      _dateSort = _DateSort.none;
      _applicabilitySort = _ApplicabilitySort.none;
      _applyFilters();
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
      _applicabilityFilter != null ||
      _dateSort != _DateSort.none ||
      _applicabilitySort != _ApplicabilitySort.none;

  void _showFilterBottomSheet(BuildContext context) {
    String? tempSituacao = _situacaoFilter;
    String? tempSpecies = _speciesFilter;
    String? tempTribunal = _tribunalFilter;
    String? tempApplicability = _applicabilityFilter;
    _DateSort tempDateSort = _dateSort;
    _ApplicabilitySort tempApplicabilitySort = _applicabilitySort;

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
                  const SizedBox(height: 12),
                  _FilterDropdown(
                    label: 'Aplicabilidade',
                    value: tempApplicability,
                    options: _uniqueValues('applicability'),
                    onChanged: (v) =>
                        setSheetState(() => tempApplicability = v),
                    labelBuilder: _getProbabilidade,
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
                  const SizedBox(height: 20),
                  Text(
                    'Ordenar por aplicabilidade',
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
                        selected:
                            tempApplicabilitySort == _ApplicabilitySort.none,
                        onTap: () => setSheetState(
                          () => tempApplicabilitySort = _ApplicabilitySort.none,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _DateSortChip(
                        label: 'Mais aplicável',
                        icon: Icons.sort_rounded,
                        selected:
                            tempApplicabilitySort ==
                            _ApplicabilitySort.bestFirst,
                        onTap: () => setSheetState(
                          () => tempApplicabilitySort =
                              _ApplicabilitySort.bestFirst,
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
                          _applicabilityFilter = tempApplicability;
                          _dateSort = tempDateSort;
                          _applicabilitySort = tempApplicabilitySort;
                          _applyFilters();
                        });
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
      'TRF1': 'Tribunal Regional Federal 1ª Região',
      'TRF2': 'Tribunal Regional Federal 2ª Região',
      'TRF3': 'Tribunal Regional Federal 3ª Região',
      'TRF4': 'Tribunal Regional Federal 4ª Região',
      'TRF5': 'Tribunal Regional Federal 5ª Região',
      'TJAC': 'Tribunal de Justiça do Acre',
      'TJAL': 'Tribunal de Justiça de Alagoas',
      'TJAP': 'Tribunal de Justiça do Amapá',
      'TJAM': 'Tribunal de Justiça do Amazonas',
      'TJBA': 'Tribunal de Justiça da Bahia',
      'TJCE': 'Tribunal de Justiça do Ceará',
      'TJDFT': 'Tribunal de Justiça do Distrito Federal e Territórios',
      'TJES': 'Tribunal de Justiça do Espírito Santo',
      'TJGO': 'Tribunal de Justiça de Goiás',
      'TJMA': 'Tribunal de Justiça do Maranhão',
      'TJMT': 'Tribunal de Justiça de Mato Grosso',
      'TJMS': 'Tribunal de Justiça de Mato Grosso do Sul',
      'TJMG': 'Tribunal de Justiça de Minas Gerais',
      'TJPA': 'Tribunal de Justiça do Pará',
      'TJPB': 'Tribunal de Justiça da Paraíba',
      'TJPR': 'Tribunal de Justiça do Paraná',
      'TJPE': 'Tribunal de Justiça de Pernambuco',
      'TJPI': 'Tribunal de Justiça do Piauí',
      'TJRJ': 'Tribunal de Justiça do Rio de Janeiro',
      'TJRN': 'Tribunal de Justiça do Rio Grande do Norte',
      'TJRS': 'Tribunal de Justiça do Rio Grande do Sul',
      'TJRO': 'Tribunal de Justiça de Rondônia',
      'TJRR': 'Tribunal de Justiça de Roraima',
      'TJSC': 'Tribunal de Justiça de Santa Catarina',
      'TJSP': 'Tribunal de Justiça de São Paulo',
      'TJSE': 'Tribunal de Justiça de Sergipe',
      'TJTO': 'Tribunal de Justiça do Tocantins',
      'TRT1': 'Tribunal Regional do Trabalho 1ª Região',
      'TRT2': 'Tribunal Regional do Trabalho 2ª Região',
      'TRT3': 'Tribunal Regional do Trabalho 3ª Região',
      'TRT4': 'Tribunal Regional do Trabalho 4ª Região',
      'TRT5': 'Tribunal Regional do Trabalho 5ª Região',
      'TRT6': 'Tribunal Regional do Trabalho 6ª Região',
      'TRT7': 'Tribunal Regional do Trabalho 7ª Região',
      'TRT8': 'Tribunal Regional do Trabalho 8ª Região',
      'TRT9': 'Tribunal Regional do Trabalho 9ª Região',
      'TRT10': 'Tribunal Regional do Trabalho 10ª Região',
      'TRT11': 'Tribunal Regional do Trabalho 11ª Região',
      'TRT12': 'Tribunal Regional do Trabalho 12ª Região',
      'TRT13': 'Tribunal Regional do Trabalho 13ª Região',
      'TRT14': 'Tribunal Regional do Trabalho 14ª Região',
      'TRT15': 'Tribunal Regional do Trabalho 15ª Região',
      'TRT16': 'Tribunal Regional do Trabalho 16ª Região',
      'TRT17': 'Tribunal Regional do Trabalho 17ª Região',
      'TRT18': 'Tribunal Regional do Trabalho 18ª Região',
      'TRT19': 'Tribunal Regional do Trabalho 19ª Região',
      'TRT20': 'Tribunal Regional do Trabalho 20ª Região',
      'TRT21': 'Tribunal Regional do Trabalho 21ª Região',
      'TRT22': 'Tribunal Regional do Trabalho 22ª Região',
      'TRT23': 'Tribunal Regional do Trabalho 23ª Região',
      'TRT24': 'Tribunal Regional do Trabalho 24ª Região',
      'TREAC': 'Tribunal Regional Eleitoral do Acre',
      'TREAL': 'Tribunal Regional Eleitoral de Alagoas',
      'TREAP': 'Tribunal Regional Eleitoral do Amapá',
      'TREAM': 'Tribunal Regional Eleitoral do Amazonas',
      'TREBA': 'Tribunal Regional Eleitoral da Bahia',
      'TRECE': 'Tribunal Regional Eleitoral do Ceará',
      'TREDF': 'Tribunal Regional Eleitoral do Distrito Federal',
      'TREES': 'Tribunal Regional Eleitoral do Espírito Santo',
      'TREGO': 'Tribunal Regional Eleitoral de Goiás',
      'TREMA': 'Tribunal Regional Eleitoral do Maranhão',
      'TREMT': 'Tribunal Regional Eleitoral de Mato Grosso',
      'TREMS': 'Tribunal Regional Eleitoral de Mato Grosso do Sul',
      'TREMG': 'Tribunal Regional Eleitoral de Minas Gerais',
      'TREPA': 'Tribunal Regional Eleitoral do Pará',
      'TREPB': 'Tribunal Regional Eleitoral da Paraíba',
      'TREPR': 'Tribunal Regional Eleitoral do Paraná',
      'TREPE': 'Tribunal Regional Eleitoral de Pernambuco',
      'TREPI': 'Tribunal Regional Eleitoral do Piauí',
      'TRERJ': 'Tribunal Regional Eleitoral do Rio de Janeiro',
      'TRERN': 'Tribunal Regional Eleitoral do Rio Grande do Norte',
      'TRERS': 'Tribunal Regional Eleitoral do Rio Grande do Sul',
      'TRERO': 'Tribunal Regional Eleitoral de Rondônia',
      'TRERR': 'Tribunal Regional Eleitoral de Roraima',
      'TRESC': 'Tribunal Regional Eleitoral de Santa Catarina',
      'TRESP': 'Tribunal Regional Eleitoral de São Paulo',
      'TRESE': 'Tribunal Regional Eleitoral de Sergipe',
      'TRETO': 'Tribunal Regional Eleitoral de Tocantins',
      'TJMMG': 'Tribunal de Justiça Militar de Minas Gerais',
      'TJMRS': 'Tribunal de Justiça Militar do Rio Grande do Sul',
      'TJMSP': 'Tribunal de Justiça Militar de São Paulo',
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
    if (_allResults.isEmpty && !_isDone) {
      return BasePageTemplate(
        title: 'Precedentes jurídicos',
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
              const Text('Buscando precedentes...'),
            ],
          ),
        ),
      );
    }

    if (_allResults.isEmpty && _isDone) {
      return BasePageTemplate(
        title: 'Precedentes jurídicos',
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
          _QueryDocumentCard(
            fileName: _queryType ?? 'peticao_inicial_1.pdf',
            facts:
                _queryFacts ??
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit...',
            requests: _queryRequests.isNotEmpty
                ? _queryRequests
                : ['Danos morais', 'Indenização', 'Reparação'],
            tribunal: _queryTribunal ?? 'N/A',
          ),
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              '${_filteredResults.length} de ${_allResults.length} precedentes',
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
              itemCount: _filteredResults.length + (_isDone ? 0 : 1),
              separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                if (index == _filteredResults.length) {
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

                final item = _filteredResults[index];
                final String applicability =
                    (item['applicability'] as String?) ?? '';

                return GestureDetector(
                  onTap: () => context.push(
                    '/precedents/details/${item['id']}',
                    extra: {...item, 'query_facts': _queryFacts ?? ''},
                  ),
                  child: PrecedentResultCard(
                    tribunal: _nomeTribunal(
                      (item['tribunal'] as String?) ?? '',
                    ),
                    siglaTribunal: (item['tribunal'] as String?) ?? '',
                    codigoPrecedente: (item['name'] as String?) ?? '',
                    descricao: (item['description'] as String?) ?? '',
                    situacao: (item['situation'] as String?) ?? '',
                    species: (item['species'] as String?) ?? '',
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE6E9EF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (fileName.isNotEmpty) ...[
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
                        child: Icon(
                          Icons.insert_drive_file_outlined,
                          color: Colors.black12,
                          size: 36,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.4),
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 4,
                          ),
                          child: Text(
                            fileName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: requests
                    .map(
                      (req) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '• ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                req,
                                style: textTheme.bodySmall?.copyWith(
                                  color: Colors.grey.shade800,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

enum _DateSort { none, newest, oldest }

enum _ApplicabilitySort { none, bestFirst }

class _FilterDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;
  final String Function(String)? labelBuilder;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.labelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      style: textTheme.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
      items: [
        const DropdownMenuItem(value: null, child: Text('Todos')),
        ...options.map(
          (opt) => DropdownMenuItem(
            value: opt,
            child: Text(labelBuilder != null ? labelBuilder!(opt) : opt),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}

class _DateSortChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  const _DateSortChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.mainDarkColor : AppColors.altLightColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? AppColors.mainDarkColor
                : AppColors.altDarkColor.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: selected
                    ? AppColors.mainWhiteColor
                    : AppColors.altDarkColor,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: selected
                    ? AppColors.mainWhiteColor
                    : AppColors.altDarkColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PrecedentResultCard extends StatelessWidget {
  final String tribunal;
  final String siglaTribunal;
  final String codigoPrecedente;
  final String situacao;
  final String descricao;
  final String species;
  final String lastUpdate;
  final String probabilidade;
  final Color probabilidadeColor;

  const PrecedentResultCard({
    super.key,
    required this.tribunal,
    required this.siglaTribunal,
    required this.codigoPrecedente,
    required this.situacao,
    required this.descricao,
    required this.species,
    required this.lastUpdate,
    required this.probabilidade,
    required this.probabilidadeColor,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isSuspended = situacao.toLowerCase() == 'suspenso';

    return Opacity(
      opacity: isSuspended ? 0.55 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.mainWhiteColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSuspended ? Colors.grey.shade400 : Colors.grey.shade300,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isSuspended)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 5),
                color: Colors.grey.shade400,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.pause_circle_outline_rounded,
                      size: 13,
                      color: Colors.grey.shade800,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Precedente suspenso',
                      style: textTheme.labelSmall?.copyWith(
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 120,
                    color: AppColors.altLightColor,
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tribunal,
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.altDarkColor,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              siglaTribunal,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.mainDarkColor,
                              ),
                            ),
                            Container(
                              height: 4,
                              width: double.infinity,
                              color: AppColors.mainDarkColor,
                              margin: const EdgeInsets.only(top: 4),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (lastUpdate.isNotEmpty)
                          Text(
                            lastUpdate,
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.altDarkColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            codigoPrecedente,
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.altLightColor,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: AppColors.altDarkColor.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            child: Text(
                              species,
                              style: textTheme.labelSmall?.copyWith(
                                color: AppColors.altDarkColor,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            descricao,
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.altDarkColor,
                              height: 1.4,
                            ),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              probabilidade,
                              style: textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: probabilidadeColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

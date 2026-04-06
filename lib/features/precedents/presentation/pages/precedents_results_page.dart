import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/base_template.dart';

class PrecedentsResultsPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const PrecedentsResultsPage({super.key, required this.data});

  String _nomeTribunal(String sigla) {
    const nomes = {
      // Tribunais Superiores
      'STF': 'Supremo Tribunal Federal',
      'STJ': 'Superior Tribunal de Justiça',
      'TST': 'Tribunal Superior do Trabalho',
      'TSE': 'Tribunal Superior Eleitoral',
      'STM': 'Superior Tribunal Militar',
      // Tribunais Regionais Federais
      'TRF1': 'Tribunal Regional Federal 1ª Região',
      'TRF2': 'Tribunal Regional Federal 2ª Região',
      'TRF3': 'Tribunal Regional Federal 3ª Região',
      'TRF4': 'Tribunal Regional Federal 4ª Região',
      'TRF5': 'Tribunal Regional Federal 5ª Região',
      // Tribunais de Justiça
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
      // Tribunais Regionais do Trabalho
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
      // Tribunais Regionais Eleitorais
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
      'TRETO': 'Tribunal Regional Eleitoral do Tocantins',
      // Tribunais Militares Estaduais
      'TJMMG': 'Tribunal de Justiça Militar de Minas Gerais',
      'TJMRS': 'Tribunal de Justiça Militar do Rio Grande do Sul',
      'TJMSP': 'Tribunal de Justiça Militar de São Paulo',
    };
    return nomes[sigla] ?? sigla;
  }

  String _getProbabilidade(double score) {
    if (score >= 0.85) return 'Muito provável';
    if (score >= 0.60) return 'Provável';
    if (score >= 0.40) return 'Pouco provável';
    return 'Muito pouco provável';
  }

  Color _getProbabilidadeColor(double score) {
    if (score >= 0.85) return AppColors.accentColor;
    if (score >= 0.60) return Colors.green.shade600;
    if (score >= 0.40) return AppColors.detailsColor;
    return Colors.red.shade700;
  }

  @override
  Widget build(BuildContext context) {
    final results = (data['results'] as List<dynamic>?) ?? [];

    if (results.isEmpty) {
      return const Center(child: Text('Nenhum precedente encontrado.'));
    }

    return BasePageTemplate(
      title: 'Precedentes jurídicos',
      onBackPress: () => context.pop(),
      body: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: results.length,
        separatorBuilder: (_, _) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final item = results[index] as Map<String, dynamic>;
          final double score = (item['score'] as num).toDouble();

          return GestureDetector(
            onTap: () =>
                context.push('/precedents/details/${item['id']}', extra: item),
            child: PrecedentResultCard(
              tribunal: _nomeTribunal(item['tribunal'] as String),
              siglaTribunal: item['tribunal'] as String,
              codigoPrecedente: item['name'] as String,
              descricao: item['description'] as String,
              situacao: item['situation'] as String,
              species: item['species'] as String,
              lastUpdate: item['last_update'] as String,
              probabilidade: _getProbabilidade(score),
              probabilidadeColor: _getProbabilidadeColor(score),
            ),
          );
        },
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

    return Container(
      decoration: BoxDecoration(
        color: AppColors.mainWhiteColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
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
                          color: AppColors.altDarkColor.withValues(alpha: 0.3),
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
    );
  }
}

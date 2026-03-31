import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:precedentia_mobile/core/widgets/base_template.dart';
import 'package:precedentia_mobile/features/precedents/domain/entities/precedent.dart';
import '../../widgets/precedent_card.dart';

class PrecedentListPage extends StatelessWidget {
  const PrecedentListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // --- DADOS TEMPORÁRIOS (MOCK) ---
    // Você substituirá isso por uma chamada ao BLoC/Provider depois
    final List<Precedent> precedentsMock = [
      Precedent(
        id: "abc1234",
        court: "Superior Tribunal de Justiça",
        courtAcronym: "STJ",
        creationDate: DateTime(2035, 2, 1),
        subject: "Herança familiar",
        summary:
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut turpis nisl, vulputate sit amet ultricies id, hendrerit id ligula. Lorem ipsum dolor sit amet, consectetur...",
        score: 80.0,
        compatibility: Compatibility.muitoProvavel,
      ),
      Precedent(
        id: "xyz5678",
        court: "Superior Tribunal de Justiça",
        courtAcronym: "STJ",
        creationDate: DateTime(2035, 2, 1),
        subject: "Herança familiar",
        summary:
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut turpis nisl, vulputate sit amet ultricies id, hendrerit id ligula. Lorem ipsum dolor sit amet, consectetur...",
        score: 60.0,
        compatibility: Compatibility.provavel,
      ),
      Precedent(
        id: "def9012",
        court: "Superior Tribunal de Justiça",
        courtAcronym: "STJ",
        creationDate: DateTime(2035, 2, 1),
        subject: "Herança familiar",
        summary:
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut turpis nisl, vulputate sit amet ultricies id, hendrerit id ligula. Lorem ipsum dolor sit amet, consectetur...",
        score: 40.0,
        compatibility: Compatibility.poucoProvavel,
      ),
    ];

    return BasePageTemplate(
      title: "Precedentes jurídicos", // Título da Imagem 7
      subtitle: null,
      onBackPress: () => context.pop(), // Volta para a home
      body: SingleChildScrollView(
        child: Column(
          children: precedentsMock.map((precedent) {
            return PrecedentCard(
              precedent: precedent,
              onTap: () {
                // Navega para a tela de detalhes passando o ID (Imagem 9)
                context.push('/precedents/details/${precedent.id}');
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

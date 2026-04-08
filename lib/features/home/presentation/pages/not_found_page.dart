import 'package:flutter/material.dart';
import '../../../../core/widgets/base_template.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePageTemplate(
      title: 'Precedentes jurídicos',
      onBackPress: () {
        Navigator.of(context).pop();
      },
      body: Padding(
        padding: const EdgeInsets.only(top: 60.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/robo.png',
                height: 220,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 32),
              Text(
                'Nenhum precedente encontrado',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
//import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';

class SpeedDialMenu extends StatefulWidget {
  final VoidCallback? onTextPressed;
  final VoidCallback? onUploadPressed;
  final VoidCallback? onMainPressed;

  const SpeedDialMenu({
    super.key,
    this.onTextPressed,
    this.onUploadPressed,
    this.onMainPressed,
  });

  @override
  State<SpeedDialMenu> createState() => _SpeedDialMenuState();
}

class _SpeedDialMenuState extends State<SpeedDialMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _mainBtnRotationAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _mainBtnRotationAnimation = Tween<double>(begin: 0, end: 1 / 8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleSpeedDial() {
    if (_animationController.isDismissed) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    widget.onMainPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          // Botão de Upload (Sobe)
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Positioned(
                bottom: 120 * _animationController.value,
                right: 10,
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: _buildSubButton(
                    Icons.description_outlined,
                    widget.onUploadPressed,
                  ),
                ),
              );
            },
          ),
          // Botão de Texto (Vai para a esquerda)
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Positioned(
                bottom: 80,
                right: 70 * _animationController.value,
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: _buildSubButton(
                    Icons.format_indent_increase,
                    widget.onTextPressed,
                  ),
                ),
              );
            },
          ),
          // Botão Principal (+)
          Positioned(
            bottom: 50,
            right: 0,
            child: RotationTransition(
              turns: _mainBtnRotationAnimation,
              child: _buildMainButton(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubButton(IconData icon, VoidCallback? onPressed) {
    return SizedBox(
      width: 40,
      height: 40,
      child: FloatingActionButton(
        heroTag: null,
        onPressed: onPressed != null
            ? () {
                _toggleSpeedDial();
                onPressed();
              }
            : null,
        elevation: 2,
        backgroundColor: AppColors.accentColor,
        // Isso força o botão a ser circular
        shape: const CircleBorder(),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  // Widget para o botão principal (+) (60x60)
  Widget _buildMainButton() {
    return SizedBox(
      width: 60,
      height: 60,
      child: FloatingActionButton(
        heroTag: null,
        onPressed: _toggleSpeedDial,
        elevation: 4,
        backgroundColor: AppColors.accentColor,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 35),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:exam_project/screens/progress_screen.dart'; // Importez votre écran de paramètres

class AnimatedButton extends StatefulWidget {
  const AnimatedButton({Key? key}) : super(key: key);

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin{
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController=AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation=Tween<double>(begin: 2,end: 0.9).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_){
        _animationController.forward();
      },
      onTapUp: (_){
        _animationController.reverse();
      },
      onTapCancel: (){
        _animationController.reverse();
      },
      onTap: (){
        // Naviguer vers la page de paramètres lorsque le bouton est cliqué
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProgressScreen()),
        );
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.red, Colors.white70],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 30),
              child: const Text(
                "Lancer",
                style: TextStyle(
                    color: Colors.black87, fontSize: 20
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

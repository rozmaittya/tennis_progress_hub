import 'package:flutter/material.dart';

class TennisBallButton extends StatelessWidget {
  final VoidCallback onPressed;

  const TennisBallButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 65,
        height: 65,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
              image: AssetImage('assets/images/tennis_ball.png'),
              fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.add,
          color: Colors.green,
          size: 32,
        ),
      ),
    );
  }
}
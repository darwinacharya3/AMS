
import 'package:flutter/material.dart';

/// Custom text field widget used throughout the login screen
class LoginTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;

  const LoginTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFF4169E1)),
        ),
      ),
      style: const TextStyle(
        fontSize: 14,
      ),
    );
  }
}

/// Custom button widget used for the sign in action
class LoginButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const LoginButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4169E1),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// Custom logo widget for Extratech Oval
class ExtraTechLogo extends StatelessWidget {
  final double height;

  const ExtraTechLogo({
    Key? key,
    this.height = 80,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: height,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Logo swoosh elements
              Positioned(
                left: 0,
                child: CustomPaint(
                  size: Size(height * 2, height),
                  painter: LogoPainter(),
                ),
              ),
              
              // Text elements
              Positioned(
                left: height * 1.1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Text(
                          'EXTRATECH',
                          style: TextStyle(
                            color: const Color(0xFF1E62D0),
                            fontSize: height * 0.25,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'OVAL',
                          style: TextStyle(
                            color: const Color(0xFFE91E63),
                            fontSize: height * 0.25,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Connecting Nepal with Sports',
                      style: TextStyle(
                        color: const Color(0xFF1E62D0),
                        fontSize: height * 0.12,
                        fontStyle: FontStyle.italic,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Custom painter for drawing the logo swoosh
class LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pinkPaint = Paint()
      ..color = const Color(0xFFE91E63)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.height * 0.03;

    final bluePaint = Paint()
      ..color = const Color(0xFF1E62D0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.height * 0.03;

    // Drawing the top curved line (pink)
    final path1 = Path();
    path1.moveTo(0, size.height * 0.2);
    path1.quadraticBezierTo(
      size.width * 0.6, 
      size.height * -0.1, 
      size.width, 
      size.height * 0.15
    );
    canvas.drawPath(path1, pinkPaint);

    // Drawing the middle line (gradient from pink to blue)
    final path2 = Path();
    path2.moveTo(size.width * 0.05, size.height * 0.4);
    path2.quadraticBezierTo(
      size.width * 0.6, 
      size.height * 0.2, 
      size.width * 0.95, 
      size.height * 0.45
    );
    // For simplicity, we'll use blue for this line
    canvas.drawPath(path2, bluePaint);

    // Drawing the bottom curved line (blue)
    final path3 = Path();
    path3.moveTo(size.width * 0.1, size.height * 0.65);
    path3.quadraticBezierTo(
      size.width * 0.6, 
      size.height * 0.5, 
      size.width * 0.9, 
      size.height * 0.7
    );
    canvas.drawPath(path3, bluePaint);

    // Drawing vertical lines
    final smallLinePaint = Paint()
      ..color = const Color(0xFF333333)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var i = 0; i < 5; i++) {
      final x = size.width * (0.2 + i * 0.15);
      canvas.drawLine(
        Offset(x, size.height * 0.47),
        Offset(x, size.height * 0.65),
        smallLinePaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
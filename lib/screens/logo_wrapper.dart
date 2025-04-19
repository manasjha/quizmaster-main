import 'package:flutter/material.dart';
import 'logo_block.dart';

class LogoWrapper extends StatelessWidget {
  final double offsetY;

  const LogoWrapper({super.key, this.offsetY = 0});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: Transform.translate(
            offset: Offset(0, offsetY),
            child: const LogoBlock(),
          ),
        ),
      ],
    );
  }
}

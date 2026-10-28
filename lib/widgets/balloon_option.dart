import 'package:flutter/material.dart';

/// Globo tocable (asset oficial balloon_XX). Al pincharlo se anima
/// una pequeña "explosión" (escala + fade) antes del feedback.
class BalloonOption extends StatefulWidget {
  const BalloonOption({
    super.key,
    required this.assetPath,
    required this.onTap,
    this.enabled = true,
    this.width = 90,
  });

  final String assetPath;
  final VoidCallback onTap;
  final bool enabled;
  final double width;

  @override
  State<BalloonOption> createState() => _BalloonOptionState();
}

class _BalloonOptionState extends State<BalloonOption>
    with SingleTickerProviderStateMixin {
  bool _popped = false;

  void _handleTap() {
    if (!widget.enabled || _popped) return;
    setState(() => _popped = true);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedScale(
        scale: _popped ? 1.3 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: AnimatedOpacity(
          opacity: _popped ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 250),
          child: Image.asset(widget.assetPath, width: widget.width),
        ),
      ),
    );
  }
}

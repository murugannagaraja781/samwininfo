import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AnimatedFavoriteButton extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback onToggle;
  final double size;
  final Color? backgroundColor;

  const AnimatedFavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onToggle,
    this.size = 38,
    this.backgroundColor,
  });

  @override
  State<AnimatedFavoriteButton> createState() => _AnimatedFavoriteButtonState();
}

class _AnimatedFavoriteButtonState extends State<AnimatedFavoriteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward(from: 0.0);
    widget.onToggle();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Icon(
              widget.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: widget.isFavorite ? const Color(0xFFE53935) : AppColors.textSecondary,
              size: widget.size * 0.52,
            ),
          ),
        ),
      ),
    );
  }
}

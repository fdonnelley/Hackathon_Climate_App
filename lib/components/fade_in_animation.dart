import 'package:flutter/material.dart';

/// A widget that animates its child with a fade-in and optional slide animation.
///
/// Use this widget to add subtle entry animations to list items, buttons,
/// or other UI elements for a more polished user experience.
class FadeInAnimation extends StatefulWidget {
  /// The widget to animate
  final Widget child;
  
  /// Animation duration in milliseconds
  final int durationMs;
  
  /// Delay before starting the animation in milliseconds
  final int delayMs;
  
  /// Whether to include a slide up animation
  final bool slideUp;
  
  /// How far to slide up (if slideUp is true)
  final double slideOffset;

  /// Creates a fade in animation.
  const FadeInAnimation({
    super.key,
    required this.child,
    this.durationMs = 300,
    this.delayMs = 0,
    this.slideUp = false,
    this.slideOffset = 30.0,
  });

  @override
  State<FadeInAnimation> createState() => _FadeInAnimationState();
}

class _FadeInAnimationState extends State<FadeInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Create the animation controller
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.durationMs),
    );
    
    // Define the opacity (fade) animation
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    
    // Define the slide animation (if enabled)
    _slideAnimation = Tween<Offset>(
      begin: widget.slideUp ? Offset(0, widget.slideOffset / 100) : Offset.zero,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );
    
    // Start the animation after the specified delay
    if (widget.delayMs == 0) {
      _controller.forward();
    } else {
      Future.delayed(Duration(milliseconds: widget.delayMs)).then((_) {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Direction for slide animations
enum SlideDirection {
  /// Slide from left to right
  left,

  /// Slide from right to left
  right,

  /// Slide from top to bottom
  up,

  /// Slide from bottom to top
  down,
}

/// Types of shared axis transitions
enum SharedAxisTransitionType {
  /// Horizontal shared axis transition (X-axis)
  horizontal,

  /// Vertical shared axis transition (Y-axis)
  vertical,

  /// Scaled shared axis transition (Z-axis)
  scaled,
}

/// Animation utility class for standardized animations across the app
class AppAnimations {
  /// Private constructor to prevent instantiation
  AppAnimations._();
  
  /// Animation duration constants
  
  /// Extra fast animation duration (200ms)
  static const extraFast = Duration(milliseconds: 200);
  
  /// Fast animation duration (280ms)
  static const fast = Duration(milliseconds: 280);
  
  /// Medium animation duration (400ms) - default for most animations
  static const medium = Duration(milliseconds: 400);
  
  /// Slow animation duration (600ms)
  static const slow = Duration(milliseconds: 600);
  
  /// Extra slow animation duration (1000ms)
  static const extraSlow = Duration(milliseconds: 1000);

  /// Animation curve constants
  
  /// Default curve for most animations (optimized for smoothness)
  static const defaultCurve = Curves.easeOutCubic;
  
  /// Emphasized curve for attention-grabbing animations
  static const emphasizedCurve = Curves.easeInOutCubic;
  
  /// Subtle curve for background or secondary animations
  static const subtleCurve = Curves.easeInOut;
  
  /// Bounce curve for playful animations
  static final bounceCurve = Curves.elasticOut;
  
  /// Standard decelerate curve for natural motion
  static const decelerateCurve = Curves.decelerate;
  
  /// Transition offset constants
  
  /// Small offset for subtle animations (10% of the dimension)
  static const smallOffset = 0.1;
  
  /// Medium offset for standard animations (20% of the dimension)
  static const mediumOffset = 0.2;
  
  /// Large offset for emphasized animations (30% of the dimension)
  static const largeOffset = 0.3;
  
  /// Fade constants
  
  /// Standard fade in interval (starts earlier, slower fade in)
  static const fadeInInterval = Interval(0.0, 0.6, curve: Curves.easeOut);
  
  /// Standard fade out interval (ends later, slower fade out)
  static const fadeOutInterval = Interval(0.3, 1.0, curve: Curves.easeIn);
  
  /// Staggered animation delay increment (for staggered lists)
  static const staggeredDelayIncrement = Duration(milliseconds: 50);
  
  /// Animation Methods

  /// Create a simple fade animation
  static Animation<double> fade(
    AnimationController controller, {
    double begin = 0.0,
    double end = 1.0,
    Curve curve = defaultCurve,
    Interval? interval,
  }) {
    return Tween<double>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: interval ?? const Interval(0.0, 1.0, curve: defaultCurve),
    ));
  }

  /// Create a slide animation
  static Animation<Offset> slide(
    AnimationController controller, {
    Offset begin = const Offset(0.0, 0.3),
    Offset end = Offset.zero,
    Curve curve = defaultCurve,
    Interval? interval,
  }) {
    return Tween<Offset>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: interval ?? const Interval(0.0, 1.0, curve: defaultCurve),
    ));
  }

  /// Create a scale animation
  static Animation<double> scale(
    AnimationController controller, {
    double begin = 0.8,
    double end = 1.0,
    Curve curve = defaultCurve,
    Interval? interval,
  }) {
    return Tween<double>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: interval ?? const Interval(0.0, 1.0, curve: defaultCurve),
    ));
  }
  
  /// Page transitions
  
  /// Slide and fade transition for pages
  static Widget slideAndFadeTransition({
    required BuildContext context,
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required Widget child,
    SlideDirection direction = SlideDirection.right,
  }) {
    // Determine the offset based on direction
    Offset beginOffset;
    switch (direction) {
      case SlideDirection.left:
        beginOffset = const Offset(-0.2, 0.0);
        break;
      case SlideDirection.right:
        beginOffset = const Offset(0.2, 0.0);
        break;
      case SlideDirection.up:
        beginOffset = const Offset(0.0, 0.2);
        break;
      case SlideDirection.down:
        beginOffset = const Offset(0.0, -0.2);
        break;
    }
    
    // Create optimized animations with better curve coordination
    
    // Primary animations (for entering page)
    final slideAnimation = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
    ));
    
    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
    ));
    
    // Secondary animations (for exiting page)
    final slideOutAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: -beginOffset * 1.5, // Slightly exaggerated for better effect
    ).animate(CurvedAnimation(
      parent: secondaryAnimation,
      curve: const Interval(0.1, 0.9, curve: Curves.easeInCubic),
    ));
    
    final fadeOutAnimation = Tween<double>(
      begin: 1.0,
      end: 0.3,
    ).animate(CurvedAnimation(
      parent: secondaryAnimation,
      curve: const Interval(0.0, 0.8, curve: Curves.easeInCubic),
    ));
    
    // Apply "damp" to reduce harsh motion and add subtle polish
    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: FadeTransition(
          opacity: fadeOutAnimation,
          child: SlideTransition(
            position: slideOutAnimation,
            child: child,
          ),
        ),
      ),
    );
  }
  
  /// Pure slide transition for pages (no fade effect)
  static Widget pureSlideTransition({
    required BuildContext context,
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required Widget child,
    SlideDirection direction = SlideDirection.right,
  }) {
    // Determine the offset based on direction
    Offset beginOffset;
    switch (direction) {
      case SlideDirection.left:
        beginOffset = const Offset(-0.2, 0.0);
        break;
      case SlideDirection.right:
        beginOffset = const Offset(0.2, 0.0);
        break;
      case SlideDirection.up:
        beginOffset = const Offset(0.0, 0.2);
        break;
      case SlideDirection.down:
        beginOffset = const Offset(0.0, -0.2);
        break;
    }
    
    // Primary animations (for entering page)
    final slideAnimation = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 0.9, curve: Curves.easeOutCubic),
    ));
    
    // Secondary animations (for exiting page)
    final slideOutAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: -beginOffset * 1.5, // Slightly exaggerated for better effect
    ).animate(CurvedAnimation(
      parent: secondaryAnimation,
      curve: const Interval(0.1, 1.0, curve: Curves.easeInCubic),
    ));
    
    return SlideTransition(
      position: slideAnimation,
      child: SlideTransition(
        position: slideOutAnimation,
        child: child,
      ),
    );
  }
  
  /// Fade scale transition for pages
  static Widget fadeScaleTransition({
    required BuildContext context,
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required Widget child,
  }) {
    // Improved animations with better timing
    
    // Primary animations (for entering page)
    final scaleAnimation = Tween<double>(
      begin: 0.95, // Less dramatic scale for smoother effect
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 0.85, curve: Curves.easeOutCubic),
    ));
    
    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 0.75, curve: Curves.easeOutCubic),
    ));
    
    // Secondary animations (for exiting page)
    final scaleOutAnimation = Tween<double>(
      begin: 1.0,
      end: 1.03, // Subtle scale up for exiting page
    ).animate(CurvedAnimation(
      parent: secondaryAnimation,
      curve: const Interval(0.1, 0.9, curve: Curves.easeInCubic),
    ));
    
    final fadeOutAnimation = Tween<double>(
      begin: 1.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: secondaryAnimation,
      curve: const Interval(0.0, 0.8, curve: Curves.easeInCubic),
    ));
    
    return FadeTransition(
      opacity: fadeAnimation,
      child: ScaleTransition(
        scale: scaleAnimation,
        child: FadeTransition(
          opacity: fadeOutAnimation,
          child: ScaleTransition(
            scale: scaleOutAnimation,
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }
  
  /// Shared axis transition for pages
  static Widget sharedAxisTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    SharedAxisTransitionType transitionType,
  ) {
    // Improved animation values with better timing and less jumpiness
    final fadeIn = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.1, 0.9, curve: Curves.easeOutCubic),
    );
    final fadeOut = CurvedAnimation(
      parent: secondaryAnimation,
      curve: const Interval(0.1, 0.85, curve: Curves.easeInCubic),
    );

    switch (transitionType) {
      case SharedAxisTransitionType.horizontal:
        // X-axis transition
        final inAnimation = Tween<Offset>(
          begin: const Offset(0.15, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.9, curve: Curves.easeOutCubic),
        ));
        
        final outAnimation = Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(-0.15, 0.0),
        ).animate(CurvedAnimation(
          parent: secondaryAnimation,
          curve: const Interval(0.1, 1.0, curve: Curves.easeInCubic),
        ));
        
        return FadeTransition(
          opacity: fadeIn,
          child: SlideTransition(
            position: inAnimation,
            child: FadeTransition(
              opacity: ReverseAnimation(fadeOut),
              child: SlideTransition(
                position: outAnimation,
                child: child,
              ),
            ),
          ),
        );
        
      case SharedAxisTransitionType.vertical:
        // Y-axis transition
        final inAnimation = Tween<Offset>(
          begin: const Offset(0.0, 0.15),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.9, curve: Curves.easeOutCubic),
        ));
        
        final outAnimation = Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0.0, -0.15),
        ).animate(CurvedAnimation(
          parent: secondaryAnimation,
          curve: const Interval(0.1, 1.0, curve: Curves.easeInCubic),
        ));
        
        return FadeTransition(
          opacity: fadeIn,
          child: SlideTransition(
            position: inAnimation,
            child: FadeTransition(
              opacity: ReverseAnimation(fadeOut),
              child: SlideTransition(
                position: outAnimation,
                child: child,
              ),
            ),
          ),
        );
        
      case SharedAxisTransitionType.scaled:
        // Z-axis transition
        final inAnimation = Tween<double>(
          begin: 0.92,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.9, curve: Curves.easeOutCubic),
        ));
        
        final outAnimation = Tween<double>(
          begin: 1.0,
          end: 1.08,
        ).animate(CurvedAnimation(
          parent: secondaryAnimation,
          curve: const Interval(0.1, 1.0, curve: Curves.easeInCubic),
        ));
        
        return FadeTransition(
          opacity: fadeIn,
          child: ScaleTransition(
            scale: inAnimation,
            child: FadeTransition(
              opacity: ReverseAnimation(fadeOut),
              child: ScaleTransition(
                scale: outAnimation,
                child: child,
              ),
            ),
          ),
        );
    }
  }
  
  /// Widget animations
  
  /// Animate a widget with scale animation
  static Widget scaleWidget(
    Widget child, {
    Duration duration = medium,
    double begin = 0.9,
    double end = 1.0,
    Curve curve = defaultCurve,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: begin, end: end),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }
  
  /// Animate a widget with fade animation
  static Widget fadeWidget(
    Widget child, {
    Duration duration = medium,
    double begin = 0.0,
    double end = 1.0,
    Curve curve = defaultCurve,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: begin, end: end),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: child,
    );
  }
  
  /// Animate a widget with slide animation
  static Widget slideWidget(
    Widget child, {
    Duration duration = medium,
    Offset begin = const Offset(0.0, 0.2),
    Offset end = Offset.zero,
    Curve curve = defaultCurve,
  }) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween<Offset>(begin: begin, end: end),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(
            value.dx * MediaQuery.of(context).size.width,
            value.dy * MediaQuery.of(context).size.height,
          ),
          child: child,
        );
      },
      child: child,
    );
  }
  
  /// Animate a widget with pulsate animation
  static Widget pulsate(
    Widget child, {
    Duration duration = const Duration(milliseconds: 1500),
    double minScale = 0.97,
    double maxScale = 1.03,
    Curve curve = Curves.easeInOut,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: minScale, end: maxScale),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      onEnd: () {
        // Reverse animation
        minScale = maxScale + minScale;
        maxScale = minScale - maxScale;
        minScale = minScale - maxScale;
      },
      child: child,
    );
  }
  
  /// Create staggered animation controller for a list
  static List<Animation<double>> createStaggeredAnimations({
    required AnimationController controller,
    required int itemCount,
    double startInterval = 0.0,
    double endInterval = 1.0,
    Duration staggerDuration = const Duration(milliseconds: 50),
  }) {
    final animations = <Animation<double>>[];
    final totalDuration = controller.duration?.inMilliseconds ?? 300;
    final itemDuration = (endInterval - startInterval) / itemCount;
    
    for (var i = 0; i < itemCount; i++) {
      final start = startInterval + (i * itemDuration);
      final end = start + itemDuration;
      
      animations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(start, end, curve: defaultCurve),
          ),
        ),
      );
    }
    
    return animations;
  }
}

/// Shared axis transition widget implementation
class SharedAxisTransition extends StatelessWidget {
  /// The animation that drives the transition.
  final Animation<double> animation;

  /// The animation that drives the secondary transition.
  final Animation<double> secondaryAnimation;

  /// The type of shared axis transition.
  final SharedAxisTransitionType transitionType;

  /// The child widget to animate.
  final Widget child;

  /// Creates a shared axis transition.
  const SharedAxisTransition({
    Key? key,
    required this.animation,
    required this.secondaryAnimation,
    required this.transitionType,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppAnimations.sharedAxisTransition(
      context, 
      animation, 
      secondaryAnimation, 
      child, 
      transitionType
    );
  }
}

/// Custom transition class for GetX page transitions
class GetPageCustomTransition extends CustomTransition {
  final Widget Function(BuildContext, Animation<double>, Animation<double>, Widget) transitionBuilder;
  
  GetPageCustomTransition({required this.transitionBuilder});
  
  @override
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return transitionBuilder(context, animation, secondaryAnimation, child);
  }
}

/// Shimmer effect implementation
class ShimmerEffect extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;

  const ShimmerEffect({
    Key? key,
    required this.child,
    required this.baseColor,
    required this.highlightColor,
    required this.duration,
  }) : super(key: key);

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              transform: _SlidingGradientTransform(
                slidePercent: _animation.value,
              ),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({
    required this.slidePercent,
  });

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

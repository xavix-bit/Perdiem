import 'package:flutter/material.dart';

class StickerCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? shadowColor;
  final double shadowOffset;
  final double? borderWidth;
  final double? borderRadius;
  final VoidCallback? onTap;
  final bool enableHoverEffect;

  const StickerCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.shadowColor,
    this.shadowOffset = 8,
    this.borderWidth,
    this.borderRadius,
    this.onTap,
    this.enableHoverEffect = true,
  });

  @override
  State<StickerCard> createState() => _StickerCardState();
}

class _StickerCardState extends State<StickerCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final borderC = widget.borderColor ??
        Theme.of(context).colorScheme.onSurface;
    final shadowC = widget.shadowColor ??
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1);
    final offset = _isHovered && widget.enableHoverEffect
        ? widget.shadowOffset + 4
        : widget.shadowOffset;
    final rotate = _isHovered && widget.enableHoverEffect ? -0.017 : 0.0; // ~-1deg

    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.elasticOut,
          transform: Matrix4.rotationZ(rotate)
            ..setTranslationRaw(0.0, _isHovered ? -2.0 : 0.0, 0.0),
          margin: widget.margin ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          decoration: BoxDecoration(
            color: widget.backgroundColor ??
                Theme.of(context).colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 12),
            border: Border.all(
              color: borderC,
              width: widget.borderWidth ?? 2,
            ),
            boxShadow: [
              BoxShadow(
                color: shadowC,
                offset: Offset(offset, offset),
                blurRadius: 0,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 12),
              child: Padding(
                padding: widget.padding ?? const EdgeInsets.all(16),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

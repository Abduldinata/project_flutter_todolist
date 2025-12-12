// utils/neumorphic_decoration.dart - FIXED VERSION
import 'package:flutter/material.dart';

class Neu {
  static BoxDecoration convex(BuildContext context, {Color? color, double? borderRadius}) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return BoxDecoration(
      color: color ?? colorScheme.surface,
      borderRadius: BorderRadius.circular(borderRadius ?? 12),
      boxShadow: _getConvexShadows(colorScheme, isDark),
    );
  }

  static BoxDecoration concave(BuildContext context, {Color? color, double? borderRadius}) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return BoxDecoration(
      color: color ?? colorScheme.surface,
      borderRadius: BorderRadius.circular(borderRadius ?? 12),
      boxShadow: _getConcaveShadows(colorScheme, isDark),
    );
  }

  static BoxDecoration pressed(BuildContext context, {Color? color, double? borderRadius}) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return BoxDecoration(
      color: color ?? colorScheme.surface,
      borderRadius: BorderRadius.circular(borderRadius ?? 12),
      boxShadow: _getPressedShadows(colorScheme, isDark),
    );
  }

  static List<BoxShadow> _getConvexShadows(ColorScheme colorScheme, bool isDark) {
    if (isDark) {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.6),
          offset: const Offset(4, 4),
          blurRadius: 8,
          spreadRadius: 1,
        ),
        BoxShadow(
          color: Colors.grey[900]!.withOpacity(0.4),
          offset: const Offset(-4, -4),
          blurRadius: 8,
          spreadRadius: 1,
        ),
      ];
    }
    
    return [
      BoxShadow(
        color: colorScheme.onSurface.withOpacity(0.1),
        offset: const Offset(-4, -4),
        blurRadius: 8,
        spreadRadius: 1,
      ),
      BoxShadow(
        color: colorScheme.onSurface.withOpacity(0.2),
        offset: const Offset(4, 4),
        blurRadius: 8,
        spreadRadius: 1,
      ),
    ];
  }

  static List<BoxShadow> _getConcaveShadows(ColorScheme colorScheme, bool isDark) {
    if (isDark) {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.8),
          offset: const Offset(3, 3),
          blurRadius: 8,
          spreadRadius: -2,
        ),
        BoxShadow(
          color: Colors.grey[900]!.withOpacity(0.2),
          offset: const Offset(-3, -3),
          blurRadius: 8,
          spreadRadius: -2,
        ),
      ];
    }
    
    return [
      BoxShadow(
        color: colorScheme.onSurface.withOpacity(0.15),
        offset: const Offset(3, 3),
        blurRadius: 8,
        spreadRadius: -2,
      ),
      BoxShadow(
        color: colorScheme.onSurface.withOpacity(0.05),
        offset: const Offset(-3, -3),
        blurRadius: 8,
        spreadRadius: -2,
      ),
    ];
  }

  static List<BoxShadow> _getPressedShadows(ColorScheme colorScheme, bool isDark) {
    if (isDark) {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.8),
          offset: const Offset(2, 2),
          blurRadius: 4,
          spreadRadius: -1,
        ),
        BoxShadow(
          color: Colors.grey[900]!.withOpacity(0.2),
          offset: const Offset(-2, -2),
          blurRadius: 4,
          spreadRadius: -1,
        ),
      ];
    }
    
    return [
      BoxShadow(
        color: colorScheme.onSurface.withOpacity(0.2),
        offset: const Offset(2, 2),
        blurRadius: 4,
        spreadRadius: -1,
      ),
      BoxShadow(
        color: colorScheme.onSurface.withOpacity(0.05),
        offset: const Offset(-2, -2),
        blurRadius: 4,
        spreadRadius: -1,
      ),
    ];
  }

  static BoxDecoration flat(BuildContext context, {Color? color, double? borderRadius}) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return BoxDecoration(
      color: color ?? colorScheme.surface,
      borderRadius: BorderRadius.circular(borderRadius ?? 12),
    );
  }
}
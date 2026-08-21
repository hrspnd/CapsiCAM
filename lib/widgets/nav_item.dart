// lib/widgets/nav_item.dart
//
// Shared bottom-nav item. Previously defined separately (and
// identically, aside from one deprecated-API drift) in the
// dashboard, scan history, and account screens.

import 'package:flutter/material.dart';

class NavItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final String? iconPath;

  const NavItem({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? Colors.white
        : Colors.white.withValues(alpha: 0.45);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (iconPath != null)
            Image.asset(
              iconPath!,
              width: 20,
              height: 20,
              color: color,
              errorBuilder: (_, __, ___) =>
                  Icon(Icons.history, color: color, size: 22),
            ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: color,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
} 
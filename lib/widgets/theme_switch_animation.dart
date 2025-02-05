import 'package:flutter/material.dart';

class ThemeSwitchAnimation extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;
  final Duration duration;

  const ThemeSwitchAnimation({
    Key? key,
    required this.isDark,
    required this.onTap,
    this.duration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: duration,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: isDark 
            ? Colors.blueGrey.shade900
            : Colors.blue.shade100,
        ),
        child: AnimatedSwitcher(
          duration: duration,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return RotationTransition(
              turns: animation,
              child: ScaleTransition(
                scale: animation,
                child: child,
              ),
            );
          },
          child: Icon(
            isDark ? Icons.dark_mode : Icons.light_mode,
            key: ValueKey<bool>(isDark),
            color: isDark ? Colors.amber : Colors.orange,
          ),
        ),
      ),
    );
  }
}

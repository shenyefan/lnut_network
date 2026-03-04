import 'package:flutter/material.dart';

class DarkInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffixIcon;
  final bool enabled;

  const DarkInput({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffixIcon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        enabled: enabled,
        style: TextStyle(
          fontSize: 15,
          color: enabled ? Colors.white : Colors.white.withValues(alpha: 0.5),
        ),
        cursorColor: const Color(0xFF5B8DEF),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: enabled ? Colors.white.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.15),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            size: 20,
            color: enabled ? Colors.white.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.15),
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}

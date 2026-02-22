import 'package:flutter/material.dart';
import 'widgets/gradient_button.dart';

class StatusView extends StatelessWidget {
  final Color accentColor;
  final IconData? icon;
  final bool loading;
  final String title;
  final String subtitle;
  final String? actionText;
  final Color? actionColor;
  final VoidCallback? onAction;

  const StatusView({
    super.key,
    required this.accentColor,
    this.icon,
    this.loading = false,
    required this.title,
    required this.subtitle,
    this.actionText,
    this.actionColor,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 40),
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [accentColor.withValues(alpha: 0.3), accentColor.withValues(alpha: 0.0)],
              radius: 1.2,
            ),
          ),
          child: Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withValues(alpha: 0.15),
                border: Border.all(color: accentColor.withValues(alpha: 0.4), width: 2),
              ),
              child: loading
                  ? Padding(
                      padding: const EdgeInsets.all(18),
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: accentColor),
                    )
                  : Icon(icon, size: 32, color: accentColor),
            ),
          ),
        ),
        const SizedBox(height: 36),
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.45),
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
        if (actionText != null && onAction != null) ...[
          const SizedBox(height: 48),
          OutlineActionButton(
            text: actionText!,
            color: actionColor ?? const Color(0xFF5B8DEF),
            onTap: onAction!,
          ),
        ],
        const SizedBox(height: 40),
      ],
    );
  }
}

import 'package:flutter/material.dart';

/// 下方有文字 + 实时数值的 Slider
class LabeledSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const LabeledSlider({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Row(
      children: [
        SizedBox(
          width: 96,
          child: Text(label, style: t.textTheme.bodyMedium),
        ),
        Expanded(
          child: Slider(
            value: value.clamp(min, max).toDouble(),
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 56,
          child: Text(
            value.toStringAsFixed(2),
            textAlign: TextAlign.end,
            style: t.textTheme.labelMedium,
          ),
        ),
      ],
    );
  }
}

/// 圆角填充按钮（你原来的 FilledButton）
class EditorFilledButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onPressed;   // ← 必须 nullable !
  final Color? filledColor;
  final Color? textColor;

  const EditorFilledButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.filledColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final bg = filledColor ?? const Color(0xFFEFF3EF);
    final fg = textColor ?? Colors.black87;

    return SizedBox(
      height: 48,
      child: ElevatedButton.icon(
        onPressed: onPressed,            // ← 可以直接传 null
        icon: Icon(icon),
        label: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

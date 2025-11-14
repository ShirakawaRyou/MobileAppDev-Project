// lib/pages/editor/editor_photo_controls.dart

import 'package:flutter/material.dart';
import 'editor_models.dart';
import 'editor_common_widgets.dart';

class PhotoBottomControls extends StatelessWidget {
  const PhotoBottomControls({
    super.key,
    required this.tab,
    required this.onTabChanged,
    required this.rotation,
    required this.onRotation,
    required this.brightness,
    required this.contrast,
    required this.saturation,
    required this.temperature,
    required this.onBrightness,
    required this.onContrast,
    required this.onSaturation,
    required this.onTemperature,
    required this.onImport,
    required this.onExport,
    required this.background,
  });

  final EditorTab tab;
  final ValueChanged<EditorTab> onTabChanged;

  final double rotation;
  final ValueChanged<double> onRotation;

  final double brightness, contrast, saturation, temperature;
  final ValueChanged<double> onBrightness,
      onContrast,
      onSaturation,
      onTemperature;

  final VoidCallback onImport, onExport;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SegmentedTabs(current: tab, onChanged: onTabChanged),
            const SizedBox(height: 10),

            // 内容卡片
            Container(
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(EditorConstants.radius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: _buildToolPanel(theme),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: EditorFilledButton(
                    text: 'Import',
                    icon: Icons.download_outlined,
                    onPressed: onImport,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: EditorFilledButton(
                    text: 'Export',
                    icon: Icons.upload_outlined,
                    filledColor: EditorConstants.green,
                    textColor: Colors.white,
                    onPressed: onExport,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolPanel(ThemeData theme) {
    switch (tab) {
      case EditorTab.clip:
        return Center(
          child: Text('Use Clip to crop image.',
              style: theme.textTheme.bodyMedium),
        );

      case EditorTab.rotate:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rotate',
                style: theme.textTheme.titleMedium!
                    .copyWith(fontWeight: FontWeight.w700)),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.rotate_left),
                  onPressed: () =>
                      onRotation((rotation - 90.0).clamp(-180.0, 180.0)),
                ),
                Expanded(
                  child: Slider(
                    value: rotation,
                    min: -180,
                    max: 180,
                    onChanged: onRotation,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.rotate_right),
                  onPressed: () =>
                      onRotation((rotation + 90.0).clamp(-180.0, 180.0)),
                ),
              ],
            )
          ],
        );

      case EditorTab.adjust:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Adjust',
                    style: theme.textTheme.titleMedium!
                        .copyWith(fontWeight: FontWeight.w700)),
                TextButton(
                  onPressed: () {
                    onBrightness(0);
                    onContrast(1);
                    onSaturation(1);
                    onTemperature(0);
                  },
                  style:
                      TextButton.styleFrom(foregroundColor: EditorConstants.green),
                  child: const Text('Reset'),
                )
              ],
            ),
            const SizedBox(height: 6),
            LabeledSlider(
              label: 'Brightness',
              value: brightness,
              min: -1,
              max: 1,
              onChanged: onBrightness,
            ),
            LabeledSlider(
              label: 'Contrast',
              value: contrast,
              min: 0,
              max: 2,
              onChanged: onContrast,
            ),
            LabeledSlider(
              label: 'Saturation',
              value: saturation,
              min: 0,
              max: 2,
              onChanged: onSaturation,
            ),
            LabeledSlider(
              label: 'Temperature',
              value: temperature,
              min: -1,
              max: 1,
              onChanged: onTemperature,
            ),
          ],
        );
    }
  }
}

/// 顶部三段切换按钮
class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs({required this.current, required this.onChanged});
  final EditorTab current;
  final ValueChanged<EditorTab> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF171B20) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          _btn('Clip', EditorTab.clip),
          _btn('Rotate', EditorTab.rotate),
          _btn('Adjust', EditorTab.adjust),
        ],
      ),
    );
  }

  Expanded _btn(String label, EditorTab tab) {
    final selected = tab == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(tab),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color:
                selected ? EditorConstants.green : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

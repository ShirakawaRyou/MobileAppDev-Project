// lib/pages/editor/editor_video_controls.dart

import 'package:flutter/material.dart';
import 'editor_models.dart';
import 'editor_common_widgets.dart';

class VideoControls extends StatelessWidget {
  const VideoControls({
    super.key,
    required this.background,
    required this.onImportVideo,
    required this.onTrimVideo,
    required this.onExportVideo,
  });

  final Color background;

  final VoidCallback onImportVideo;
  final VoidCallback onTrimVideo;
  final VoidCallback onExportVideo;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Video Tools",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),

                  // Import + Trim
                  Row(
                    children: [
                      Expanded(
                        child: EditorFilledButton(
                          text: "Import",
                          icon: Icons.video_call_outlined,
                          onPressed: onImportVideo,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: EditorFilledButton(
                          text: "Trim",
                          icon: Icons.cut,
                          onPressed: onTrimVideo,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Export
                  Row(
                    children: [
                      Expanded(
                        child: EditorFilledButton(
                          text: "Export",
                          icon: Icons.upload_outlined,
                          filledColor: EditorConstants.green,
                          textColor: Colors.white,
                          onPressed: onExportVideo,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

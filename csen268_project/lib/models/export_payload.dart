import 'dart:io';

class ExportPayload {
  ExportPayload({
    required this.mediaFile,
    required this.projectName,
    this.previewImage,
    this.duration,
  });

  final File mediaFile;
  final File? previewImage;
  final String projectName;
  final Duration? duration;

  bool get isVideo {
    final lower = mediaFile.path.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.m4v') ||
        lower.endsWith('.avi');
  }
}

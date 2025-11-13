import 'package:csen268_project/models/export_payload.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key, this.payload});

  final ExportPayload? payload;

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  static const String _fallbackPreviewUrl =
      'https://images.unsplash.com/photo-1507525428034-b723cf961d3e';
  String _selectedResolution = '1080p';
  String _selectedFps = '30 fps';
  double _previewAspect = 16 / 9;

  final List<String> _resolutions = ['720p', '1080p', '4K'];
  final List<String> _fpsOptions = ['24 fps', '30 fps', '60 fps'];

  VideoPlayerController? _controller;
  bool _isVideo = false;
  bool _isControllerReady = false;
  bool _isSaving = false;
  String? _shareInProgress;

  @override
  void initState() {
    super.initState();
    _previewAspect = _aspectFromResolution(_selectedResolution);
    _initMedia();
  }

  @override
  void didUpdateWidget(covariant ExportScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldPath = oldWidget.payload?.mediaFile.path;
    final newPath = widget.payload?.mediaFile.path;
    if (oldPath != newPath) {
      _disposeController();
      _initMedia();
    }
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  bool get _hasMedia {
    final file = widget.payload?.mediaFile;
    if (file == null) return false;
    return file.existsSync();
  }

  Future<void> _initMedia() async {
    final payload = widget.payload;
    if (payload == null || !_hasMedia) return;
    _isVideo = payload.isVideo;
    if (!_isVideo) {
      setState(() => _isControllerReady = false);
      return;
    }

    final controller = VideoPlayerController.file(payload.mediaFile);
    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.play();
    } catch (e) {
      controller.dispose();
      _showError('Failed to load video preview: $e');
      return;
    }

    if (!mounted) {
      controller.dispose();
      return;
    }

    setState(() {
      _controller = controller;
      _isControllerReady = true;
    });
    _applyFpsToPreview();
  }

  void _disposeController() {
    _controller?.dispose();
    _controller = null;
    _isControllerReady = false;
    _isVideo = false;
  }

  void _applyFpsToPreview() {
    if (!_isVideo || _controller == null) return;
    double speed = 1.0;
    switch (_selectedFps) {
      case '24 fps':
        speed = 0.8;
        break;
      case '60 fps':
        speed = 1.5;
        break;
      default:
        speed = 1.0;
    }
    _controller!.setPlaybackSpeed(speed);
  }

  double _aspectFromResolution(String value) {
    switch (value) {
      case '720p':
      case '1080p':
      case '4K':
        return 16 / 9;
      default:
        return 16 / 9;
    }
  }

  @override
  Widget build(BuildContext context) {
    final payload = widget.payload;
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Export',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () {
            final router = GoRouter.of(context);
            if (router.canPop()) {
              router.pop();
            } else {
              context.go('/editor');
            }
          },
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPreviewCard(payload),
                      const SizedBox(height: 32),
                      const Text(
                        'Settings',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildResolutionRow(),
                      const SizedBox(height: 12),
                      _buildFpsRow(),
                      const SizedBox(height: 32),
                      const Text(
                        'Share',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildShareButton(
                            Icons.facebook,
                            'Facebook',
                            () => _shareToPlatform('Facebook'),
                          ),
                          _buildShareButton(
                            Icons.video_library,
                            'YouTube',
                            () => _shareToPlatform('YouTube'),
                          ),
                          _buildShareButton(
                            Icons.music_note,
                            'TikTok',
                            () => _shareToPlatform('TikTok'),
                          ),
                          _buildShareButton(
                            Icons.camera_alt,
                            'Instagram',
                            () => _shareToPlatform('Instagram'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 36),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveToDevice,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00A86B),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Save to Device',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPreviewCard(ExportPayload? payload) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: _previewAspect,
        child: _buildPreviewContent(payload),
      ),
    );
  }

  Widget _buildPreviewContent(ExportPayload? payload) {
    if (!_hasMedia || payload == null) {
      return _buildFallbackPreview();
    }

    if (_isVideo) {
      if (!_isControllerReady || _controller == null) {
        return const ColoredBox(
          color: Color(0xFF101010),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      return FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _controller!.value.size.width,
          height: _controller!.value.size.height,
          child: VideoPlayer(_controller!),
        ),
      );
    }

    final file = payload.previewImage ?? payload.mediaFile;
    return Image.file(
      file,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildFallbackPreview(),
    );
  }

  Widget _buildFallbackPreview() {
    return Image.network(
      _fallbackPreviewUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: Colors.grey[300],
      ),
    );
  }

  Widget _buildResolutionRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Resolution',
          style: TextStyle(
            fontSize: 15,
            color: Colors.black,
          ),
        ),
        DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedResolution,
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black),
            items: _resolutions
                .map(
                  (res) => DropdownMenuItem(
                    value: res,
                    child: Text(
                      res,
                      style: const TextStyle(
                        color: Colors.teal,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _selectedResolution = value;
                _previewAspect = _aspectFromResolution(value);
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFpsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Frame Rate',
          style: TextStyle(
            fontSize: 15,
            color: Colors.black,
          ),
        ),
        DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedFps,
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black),
            items: _fpsOptions
                .map(
                  (fps) => DropdownMenuItem(
                    value: fps,
                    child: Text(
                      fps,
                      style: const TextStyle(
                        color: Colors.teal,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() => _selectedFps = value);
              _applyFpsToPreview();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildShareButton(IconData icon, String label, VoidCallback onTap) {
    final bool isBusy = _shareInProgress == label;
    return GestureDetector(
      onTap: isBusy ? null : onTap,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE6F6EF),
              borderRadius: BorderRadius.circular(36),
            ),
            padding: const EdgeInsets.all(14),
            child: isBusy
                ? const SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(strokeWidth: 2.2),
                  )
                : Icon(icon, color: Colors.teal, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Future<void> _saveToDevice() async {
    final payload = widget.payload;
    if (payload == null || !_hasMedia) {
      _showMissingMedia();
      return;
    }

    final PermissionState status = await PhotoManager.requestPermissionExtend();
    if (!status.isAuth) {
      _showError('Please grant photo permissions before trying again.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      AssetEntity? saved;
      if (payload.isVideo) {
        saved = await PhotoManager.editor.saveVideo(payload.mediaFile);
      } else {
        saved = await PhotoManager.editor.saveImageWithPath(payload.mediaFile.path);
      }
      if (!mounted) return;
      final message = saved != null
          ? 'Saved to gallery successfully.'
          : 'Save failed, please try again later.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      _showError('Export failed: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _shareToPlatform(String platform) async {
    final payload = widget.payload;
    if (payload == null || !_hasMedia) {
      _showMissingMedia();
      return;
    }

    setState(() => _shareInProgress = platform);
    try {
      await Share.shareXFiles(
        [XFile(payload.mediaFile.path)],
        subject: payload.projectName,
        text: 'Sharing my project on $platform: ${payload.projectName}',
      );
    } catch (e) {
      _showError('Share failed: $e');
    } finally {
      if (mounted) {
        setState(() => _shareInProgress = null);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showMissingMedia() {
    _showError('No exportable project found. Please finish editing before exporting.');
  }
}

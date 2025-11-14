// lib/pages/editor/trim_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_editor/video_editor.dart';

import 'editor_common_widgets.dart';
import 'editor_models.dart';

class TrimPage extends StatefulWidget {
  final File videoFile;

  const TrimPage({super.key, required this.videoFile});

  @override
  State<TrimPage> createState() => _TrimPageState();
}

class _TrimPageState extends State<TrimPage> {
  late final VideoEditorController _controller;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _controller = VideoEditorController.file(
      widget.videoFile,
      minDuration: const Duration(seconds: 1),
      maxDuration: const Duration(seconds: 30),
    )..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 这里“保存”只是记录当前的 startTrim / endTrim，
  /// 然后把原始文件路径返回给上一页（不会生成新的视频文件）
  Future<void> _saveTrim() async {
    setState(() => _isSaving = true);

    final start = _controller.startTrim;
    final end = _controller.endTrim;

    // TODO: 如果以后接后端 / ffmpeg，可以把 start/end 一起传出去做真正导出
    debugPrint('Selected trim range: $start -> $end');

    setState(() => _isSaving = false);

    if (!mounted) return;
    Navigator.pop(context, widget.videoFile.path);
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Trim Video')),
      body: Column(
        children: [
          // 预览区域
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(EditorConstants.radius),
                child: CropGridViewer.preview(
                  controller: _controller,
                ),
              ),
            ),
          ),

          // Trim 滑条 + 时间轴
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TrimSlider(
              controller: _controller,
              height: 60,
              child: TrimTimeline(
                controller: _controller,
                padding: const EdgeInsets.only(top: 8),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Save 按钮
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: EditorFilledButton(
              text: _isSaving ? 'Saving...' : 'Save Trim Range',
              icon: Icons.check,
              filledColor: EditorConstants.green,
              textColor: Colors.white,
              onPressed: _isSaving ? null : () => _saveTrim(),
            ),
          ),
        ],
      ),
    );
  }
}

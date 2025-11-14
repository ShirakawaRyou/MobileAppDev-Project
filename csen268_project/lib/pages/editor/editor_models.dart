
// lib/editor/editor_models.dart
import 'package:flutter/material.dart';

/// 照片编辑 Tab
enum EditorTab { clip, rotate, adjust }

/// 编辑模式：照片 / 视频
enum EditMode { photo, video }

/// 一些 Editor 用到的常量
class EditorConstants {
  static const Color green = Color(0xFF4BAE61);
  static const double radius = 16.0;
}

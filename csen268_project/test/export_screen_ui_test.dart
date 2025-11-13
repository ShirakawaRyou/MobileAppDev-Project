import 'dart:io';

import 'package:csen268_project/models/export_payload.dart';
import 'package:csen268_project/pages/export_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ExportScreen UI interactions', () {
    late File tempFile;

    setUp(() async {
      tempFile = await _createTempImage();
    });

    tearDown(() async {
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    });

    testWidgets('allows changing resolution and fps', (tester) async {
      final payload = ExportPayload(
        mediaFile: tempFile,
        previewImage: tempFile,
        projectName: 'Demo Project',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ExportScreen(payload: payload),
        ),
      );

      final resolutionFinder = find.text('1080p');
      await tester.ensureVisible(resolutionFinder);
      expect(resolutionFinder, findsOneWidget);
      await tester.tap(resolutionFinder);
      await tester.pumpAndSettle();
      await tester.tap(find.text('720p').last);
      await tester.pumpAndSettle();
      expect(find.text('720p'), findsOneWidget);
      final fpsFinder = find.text('30 fps').first;
      await tester.ensureVisible(fpsFinder);
      expect(fpsFinder, findsOneWidget);
      await tester.tap(fpsFinder);
      await tester.pumpAndSettle();
      await tester.tap(find.text('60 fps').last);
      await tester.pumpAndSettle();
      expect(find.text('60 fps'), findsOneWidget);
    });
  });
}

Future<File> _createTempImage() async {
  final file = File('${Directory.systemTemp.path}/export_screen_ui_test.jpg');
  await file.writeAsBytes(List<int>.filled(10, 0));
  return file;
}

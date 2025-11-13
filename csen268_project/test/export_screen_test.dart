import 'package:csen268_project/models/export_payload.dart';
import 'package:csen268_project/pages/export_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:io';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('ExportScreen shows fallback content when no payload',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ExportScreen(),
      ),
    );

    expect(find.text('Export'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Resolution'), findsOneWidget);
    expect(find.text('Frame Rate'), findsOneWidget);
    expect(find.text('Share'), findsOneWidget);
    expect(find.text('Save to Device'), findsOneWidget);
  });

  testWidgets('ExportScreen renders with provided payload', (tester) async {
    final tempFile = await _createTempImage();
    final payload =
        ExportPayload(mediaFile: tempFile, previewImage: tempFile, projectName: 'Temp Project');

    await tester.pumpWidget(
      MaterialApp(
        home: ExportScreen(payload: payload),
      ),
    );

    expect(find.text('Temp Project'), findsOneWidget);
    expect(find.textContaining('1080p'), findsWidgets);
    expect(find.textContaining('30 fps'), findsWidgets);
  });
}

Future<File> _createTempImage() async {
  final file = File('${Directory.systemTemp.path}/temp_image.jpg');
  await file.writeAsBytes(List<int>.filled(10, 0));
  return file;
}

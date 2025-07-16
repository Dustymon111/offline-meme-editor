import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meme_editor/features/editor/domain/entities/meme_element.dart';
import 'package:meme_editor/features/editor/presentation/widgets/draggable_element.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:saver_gallery/saver_gallery.dart';

class ExportPage extends StatelessWidget {
  final String imageUrl;
  final List<MemeElement> elements;
  final GlobalKey _memeKey = GlobalKey();

  ExportPage({super.key, required this.imageUrl, required this.elements});

  Future<void> _saveToGallery(BuildContext context) async {
    final bytes = await _captureMemeImage();
    if (bytes == null) return;

    final permission = await _requestGalleryPermissionWithSettings(context);
    if (!permission) return;

    try {
      await SaverGallery.saveImage(
        bytes,
        fileName: 'meme_${DateTime.now().millisecondsSinceEpoch}',
        skipIfExists: false,
      );

      Fluttertoast.showToast(
        msg: 'Meme saved to gallery!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (e) {
      debugPrint('Error saving: $e');
    }
  }

  Future<void> _shareMeme(BuildContext context) async {
    final bytes = await _captureMemeImage();
    if (bytes == null) return;

    try {
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/meme_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes);

      final result = await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], text: 'Check out my meme!'),
      );

      if (result.status == ShareResultStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meme shared!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error sharing: $e');
    }
  }

  Future<Uint8List?> _captureMemeImage() async {
    try {
      final boundary =
          _memeKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Capture error: $e');
      return null;
    }
  }

  Future<bool> _requestGalleryPermissionWithSettings(
    BuildContext context,
  ) async {
    PermissionStatus status;

    if (Platform.isAndroid) {
      status = await Permission.photos.request();
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }
    } else if (Platform.isIOS) {
      status = await Permission.photos.request();
    } else {
      status = PermissionStatus.granted;
    }

    if (status.isDenied || status.isPermanentlyDenied) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Permission Required'),
          content: const Text('Please allow storage access in settings.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                openAppSettings();
                Navigator.pop(context);
              },
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );
      return false;
    }

    return status.isGranted;
  }

  @override
  Widget build(BuildContext context) {
    final imageWidget = File(imageUrl).existsSync()
        ? Image.file(File(imageUrl), fit: BoxFit.contain)
        : const Icon(Icons.broken_image);

    return Scaffold(
      appBar: AppBar(title: const Text('Export Meme')),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: RepaintBoundary(
                key: _memeKey,
                child: Stack(
                  children: [
                    Positioned.fill(child: imageWidget),
                    ...elements.map((e) => DraggableMemeElement(element: e)),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _saveToGallery(context),
                  icon: const Icon(Icons.download),
                  label: const Text('Save to Gallery'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _shareMeme(context),
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meme_editor/features/editor/presentation/pages/export_page.dart';
import 'package:meme_editor/features/editor/presentation/provider/editor_provider.dart';
import 'package:meme_editor/features/editor/presentation/widgets/draggable_element.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/meme_element.dart';
import 'package:uuid/uuid.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saver_gallery/saver_gallery.dart';

class EditorPage extends StatelessWidget {
  final String imageUrl;
  final bool isOnline;
  final GlobalKey _memeKey = GlobalKey();

  EditorPage({required this.imageUrl, required this.isOnline, super.key});

  Future<void> _pickSticker(
    BuildContext context,
    EditorProvider provider,
  ) async {
    final hasPermission = await _requestGalleryPermissionWithSettings(context);
    if (!hasPermission) return;

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);

      if (picked != null) {
        final id = const Uuid().v4();
        provider.addElement(
          MemeElement(
            id: id,
            type: MemeElementType.sticker,
            x: 100,
            y: 100,
            content: picked.path,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveMemeToGallery(BuildContext context) async {
    try {
      final boundary =
          _memeKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to capture meme. Please try again.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to process image. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      final pngBytes = byteData.buffer.asUint8List();

      final permission = await _requestGalleryPermissionWithSettings(context);
      if (!permission) return;

      await SaverGallery.saveImage(
        pngBytes,
        fileName: 'meme_${DateTime.now().millisecondsSinceEpoch}',
        skipIfExists: false,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meme saved to gallery successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('Error saving meme: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save meme: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
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
      debugPrint('Error capturing meme: $e');
      return null;
    }
  }

  Future<void> _shareMeme(BuildContext context) async {
    final bytes = await _captureMemeImage();
    if (bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to capture meme'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Get temporary directory
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/shared_meme_${DateTime.now().millisecondsSinceEpoch}.png',
      );

      // Write bytes to file
      await file.writeAsBytes(bytes);

      final result = await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Check out this awesome meme!',
          subject: 'My Meme Creation',
        ),
      );

      if (result.status == ShareResultStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meme shared successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (result.status == ShareResultStatus.dismissed) {
        debugPrint('Share dismissed by user');
      }
    } catch (e) {
      debugPrint('Error sharing meme: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to share meme: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> _requestGalleryPermissionWithSettings(
    BuildContext context,
  ) async {
    PermissionStatus status;

    if (Platform.isAndroid) {
      // Android 13+
      status = await Permission.photos.request();
      if (!status.isGranted) {
        // Fallback for older devices
        status = await Permission.storage.request();
      }
    } else if (Platform.isIOS) {
      status = await Permission.photos.request();
    } else {
      status = PermissionStatus.granted;
    }

    if (status.isDenied) {
      final shouldOpenSettings = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Permission Required'),
          content: const Text(
            'This app needs access to your photos to save and share memes. Would you like to open settings to grant permission?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );

      if (shouldOpenSettings == true) {
        await openAppSettings();
      }
      return false;
    }

    if (status.isPermanentlyDenied) {
      // Show dialog for permanently denied
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Permission Permanently Denied'),
          content: const Text(
            'Gallery access has been permanently denied. Please enable it in app settings to save and access memes.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
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
    final provider = Provider.of<EditorProvider>(context);

    final imageWidget = File(imageUrl).existsSync()
        ? Image.file(
            File(imageUrl),
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
          )
        : const Icon(Icons.broken_image);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meme Editor'),
        actions: [
          IconButton(icon: const Icon(Icons.undo), onPressed: provider.undo),
          IconButton(icon: const Icon(Icons.redo), onPressed: provider.redo),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Text',
            onPressed: () {
              final id = const Uuid().v4();
              provider.addElement(
                MemeElement(
                  id: id,
                  type: MemeElementType.text,
                  x: 100,
                  y: 100,
                  content: 'New Text',
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.image),
            tooltip: 'Add Sticker',
            onPressed: () => _pickSticker(context, provider),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share Meme',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ExportPage(imageUrl: imageUrl, elements: provider.elements),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: RepaintBoundary(
          key: _memeKey,
          child: Stack(
            children: [
              Positioned.fill(child: imageWidget),
              ...provider.elements.map((e) => DraggableMemeElement(element: e)),
            ],
          ),
        ),
      ),
    );
  }
}

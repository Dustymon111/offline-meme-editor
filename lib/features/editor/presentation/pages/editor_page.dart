import 'dart:io';
import 'package:flutter/material.dart';
import 'package:meme_editor/features/editor/presentation/provider/editor_provider.dart';
import 'package:meme_editor/features/editor/presentation/widgets/draggable_element.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/meme_element.dart';
import 'package:uuid/uuid.dart';

class EditorPage extends StatelessWidget {
  final String imageUrl;
  final bool isOnline;

  const EditorPage({required this.imageUrl, required this.isOnline, super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EditorProvider>(context);

    final imageWidget = isOnline
        ? Image.network(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
          )
        : File(imageUrl).existsSync()
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
        ],
      ),
      body: Stack(
        children: [
          // Background meme image
          Positioned.fill(child: imageWidget),

          // Meme elements (text/sticker)
          ...provider.elements.map((e) => DraggableMemeElement(element: e)),
        ],
      ),
    );
  }
}

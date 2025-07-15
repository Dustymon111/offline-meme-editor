import 'package:flutter/material.dart';
import 'package:meme_editor/features/editor/presentation/provider/editor_provider.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/meme_element.dart';

class DraggableMemeElement extends StatefulWidget {
  final MemeElement element;

  const DraggableMemeElement({required this.element, super.key});

  @override
  State<DraggableMemeElement> createState() => _DraggableMemeElementState();
}

class _DraggableMemeElementState extends State<DraggableMemeElement> {
  late Offset position;

  @override
  void initState() {
    super.initState();
    position = Offset(widget.element.x, widget.element.y);
  }

  @override
  void didUpdateWidget(covariant DraggableMemeElement oldWidget) {
    // In case external updates happen (e.g. from undo/redo)
    if (oldWidget.element.x != widget.element.x ||
        oldWidget.element.y != widget.element.y) {
      position = Offset(widget.element.x, widget.element.y);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EditorProvider>(context, listen: false);

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            position += details.delta;
          });
        },
        onPanEnd: (_) {
          final updated = widget.element.copyWith(
            x: position.dx,
            y: position.dy,
          );
          provider.updateElement(widget.element.id!, updated);
          provider.saveToHistory();
        },
        child: _buildContent(widget.element),
      ),
    );
  }

  Widget _buildContent(MemeElement element) {
    if (element.type == MemeElementType.text) {
      return GestureDetector(
        onTap: () => _showTextEditDialog(element),
        child: Text(
          element.content,
          style: const TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(blurRadius: 2, color: Colors.black)],
          ),
        ),
      );
    } else {
      return Image.asset(element.content, width: 60, height: 60);
    }
  }

  void _showTextEditDialog(MemeElement element) {
    final provider = Provider.of<EditorProvider>(context, listen: false);
    final current = provider.elements.firstWhere((e) => e.id == element.id);

    final controller = TextEditingController(text: current.content);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Text'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter new text'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newText = controller.text.trim();
              if (newText.isNotEmpty) {
                provider.updateElement(
                  current.id!,
                  current.copyWith(content: newText), // uses latest x/y
                );
                provider.saveToHistory();
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

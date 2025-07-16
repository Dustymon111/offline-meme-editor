import 'dart:io';

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
  late double scale;
  Offset? _startFocalPoint;
  Offset? _startPosition;
  double? _startScale;

  @override
  void initState() {
    super.initState();
    position = Offset(widget.element.x, widget.element.y);
    scale = widget.element.scale ?? 1.0;
  }

  @override
  void didUpdateWidget(covariant DraggableMemeElement oldWidget) {
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
        onScaleStart: (details) {
          _startFocalPoint = details.focalPoint;
          _startPosition = position;
          _startScale = scale;
        },
        onScaleUpdate: (details) {
          setState(() {
            final dx = details.focalPoint.dx - _startFocalPoint!.dx;
            final dy = details.focalPoint.dy - _startFocalPoint!.dy;
            position = _startPosition! + Offset(dx, dy);
            scale = (_startScale! * details.scale).clamp(0.5, double.infinity);
          });
        },
        onScaleEnd: (_) {
          final updated = widget.element.copyWith(
            x: position.dx,
            y: position.dy,
            scale: scale,
          );
          provider.updateElement(widget.element.id!, updated);
          provider.saveToHistory();
        },
        child: _ScaledBox(scale: scale, child: _buildContent(widget.element)),
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
      return Image.file(
        File(element.content),
        width: 60,
        height: 60,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
      );
    }
  }

  void _showTextEditDialog(MemeElement element) async {
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
            onPressed: () async {
              final newText = controller.text.trim();
              if (newText.isNotEmpty) {
                provider.updateElement(
                  current.id!,
                  current.copyWith(content: newText),
                );
                provider.saveToHistory();
                await provider.saveMeme();
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

class _ScaledBox extends StatelessWidget {
  final double scale;
  final Widget child;
  final double padding;

  const _ScaledBox({
    required this.scale,
    required this.child,
    this.padding = 30,
  });

  @override
  Widget build(BuildContext context) {
    final size = 60 * scale;

    return Container(
      width: size + padding,
      height: size + padding,
      alignment: Alignment.center,
      color: Colors.transparent,
      child: SizedBox(
        width: size,
        height: size,
        child: FittedBox(fit: BoxFit.contain, child: child),
      ),
    );
  }
}

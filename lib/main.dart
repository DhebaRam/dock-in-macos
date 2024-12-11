import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Dock(
                items: [
                  Icons.camera,
                  Icons.photo,
                  Icons.person,
                  Icons.message,
                  Icons.call,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Dock extends StatefulWidget {
  const Dock({super.key, required this.items});

  final List<IconData> items;

  @override
  State<Dock> createState() => _DockState();
}

class _DockState extends State<Dock> {
  late List<IconData> _items;
  int? _draggingIndex;
  int? _hoveringIndex;

  @override
  void initState() {
    super.initState();
    _items = widget.items.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black12,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_items.length, (index) {
          final isDragging = _draggingIndex == index;
          final isHovered = _hoveringIndex == index;

          return MouseRegion(
            onEnter: (_) {
              setState(() {
                _hoveringIndex = index;
              });
            },
            onExit: (_) {
              setState(() {
                _hoveringIndex = null;
              });
            },
            child: Draggable<int>(
              data: index,
              feedback: Material(
                color: Colors.transparent,
                child: _buildDockItem(
                  _items[index],
                  isHovered: false,
                  isDragging: true,
                ),
              ),
              childWhenDragging: const SizedBox(width: 48),
              onDragStarted: () {
                setState(() {
                  _draggingIndex = index;
                  _hoveringIndex = index;
                });
              },
              onDraggableCanceled: (_, __) {
                setState(() {
                  _draggingIndex = null;
                  _hoveringIndex = null;
                });
              },
              onDragCompleted: () {
                setState(() {
                  _draggingIndex = null;
                  _hoveringIndex = null;
                });
              },
              child: DragTarget<int>(
                onWillAcceptWithDetails: (draggedIndex) => draggedIndex.data != index,
                onAccept: (draggedIndex) {
                  setState(() {
                    final draggedItem = _items.removeAt(draggedIndex);
                    _items.insert(index, draggedItem);
                    _draggingIndex = null;
                    _hoveringIndex = null;
                  });
                },
                builder: (context, candidateData, rejectedData) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    transform: isDragging || isHovered
                        ? Matrix4.diagonal3Values(1.2, 1.2, 1)
                        : Matrix4.identity(),
                    child: _buildDockItem(
                      _items[index],
                      isHovered: isHovered,
                      isDragging: isDragging,
                    ),
                  );
                },
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDockItem(IconData icon,
      {required bool isHovered, required bool isDragging}) {
    return Container(
      width: isHovered || isDragging ? 64 : 48,
      height: isHovered || isDragging ? 64 : 48,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.primaries[icon.hashCode % Colors.primaries.length],
        borderRadius: BorderRadius.circular(12),
        boxShadow: isHovered || isDragging
            ? [BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.3))]
            : [],
      ),
      child: Icon(icon, color: Colors.white, size: isHovered || isDragging ? 32 : 24),
    );
  }
}

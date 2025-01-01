import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class CardTodoListWidget extends StatefulWidget {
  const CardTodoListWidget({
    super.key,
    required this.getIndex,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.isDone,
    required this.onDelete,
    required this.onToggleDone,
    required this.category,
  });

  final int getIndex;
  final String title;
  final String description;
  final String category;
  final String date;
  final String time;
  final bool isDone;
  final VoidCallback onDelete;
  final ValueChanged<bool?> onToggleDone;

  @override
  _CardTodoListWidgetState createState() => _CardTodoListWidgetState();
}

class _CardTodoListWidgetState extends State<CardTodoListWidget> {
  late bool isDone;

  @override
  void initState() {
    super.initState();
    isDone = widget.isDone;
  }

  @override
  Widget build(BuildContext context) {
    Color categoryColor = _getCategoryColor(widget.category);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Warna kategori di sisi kiri
          Container(
            decoration: BoxDecoration(
              color: categoryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
            ),
            width: 20,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ListTile(
                    leading: IconButton(
                      onPressed: widget.onDelete,
                      icon: const Icon(Icons.delete),
                    ),
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        decoration: isDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            decoration:
                                isDone ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        const Gap(5),
                      ],
                    ),
                    trailing: Transform.scale(
                      scale: 1.5,
                      child: Checkbox(
                        activeColor: Colors.blue.shade800,
                        shape: const CircleBorder(),
                        value: isDone,
                        onChanged: (value) {
                          setState(() {
                            isDone = value!;
                          });
                          widget.onToggleDone(value);
                        },
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -12),
                    child: Column(
                      children: [
                        Divider(
                          thickness: 1.5,
                          color: Colors.grey.shade200,
                        ),
                        Row(
                          children: [
                            Text("${widget.date}     ${widget.time} WIB"),
                            const Gap(12),
                            // Add time if needed
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case "MUDAH":
        return Colors.green;
      case "SEDANG":
        return Colors.yellow;
      case "SULIT":
        return Colors.red;
      default:
        return Colors.white;
    }
  }
}

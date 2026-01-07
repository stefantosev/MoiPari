import 'package:flutter/material.dart';
import 'package:mobile/models/category.dart';
import 'package:mobile/service/category_service.dart';
import 'package:mobile/utils/color_utils.dart';
import 'package:mobile/utils/icon_utils.dart';


class CategoryPopup extends StatefulWidget {
  final Category? category;

  const CategoryPopup({super.key, this.category});

  @override
  State<CategoryPopup> createState() => _CategoryPopupState();
}

class _CategoryPopupState extends State<CategoryPopup> {
  final _nameController = TextEditingController();
  IconData _selectedIcon = Icons.category;
  Color _selectedColor = Colors.blue;

  final CategoryService _service = CategoryService();

  @override
  void initState() {
    super.initState();

    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _selectedIcon = widget.category!.iconData;

      if (widget.category!.color.isNotEmpty) {
        try {
          _selectedColor = widget.category!.colorValue;
        } catch (e) {
          _selectedColor = Colors.blue;
        }
      }
    }
  }

  void _showIconPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Icon'),
        content: SizedBox(
          width: 300,
          height: 300,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: IconUtils.commonIcons.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIcon = IconUtils.commonIcons[index];
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: _selectedIcon == IconUtils.commonIcons[index]
                        ? _selectedColor.withValues(alpha: 0.3)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    IconUtils.commonIcons[index],
                    color: _selectedIcon == IconUtils.commonIcons[index]
                        ? _selectedColor
                        : Colors.grey[600],
                    size: 24,
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.category != null;

    return AlertDialog(
      title: Text(isEditing ? "Edit Category" : "Add Category"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _showIconPicker,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _selectedColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: _selectedColor, width: 2),
                ),
                child: Icon(_selectedIcon, color: _selectedColor, size: 30),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap to change icon',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Category Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              "Select Color:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ColorUtils.colors.map((color) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: _selectedColor == color
                          ? Border.all(color: Colors.black, width: 3)
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              if (!isEditing) {
                await _service.createCategory(
                  _nameController.text.trim(),
                  IconUtils.getStringFromIcon(_selectedIcon),
                  '#${_selectedColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
                );
                Navigator.pop(context, "created");
              } else {
                await _service.updateCategory(
                  widget.category!.id,
                  _nameController.text.trim(),
                  IconUtils.getStringFromIcon(_selectedIcon),
                  '#${_selectedColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
                );
                Navigator.pop(context, "updated");
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(e.toString())),
              );
            }
          },
          child: Text(isEditing ? "Save" : "Create"),
        ),
      ],
    );
  }
}
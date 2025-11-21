import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/service/category_service.dart';
import 'package:mobile/models/category.dart';

class CategoryPopup extends StatefulWidget {
  final Category? category;

  const CategoryPopup({super.key, this.category});

  @override
  State<CategoryPopup> createState() => _CategoryPopupState();
}

class _CategoryPopupState extends State<CategoryPopup> {
  final _nameController = TextEditingController();
  final _iconController = TextEditingController();
  final _colorController = TextEditingController();

  final CategoryService _service = CategoryService();

  @override
  void initState() {
    super.initState();

    if(widget.category != null){
      _nameController.text = widget.category!.name;
      _iconController.text = widget.category!.icon;
      _colorController.text = widget.category!.color;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.category != null;

    return AlertDialog(
      title: Text(isEditing ? "Edit Category" : "Add Category"),

      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: "Category Name"),
          ),
          TextField(
            controller: _iconController,
            decoration: const InputDecoration(labelText: "Icon(emoji or text)"),
          ),
          TextField(
            controller: _colorController,
            decoration: const InputDecoration(labelText: "Color (Hex or name)"),
          ),
        ],
      ),

      actions: [
        //CREATE
        TextButton(
            onPressed: () async{
              try{
                if(!isEditing){
                  final newCategory = await _service.createCategory(
                    _nameController.text.trim(),
                    _iconController.text.trim(),
                    _colorController.text.trim(),
                  );
                  Navigator.pop(context, "created");
                } else{
                  //EDIT
                  final updated = await _service.updateCategory(
                    widget.category!.id,
                    _nameController.text.trim(),
                    _iconController.text.trim(),
                    _colorController.text.trim(),
                  );
                  Navigator.pop(context, "updated");
                }
              }
              catch (e){
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              }
            },
            child: Text(isEditing ? "Save" : "Create")),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/models/category.dart';
import 'package:mobile/pages/expenses.dart';
import 'package:mobile/providers/navigation_provider.dart';
import 'package:mobile/service/expense_service.dart';
import 'package:mobile/widgets/category_popup.dart';

import '../service/category_service.dart';
import '../widgets/card.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  //TODO: WALKORION

  @override
  ConsumerState<HomePage> createState() => _CategoryPageState();
}

class _CategoryPageState extends ConsumerState<HomePage> {
  final CategoryService _services = CategoryService();
  late Future<List<Category>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _services.getCategories();
  }

  void _refreshCategories() {
    setState(() {
      _categoriesFuture = _services.getCategories();
    });
  }


  Future<void> _handleDelete(int categoryId) async{
    try {
      await _services.deleteCategory(categoryId);
      _refreshCategories();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Category deleted!")),
      );
      ref.read(navigationIndexProvider.notifier).state = 0;
    }catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _handleEdit(Category category) async{
     final result = await showDialog(
         context: context,
         builder: (context) => CategoryPopup(category: category)
     );

     if (result == "updated"){
       _refreshCategories();
       ref.read(navigationIndexProvider.notifier).state = 0;
     }
  }

  @override
  Widget build(BuildContext context) {
    final navNotifier = ref.read(navigationIndexProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.deepPurpleAccent,
        child: Stack(
          children: [
            Positioned(
              top: 200,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: FutureBuilder<List<Category>>(
                  future: _categoriesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.hasData) {
                      final categories = snapshot.data!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () async{
                                //TODO: ADD THE FUNCTIONALITY
                                final result = await showDialog(
                                    context: context,
                                    builder: (context) => const CategoryPopup(),
                                );
                                if(result != null){
                                  setState(() {
                                    _categoriesFuture = _services.getCategories();
                                  });
                                  navNotifier.state = 0;
                                } else if( result != null ) {
                                  setState(() {
                                    _categoriesFuture = _services.getCategories();
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.deepPurpleAccent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  "Add",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          Expanded(
                              child: ListView.builder(
                                itemCount: categories.length,
                                itemBuilder: (context, index){
                                  final categoryId = categories[index];

                                  return GestureDetector(
                                    onTap: () {
                                      ref.read(selectedCategoryIdProvider.notifier).state = categoryId.id.toString();
                                      navNotifier.state = 2;
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                              width: 40,
                                              height: 40,
                                              // decoration: BoxDecoration(
                                              //   color: Colors.deepPurpleAccent,
                                              //   borderRadius: BorderRadius.circular(8),
                                              // ),
                                              child: Center(
                                                child: Text(
                                                    categories[index].icon,
                                                    style: const TextStyle(fontSize: 20, color: Colors.white),
                                                ),
                                              )
                                          ),

                                          const SizedBox(width: 16),

                                          Expanded(
                                            child: Text(
                                              categories[index].name,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),

                                          IconButton(
                                              onPressed: () => _handleDelete(categories[index].id),
                                              icon: const Icon(Icons.close, size: 20,color: Colors.red),
                                              tooltip: 'Delete Category',
                                          ),

                                          IconButton(
                                              onPressed: () => _handleEdit(categories[index]),
                                              icon: const Icon(Icons.edit, size: 20, color: Colors.deepPurpleAccent),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ),
                        ],
                      );
                    } else {
                      return const Center(child: Text('No categories found.'));
                    }
                  },
                ),
              ),
            ),

            Column(
              children: [
                const SizedBox(height: 1),
                CreditCardWidget(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

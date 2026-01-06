import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/models/category.dart';
import 'package:mobile/providers/navigation_provider.dart';
import 'package:mobile/widgets/category_popup.dart';

import '../service/category_service.dart';
import '../widgets/card.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

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

  Future<void> _handleDelete(int categoryId) async {
    try {
      await _services.deleteCategory(categoryId);

      if (!mounted) return;

      _onDeleteSuccess();
    } catch (e) {
      if (!mounted) return;

      _showError(e.toString());
    }
  }

  void _onDeleteSuccess() {
    _refreshCategories();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Category deleted!")));

    ref.read(navigationIndexProvider.notifier).state = 0;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleEdit(Category category) async {
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => CategoryPopup(category: category),
    );

    if (!context.mounted) return;

    if (result == "updated") {
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
                              onTap: () async {
                                final result = await showDialog<String>(
                                  context: context,
                                  builder: (dialogContext) =>
                                      const CategoryPopup(),
                                );

                                if (!context.mounted) return;

                                if (result == "created" || result == "updated") {
                                  _refreshCategories();
                                  navNotifier.state = 0;
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
                                child: const Text(
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
                              itemBuilder: (context, index) {
                                final category = categories[index];

                                return GestureDetector(
                                  onTap: () {
                                    ref
                                        .read(
                                          selectedCategoryIdProvider.notifier,
                                        )
                                        .state = category.id
                                        .toString();
                                    navNotifier.state = 2;
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: category.colorValue
                                                .withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Center(
                                            child: Icon(
                                              category.iconData,
                                              color: category.colorValue,
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),

                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                category.name,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${category.expenseIds.length} expenses',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        IconButton(
                                          onPressed: () =>
                                              _handleEdit(category),
                                          icon: const Icon(
                                            Icons.edit,
                                            size: 20,
                                            color: Colors.deepPurpleAccent,
                                          ),
                                          tooltip: 'Edit Category',
                                        ),

                                        IconButton(
                                          onPressed: () =>
                                              _handleDelete(category.id),
                                          icon: const Icon(
                                            Icons.delete,
                                            size: 20,
                                            color: Colors.red,
                                          ),
                                          tooltip: 'Delete Category',
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

            Column(children: [const SizedBox(height: 1), CreditCardWidget()]),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/models/category.dart';
import 'package:mobile/pages/expenses.dart';
import 'package:mobile/providers/navigation_provider.dart';
import 'package:mobile/service/expense_service.dart';

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
                      return ListView.builder(
                        itemCount: categories.length,
                        itemBuilder: (context, index){
                          final categoryId = categories[index];
                          return ListTile(
                            title: Text(categories[index].name),
                            onTap: () {
                              ref.read(selectedCategoryIdProvider.notifier).state = categoryId.id.toString();
                              navNotifier.state = 2;
                            }
                          );
                        },
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
                const SizedBox(height: 20),
                CreditCardWidget(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

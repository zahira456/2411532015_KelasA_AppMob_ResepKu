import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:resepku/models/recipe.dart';
import 'package:resepku/services/recipe_service.dart';
import 'package:resepku/widgets/error_view.dart';
import 'package:resepku/widgets/recipe_tile.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  Future<List<Recipe>>? _searchFuture;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Cari resep...',
            border: InputBorder.none,
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: (query) {
            if (query.trim().isEmpty) return;

            setState(() {
              _searchFuture = context
                  .read<RecipeService>()
                  .searchRecipes(query.trim());
            });
          },
        ),
      ),
      body: _searchFuture == null
          ? const Center(
              child: Text('Masukkan kata kunci resep.'),
            )
          : FutureBuilder<List<Recipe>>(
              future: _searchFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return ErrorView(
                    message: 'Gagal mencari resep.\n${snapshot.error}',
                    onRetry: () {},
                  );
                }

                final recipes = snapshot.data ?? [];

                if (recipes.isEmpty) {
                  return const Center(
                    child: Text('Resep tidak ditemukan.'),
                  );
                }

                return ListView.builder(
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    return RecipeTile(
                      recipe: recipes[index],
                    );
                  },
                );
              },
            ),
    );
  }
}
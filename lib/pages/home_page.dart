
import 'package:flutter/material.dart';
import 'package:resepku/data/dummy_recipes.dart';
import 'package:resepku/widgets/favorite_badge_button.dart';
import 'package:resepku/widgets/recipe_grid_card.dart';
import 'package:resepku/widgets/recipe_tile.dart';
import 'package:resepku/pages/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isGrid = false;

  // State untuk filter cuisine
  String? _cuisine;

  // Mengambil daftar cuisine langsung dari data resep
  List<String> get cuisines {
    return dummyRecipes
        .map((recipe) => recipe.cuisine)
        .toSet()
        .toList();
  }

  // Mengambil resep berdasarkan cuisine yang dipilih
  List get filteredRecipes {
    if (_cuisine == null) {
      return dummyRecipes;
    }

    return dummyRecipes
        .where((recipe) => recipe.cuisine == _cuisine)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 32,
            ),
            const SizedBox(width: 8),
            const Text('ResepKu'),
          ],
        ),

        actions: [
          // Tombol ganti tampilan list dan grid
          IconButton(
            tooltip: _isGrid ? 'Tampilan list' : 'Tampilan grid',
            icon: Icon(
              _isGrid ? Icons.view_list : Icons.grid_view,
            ),
            onPressed: () {
              setState(() {
                _isGrid = !_isGrid;
              });
            },
          ),

          // Tombol favorit
          const FavoriteBadgeButton(),

          // Tombol pengaturan
          IconButton(
            tooltip: 'Pengaturan',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              );
            },
          ),
        ],
      ),

      // Filter cuisine dan daftar resep
      body: Column(
        children: [
          _buildCuisineFilter(),

          Expanded(
            child: _isGrid ? _buildGrid() : _buildList(),
          ),
        ],
      ),
    );
  }

  // Widget filter cuisine menggunakan ChoiceChip
  Widget _buildCuisineFilter() {
    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          // Chip Semua
          ChoiceChip(
            label: const Text('Semua'),
            selected: _cuisine == null,
            onSelected: (selected) {
              setState(() {
                _cuisine = null;
              });
            },
          ),

          // Chip berdasarkan cuisine dari data
          ...cuisines.map((cuisine) {
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: ChoiceChip(
                label: Text(cuisine),
                selected: _cuisine == cuisine,
                onSelected: (selected) {
                  setState(() {
                    _cuisine = selected ? cuisine : null;
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  // Tampilan list
  Widget _buildList() {
    return ListView.builder(
      itemCount: filteredRecipes.length,
      itemBuilder: (context, index) {
        return RecipeTile(
          recipe: filteredRecipes[index],
        );
      },
    );
  }

  // Tampilan grid
  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.75,
      ),
      itemCount: filteredRecipes.length,
      itemBuilder: (context, index) {
        return RecipeGridCard(
          recipe: filteredRecipes[index],
        );
      },
    );
  }
}

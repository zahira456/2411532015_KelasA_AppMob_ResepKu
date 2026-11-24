
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:resepku/models/recipe.dart';
import 'package:resepku/providers/favorite_provider.dart';
import 'package:resepku/services/recipe_service.dart';
import 'package:resepku/widgets/recipe_image.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key, required this.recipe});

  final Recipe recipe;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late int _servings;

  @override
  void initState() {
    super.initState();
    _servings = widget.recipe.servings;
  }

  void _addServing() {
    setState(() => _servings++);
  }

  void _removeServing() {
    if (_servings > 1) {
      setState(() => _servings--);
    }
  }

  // Mengubah nama resep menggunakan PUT
  Future<void> _updateRecipeName() async {
    final controller = TextEditingController(
      text: widget.recipe.name,
    );

    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Ubah Nama Resep'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Nama resep',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  controller.text.trim(),
                );
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (!mounted) return;

    if (newName == null || newName.isEmpty) return;

    try {
      final result = await context.read<RecipeService>().updateRecipe(
        id: widget.recipe.id,
        name: newName,
      );

      if (!mounted) return;

      final updatedName = result['name']?.toString() ?? newName;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nama resep berhasil diubah menjadi $updatedName'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengubah resep: $e'),
        ),
      );
    }
  }

  // Menghapus resep menggunakan DELETE
  Future<void> _deleteRecipe() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Resep'),
          content: Text(
            'Apakah kamu yakin ingin menghapus resep "${widget.recipe.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    if (confirm != true) return;

    try {
      final result = await context
          .read<RecipeService>()
          .deleteRecipe(widget.recipe.id);

      if (!mounted) return;

      if (result['isDeleted'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Resep "${widget.recipe.name}" berhasil dihapus.',
            ),
          ),
        );

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resep gagal dihapus.'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus resep: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    final totalCalories = recipe.caloriesPerServing * _servings;
    final isFavorite = context.watch<FavoriteProvider>().isFavorite(recipe);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
            ),
            onPressed: () =>
                context.read<FavoriteProvider>().toggle(recipe),
          ),

          // Menu Ubah dan Hapus
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _updateRecipeName();
              } else if (value == 'delete') {
                _deleteRecipe();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined),
                    SizedBox(width: 8),
                    Text('Ubah nama'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline),
                    SizedBox(width: 8),
                    Text('Hapus resep'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: RecipeImage(url: recipe.image),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${recipe.cuisine} • ${recipe.difficulty} • ${recipe.totalTimeMinutes} menit',
            style: textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Text('Porsi', style: textTheme.titleMedium),
                  const Spacer(),
                  IconButton.filledTonal(
                    onPressed: _servings > 1 ? _removeServing : null,
                    icon: const Icon(Icons.remove),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '$_servings',
                      style: textTheme.titleLarge,
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: _addServing,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Total kalori: $totalCalories kkal',
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: 24),
          Text('Bahan', style: textTheme.titleLarge),
          for (final item in recipe.ingredients)
            ListTile(
              dense: true,
              leading: const Icon(Icons.check_circle_outline),
              title: Text(item),
            ),
          if (recipe.instructions.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Instruksi', style: textTheme.titleLarge),
            for (final (index, step) in recipe.instructions.indexed)
              ListTile(
                dense: true,
                leading: CircleAvatar(
                  radius: 12,
                  child: Text('${index + 1}'),
                ),
                title: Text(step),
              ),
          ],
        ],
      ),
    );
  }
}

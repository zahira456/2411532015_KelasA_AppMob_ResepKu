
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resepku/providers/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: SwitchListTile(
        title: const Text('Mode gelap'),
        subtitle: const Text('Aktifkan tema gelap aplikasi'),
        value: themeProvider.themeMode == ThemeMode.dark,
        onChanged: (value) {
          context.read<ThemeProvider>().toggleTheme(value);
        },
        secondary: const Icon(Icons.dark_mode),
      ),
    );
  }
}

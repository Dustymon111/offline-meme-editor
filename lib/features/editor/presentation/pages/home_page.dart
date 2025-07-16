import 'dart:io';

import 'package:flutter/material.dart';
import 'package:meme_editor/features/editor/presentation/provider/editor_provider.dart';
import 'package:meme_editor/features/editor/presentation/provider/home_provider.dart';
import 'package:meme_editor/features/editor/presentation/provider/theme_provider.dart';
import 'package:provider/provider.dart';
import 'editor_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeProvider>(context, listen: false).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meme Templates"),
        actions: [
          Consumer<HomeProvider>(
            builder: (_, provider, __) => IconButton(
              icon: Icon(provider.isOnline ? Icons.cloud : Icons.cloud_off),
              tooltip: provider.isOnline ? 'Online Mode' : 'Offline Mode',
              onPressed: () => {provider.toggleOnlineMode(context)},
            ),
          ),
          Consumer<ThemeProvider>(
            builder: (_, themeProvider, __) => Switch(
              value: themeProvider.isDarkMode,
              onChanged: (val) {
                themeProvider.toggleTheme(val);
              },
            ),
          ),
        ],
      ),
      body: Consumer<HomeProvider>(
        builder: (context, provider, _) {
          final searchQuery = provider.searchQuery;

          final memes = provider.filteredCachedMemes;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search memes...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              provider.setSearchQuery('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: provider.setSearchQuery,
                ),
              ),

              // Swipe-to-Refresh
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => provider.fetchTemplates(),
                  child: provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : memes.isEmpty
                      ? const Center(child: Text('No memes found'))
                      : GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: 1,
                              ),
                          itemCount: memes.length,
                          itemBuilder: (context, index) {
                            final meme = memes[index];
                            final imagePath = meme.imagePath;

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChangeNotifierProvider(
                                      create: (_) {
                                        final provider =
                                            Provider.of<EditorProvider>(
                                              context,
                                            );
                                        provider.loadMemeById(meme.id);
                                        return provider;
                                      },
                                      child: EditorPage(
                                        imageUrl: meme.imagePath,
                                        isOnline: false,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: File(imagePath).existsSync()
                                  ? Image.file(
                                      File(imagePath),
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(Icons.broken_image),
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

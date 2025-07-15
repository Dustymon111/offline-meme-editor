import 'dart:io';

import 'package:flutter/material.dart';
import 'package:meme_editor/features/editor/domain/entities/meme.dart';
import 'package:meme_editor/features/editor/domain/entities/meme_template.dart';
import 'package:meme_editor/features/editor/presentation/provider/home_provider.dart';
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
    Future.microtask(() {
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
              onPressed: () => {provider.toggleOnlineMode()},
            ),
          ),
        ],
      ),
      body: Consumer<HomeProvider>(
        builder: (context, provider, _) {
          final isOnline = provider.isOnline;
          final searchQuery = provider.searchQuery;

          final memes = isOnline
              ? provider.filteredTemplates
              : provider.filteredCachedMemes;

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

              // 🔄 Swipe-to-Refresh + Grid
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
                            final imagePath = isOnline
                                ? (meme as MemeTemplate).url
                                : (meme as Meme).imagePath;

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditorPage(
                                      imageUrl: imagePath,
                                      isOnline: isOnline,
                                    ),
                                  ),
                                );
                              },
                              child: isOnline
                                  ? Image.network(
                                      imagePath,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.broken_image),
                                    )
                                  : File(imagePath).existsSync()
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

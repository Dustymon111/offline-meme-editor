import 'package:flutter/material.dart';
import 'package:meme_editor/features/editor/data/repositories/meme_repository_impl.dart';
import 'package:meme_editor/features/editor/domain/repositories/meme_repository.dart';
import 'package:meme_editor/features/editor/presentation/pages/home_page.dart';
import 'package:meme_editor/features/editor/presentation/provider/editor_provider.dart';
import 'package:meme_editor/features/editor/presentation/provider/home_provider.dart';
import 'package:meme_editor/features/editor/presentation/provider/meme_provider.dart';
import 'package:meme_editor/features/editor/presentation/provider/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/editor/domain/entities/meme.dart';
import 'features/editor/domain/entities/meme_element.dart';
import 'injection/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final brightness =
      WidgetsBinding.instance.platformDispatcher.platformBrightness;
  final isSystemDark = brightness == Brightness.dark;

  await Hive.initFlutter();

  // Register type adapters
  Hive.registerAdapter(MemeAdapter());
  Hive.registerAdapter(MemeElementAdapter());
  Hive.registerAdapter(MemeElementTypeAdapter());

  final memeBox = await Hive.openBox<Meme>('memes');

  //Setup Injection
  await Injection.init(memeBox);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MemeProvider(sl<MemeRepositoryImpl>()),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeProvider(sl<MemeRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => EditorProvider(sl<MemeRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(isSystemDark: isSystemDark),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Offline Meme Editor',
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(primary: Colors.deepPurple),
      ),
      home: const HomePage(),
    );
  }
}

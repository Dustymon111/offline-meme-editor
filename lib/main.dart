import 'package:flutter/material.dart';
import 'package:meme_editor/features/editor/data/repositories/meme_repository_impl.dart';
import 'package:meme_editor/features/editor/domain/repositories/meme_repository.dart';
import 'package:meme_editor/features/editor/domain/usecases/get_templates_usecase.dart';
import 'package:meme_editor/features/editor/presentation/pages/home_page.dart';
import 'package:meme_editor/features/editor/presentation/provider/editor_provider.dart';
import 'package:meme_editor/features/editor/presentation/provider/home_provider.dart';
import 'package:meme_editor/features/editor/presentation/provider/meme_provider.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/editor/domain/entities/meme.dart';
import 'features/editor/domain/entities/meme_element.dart';
import 'injection/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
        ChangeNotifierProvider(create: (_) => EditorProvider()),
        ChangeNotifierProvider(
          create: (_) => HomeProvider(sl<MemeRepository>()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Offline Meme Editor',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(),
    );
  }
}

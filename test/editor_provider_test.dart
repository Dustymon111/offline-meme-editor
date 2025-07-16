import 'package:flutter_test/flutter_test.dart';
import 'package:meme_editor/features/editor/domain/entities/meme.dart';
import 'package:meme_editor/features/editor/presentation/provider/editor_provider.dart';
import 'package:meme_editor/features/editor/domain/entities/meme_element.dart';
import 'package:mockito/mockito.dart';
import 'mock_meme_repository.mocks.dart';

void main() {
  late MockMemeRepository mockRepository;
  late EditorProvider provider;

  final initialElement = MemeElement(
    id: '1',
    type: MemeElementType.text,
    x: 10,
    y: 20,
    content: 'Hello',
    scale: 1.0,
  );

  final updatedElement = MemeElement(
    id: '1',
    type: MemeElementType.text,
    x: 30,
    y: 40,
    content: 'Updated',
    scale: 1.5,
  );

  setUp(() {
    mockRepository = MockMemeRepository();
    provider = EditorProvider(repository: mockRepository);
  });

  test('addElement should add element and save to history', () {
    provider.addElement(initialElement);

    expect(provider.elements.length, 1);
    expect(provider.elements.first.content, 'Hello');
  });

  test(
    'updateElement should update an existing element and call saveMeme',
    () async {
      final meme = Meme(id: '123', imagePath: "", elements: [initialElement]);
      when(mockRepository.getAllMemes()).thenAnswer((_) async => [meme]);
      when(mockRepository.updateMeme(any)).thenAnswer((_) async => {});

      await provider.loadMemeById('123');
      provider.updateElement('1', updatedElement);

      expect(provider.elements.first.content, 'Updated');
      verify(mockRepository.updateMeme(any)).called(1);
    },
  );

  // test('removeElement should remove the element and call saveMeme', () async {
  //   // Arrange
  //   provider.addElement(initialElement);
  //   when(mockRepository.updateMeme(any)).thenAnswer((_) async => {});

  //   // Act
  //   provider.removeElement('1');

  //   // Assert
  //   expect(provider.elements.length, 0);
  //   verify(mockRepository.updateMeme(any)).called(1);
  // });

  test('undo should revert to previous history state', () {
    final secondElement = initialElement.copyWith(id: '2', content: 'Second');
    provider.addElement(initialElement);
    provider.addElement(secondElement);

    expect(provider.elements.length, 2);

    provider.undo();

    expect(provider.elements.length, 1);
    expect(provider.elements.first.id, '1');
  });

  test('redo should reapply the undone change', () {
    final secondElement = initialElement.copyWith(id: '2', content: 'Second');
    provider.addElement(initialElement);
    provider.addElement(secondElement);

    provider.undo();
    provider.redo();

    expect(provider.elements.length, 2);
  });

  test('clear should remove all elements and history', () {
    provider.addElement(initialElement);
    expect(provider.elements.isNotEmpty, true);

    provider.clear();

    expect(provider.elements.isEmpty, true);
  });

  test(
    'loadMemeById should load elements from meme and save to history',
    () async {
      final meme = Meme(
        id: '123',
        imagePath: "path",
        elements: [initialElement],
      );

      when(mockRepository.getAllMemes()).thenAnswer((_) async => [meme]);

      await provider.loadMemeById('123');

      expect(provider.elements.length, 1);
      expect(provider.elements.first.id, '1');
      expect(provider.elements.first.content, 'Hello');
    },
  );
}

// Mocks generated by Mockito 5.4.5 from annotations
// in meme_editor/test/features/editor/domain/repositories/mock_meme_repository.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i3;

import 'package:meme_editor/features/editor/domain/entities/meme.dart' as _i4;
import 'package:meme_editor/features/editor/domain/entities/meme_template.dart'
    as _i5;
import 'package:meme_editor/features/editor/domain/repositories/meme_repository.dart'
    as _i2;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: must_be_immutable
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

/// A class which mocks [MemeRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockMemeRepository extends _i1.Mock implements _i2.MemeRepository {
  MockMemeRepository() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<List<_i4.Meme>> getAllMemes() =>
      (super.noSuchMethod(
            Invocation.method(#getAllMemes, []),
            returnValue: _i3.Future<List<_i4.Meme>>.value(<_i4.Meme>[]),
          )
          as _i3.Future<List<_i4.Meme>>);

  @override
  _i3.Future<List<_i5.MemeTemplate>> getTemplates() =>
      (super.noSuchMethod(
            Invocation.method(#getTemplates, []),
            returnValue: _i3.Future<List<_i5.MemeTemplate>>.value(
              <_i5.MemeTemplate>[],
            ),
          )
          as _i3.Future<List<_i5.MemeTemplate>>);

  @override
  _i3.Future<void> updateMeme(_i4.Meme? meme) =>
      (super.noSuchMethod(
            Invocation.method(#updateMeme, [meme]),
            returnValue: _i3.Future<void>.value(),
            returnValueForMissingStub: _i3.Future<void>.value(),
          )
          as _i3.Future<void>);
}

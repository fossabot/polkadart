import 'package:analyzer/dart/element/element.dart';

import 'helper_core.dart';

abstract class DecodeHelper implements HelperCore {
  /// Write decode method implementation as example above:
  ///
  /// ```dart
  ///   // ...
  ///   Example decode(String encodedData) =>
  ///     Example();
  ///   // ...
  /// ```
  Iterable<String> createDecode(
      Map<String, FieldElement> accessibleFields) sync* {
    assert(config.shouldCreateDecodeMethod);

    final buffer = StringBuffer();

    //TODO: write decode complete implementation
    buffer.writeln('$targetClassReference decode(String encodedData) => ');

    _writeDefaultConstructor(buffer, accessibleFields);

    yield buffer.toString();
  }

  void _writeDefaultConstructor(
      StringBuffer stringBuffer, Map<String, FieldElement> fields) {
    stringBuffer.write('$targetClassReference(');

    for (var field in fields.keys) {
      final fieldName =
          field.startsWith('_') ? field.replaceFirst('_', '') : field;

      stringBuffer.write('$fieldName, ');
    }

    stringBuffer.writeln(');');
  }
}

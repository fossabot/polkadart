import 'models/scale_codec_class.dart';
import 'templates/class_template.dart';

class GeneratorHelper {
  final ClassTemplate classTemplate;

  GeneratorHelper(ScaleCodecClass scaleCodecClass)
      : classTemplate = ClassTemplate(scaleCodecClass);

  String generate() => '''
        ${classTemplate.generate()}
      ''';
}

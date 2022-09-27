import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:scale_codec_annotation/scale_codec_annotation.dart';
import 'package:source_gen/source_gen.dart';

import 'config.dart';
import 'models/scale_codec_class.dart';
import 'templates/class_template.dart';
import 'utils/utils.dart';

class ScaleCodecSerializableGenerator
    extends GeneratorForAnnotation<ScaleCodecSerializable> {
  final ClassConfig config;
  const ScaleCodecSerializableGenerator({required this.config});

  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement || element is EnumElement) {
      throw InvalidGenerationSourceError(
          '`@ScaleCodecSerializable` can only be used on classes.',
          element: element);
    }

    final mergedConfig = config.mergeWith(annotation);
    final scaleCodecClass = ScaleCodecClass.fromElement(element, mergedConfig);

    final classTemplate = ClassTemplate(scaleCodecClass);
    return classTemplate.generate();
  }
}

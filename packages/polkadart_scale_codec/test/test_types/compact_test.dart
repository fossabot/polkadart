import 'package:polkadart_scale_codec/polkadart_scale_codec.dart'
    as scale_codec;
import 'package:polkadart_scale_codec/src/util/utils.dart';
import 'package:substrate_metadata/old/type_registry.dart';
import 'package:substrate_metadata/old/types.dart' as old_types;
import 'package:test/test.dart';

void main() {
  {
    //
    // Unexpected case: TypeKind.Sequence.
    //
    // We can't compact `Vector` so it should throw `Exception`.
    //
    group('Compact Exception', () {
      test('On using Compact<Vec<u8>> as Types then Codec initialization should throw UnexpectedCaseException', () {
        final registry = OldTypeRegistry(
          old_types.OldTypes(
            types: <String, dynamic>{
              'Codec': {
                'primitive__compact_some': 'Compact<Vec<u8>>',
              },
            },
          ),
        );

        // specifying which schema type to use.
        registry.use('Codec');

        // fetching the parsed types from `Json` to `Type`
        final types = registry.getTypes();

        // Invalid Case Exception
        expect(
            () => scale_codec.Codec(types),
            throwsA(predicate((e) =>
                e is UnexpectedCaseException &&
                e.toString() == 'Unexpected case: TypeKind.Sequence.')));
      });
    });
  }

  // Creates the registry for parsing the types and selecting particular schema.
  final registry = OldTypeRegistry(
    old_types.OldTypes(
      types: <String, dynamic>{
        'Codec': {
          'primitive__compact_u8': 'Compact<u8>',
        },
      },
    ),
  );

  // specifying which schema type to use.
  registry.use('Codec');

  // fetching the parsed types from `Json` to `Type`
  final types = registry.getTypes();

  // Initializing Scale-Codec object
  final codec = scale_codec.Codec(types);

  {
    // Testing Compact exception
    group('Compact Exception', () {
      test('Encode Compact<u8>', () {
        //
        // Invalid int compacting
        //
        expect(
            () => codec.encodeToHex(registry.use('Compact<u8>'), -1),
            throwsA(predicate((e) =>
                e is InvalidCompactException &&
                e.toString() == 'Value can\'t be less than 0.')));

        //
        // Invalid BigInt compacting
        //
        expect(
            () =>
                codec.encodeToHex(registry.use('Compact<u8>'), BigInt.from(-1)),
            throwsA(predicate((e) =>
                e is InvalidCompactException &&
                e.toString() == 'Value can\'t be less than 0.')));

        //
        // Invalid Type Compacting
        //
        expect(
            () => codec.encodeToHex(registry.use('Compact<u8>'), 'A'),
            throwsA(predicate((e) =>
                e is UnexpectedTypeException &&
                e.toString() ==
                    'Expected `int` or `BigInt`, but found String.')));

        //
        // Exceeding BigInt Compacting value range: 2 ** 536
        //
        final BigInt invalidValue = 2.toBigInt.pow(536.toBigInt.toInt());
        expect(
            () => codec.encodeToHex(registry.use('Compact<u8>'), invalidValue),
            throwsA(predicate((e) =>
                e is IncompatibleCompactException &&
                e.toString() ==
                    '${invalidValue.toRadixString(16)} is too large for a compact')));

        //
        // Exceeding int Compacting value range: 2 ** 536
        //
        expect(
            () => codec.encodeToHex(
                registry.use('Compact<u8>'), invalidValue.toInt()),
            throwsA(predicate((e) =>
                e is IncompatibleCompactException &&
                e.toString() ==
                    '${invalidValue.toInt().toRadixString(16)} is too large for a compact')));
      });
    });
  }
}

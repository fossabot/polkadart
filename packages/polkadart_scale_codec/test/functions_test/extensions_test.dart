import 'package:test/test.dart';
import 'package:polkadart_scale_codec/polkadart_scale_codec.dart';

void main() {
  group('IntConverter Extension:', () {
    test('When provided with 5 as int, it will result in an BigInt Object.',
        () {
      final bigInt = 5.toBigInt;
      expect(BigInt.from(5), equals(bigInt));
    });

    test('When provided with 0 as int, it will result in an BigInt Object.',
        () {
      final bigInt = 0.toBigInt;
      expect(BigInt.from(0), equals(bigInt));
    });

    test('When provided with 500 as int, it will result in an BigInt Object.',
        () {
      final bigInt = 500.toBigInt;
      expect(BigInt.from(500), equals(bigInt));
    });

    test(
        'When provided with -5 as negative int, it will result in an BigInt Object.',
        () {
      final bigInt = -5.toBigInt;
      expect(BigInt.from(-5), equals(bigInt));
    });
  });

  group('StringConverter Extension:', () {
    test(
        'When provided with 500 as String, it will result in an BigInt Object.',
        () {
      final bigInt = '500'.toBigInt;
      expect(BigInt.parse('500'), bigInt);
    });

    test(
        'When provided with -120 as String, it will result in an BigInt Object.',
        () {
      final bigInt = '-120'.toBigInt;
      expect(BigInt.parse('-120'), bigInt);
    });
  });

  group('Throw Exception at StringConverter Extension:', () {
    test(
        'When trying to convert \'ABC\' to BigInt, it will throw \'UnexpectedCaseException\'.',
        () {
      expect(() => 'ABC'.toBigInt, throwsA(isA<UnexpectedCaseException>()));
    });
  });
}

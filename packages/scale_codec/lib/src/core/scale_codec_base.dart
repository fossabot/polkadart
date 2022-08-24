import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:scale_codec/src/util/hex.dart';

class Src {
  int _idx = 0;
  late Uint8List _buf;

  Src.fromUint8List(Uint8List buf) {
    _buf = buf;
  }

  Src.fromString(String buf) {
    _buf = decodeHex(buf);
  }

  int _byte() {
    if (_idx >= _buf.length) {
      throw eof();
    }
    _idx += 1;
    return _buf[_idx];
  }

  int i8() {
    var b = _byte();
    return b | (b & (pow(2, 7) as int)) * 0x1fffffe;
  }

  int u8() {
    return _byte();
  }

  int i16() {
    var val = u16();
    return val | (val & (pow(2, 15) as int)) * 0x1fffe;
  }

  int u16() {
    var first = _byte();
    var last = _byte();
    return first + last * (pow(2, 8) as int);
  }

  int i32() {
    return _byte() +
        _byte() * (pow(2, 8) as int) +
        _byte() * (pow(2, 16) as int) +
        (_byte() << 24);
  }

  int u32() {
    return _byte() +
        _byte() * (pow(2, 8) as int) +
        _byte() * (pow(2, 16) as int) +
        _byte() * (pow(2, 24) as int);
  }

  BigInt i64() {
    var lo = u32();
    var hi = i32();
    return BigInt.from(lo) + (BigInt.from(hi) << 32);
  }

  BigInt u64() {
    var lo = u32();
    var hi = u32();
    return BigInt.from(lo) + (BigInt.from(hi) << 32);
  }

  BigInt i128() {
    var lo = u64();
    var hi = i64();
    return lo + (hi << 64);
  }

  BigInt u128() {
    var lo = u64();
    var hi = u64();
    return lo + (hi << 64);
  }

  BigInt i256() {
    var lo = u128();
    var hi = i128();
    return lo + (hi << 128);
  }

  BigInt u256() {
    var lo = u128();
    var hi = u128();
    return lo + (hi << 128);
  }

  /// can return either [BigInt] or [int]
  dynamic compact() {
    var b = _byte();
    var mode = b & 3;
    switch (mode) {
      case 0:
        return b >> 2;
      case 1:
        return (b >> 2) + _byte() * pow(2, 6);
      case 2:
        return (b >> 2) +
            _byte() * pow(2, 6) +
            _byte() * pow(2, 14) +
            _byte() * pow(2, 22);
      case 3:
        // returning BigInt here
        return _bigCompact(b >> 2);
      default:
        throw Exception('Reached unreachable statement');
    }
  }

  /// can return either [BigInt] or [int]
  dynamic _bigCompact(num len) {
    var i = u32();
    switch (len) {
      case 0:
        return i;
      case 1:
        return i + _byte() * pow(2, 32);
      case 2:
        return i + _byte() * pow(2, 32) + _byte() * pow(2, 40);
    }
    var n = BigInt.from(i);
    var base = BigInt.from(32);
    len--;
    while (len != 0) {
      n += BigInt.from(_byte()) << base.toInt();
      base += BigInt.from(8);
      len--;
    }
    // returning BigInt here
    return n;
  }

  int compactLength() {
    var len = compact();
    assert(len is int);
    return len;
  }

  String str() {
    var len = compactLength();
    var buf = bytes(len);
    return utf8.decode(buf.toList());
  }

  Uint8List bytes(int len) {
    var beg = _idx;
    var end = _idx += len;
    if (_buf.length < end) {
      throw eof();
    }
    return _buf.sublist(beg, end);
  }

  bool getBool() {
    return _byte() != 0;
  }

  bool hasBytes() {
    return _buf.length > _idx;
  }

  void assertEOF() {
    if (hasBytes()) {
      throw Exception('Unprocessed data left');
    }
  }
}

Exception eof() {
  throw Exception('Unexpected EOF');
}

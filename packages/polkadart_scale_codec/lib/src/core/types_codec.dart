import 'dart:math';
import 'package:polkadart_scale_codec/src/util/functions.dart';

import 'codec_type.dart';
import 'types.dart';
import 'codec_variant.dart';

Type getUnwrappedType(List<Type> types, int ti) {
  Type def = types[ti];
  switch (def.kind) {
    case TypeKind.Tuple:
    case TypeKind.Composite:
      return unwrap(def, types);
    default:
      return def;
  }
}

Type unwrap(Type def, List<Type> types, {Set<int>? visited}) {
  int next;
  switch (def.kind) {
    case TypeKind.Tuple:
      if ((def as TupleType).tuple.length == 1) {
        next = def.tuple[0];
        break;
      } else {
        return def;
      }
    case TypeKind.Composite:
      if ((def as CompositeType).fields[0].name == null) {
        // TODO: Uncomment this below comment when it starts working by calling from the substrate-metadata explorer.
        //
        // var tuple = def.fields.map((t) {
        //     assert(t?.name == null);
        //     return t.type;
        // }).toList();
        //
        // TODO: Check this with the above function as if the same working is being done or not.
        var tuple = def.fields.map((t) => t.type).toList();
        if (tuple.length == 1) {
          next = tuple[0];
          break;
        } else {
          return TupleType(tuple: tuple);
        }
      } else {
        return def;
      }
    default:
      return def;
  }
  if (visited?.contains(next) ?? false) {
    throw Exception('Cycle of tuples involving $next');
  }
  visited = visited ?? <int>{};
  visited.add(next);
  return unwrap(types[next], types, visited: visited);
}

CodecType getCodecType(List<Type> types, int ti) {
  Type def = getUnwrappedType(types, ti);
  switch (def.kind) {
    case TypeKind.Sequence:
      if (isPrimitive(Primitive.U8, types, (def as SequenceType).type)) {
        return CodecBytesType();
      } else {
        return def;
      }
    case TypeKind.Array:
      if (isPrimitive(Primitive.U8, types, (def as ArrayType).type)) {
        return CodecBytesArrayType(len: def.len);
      } else {
        return def;
      }
    case TypeKind.Compact:
      var type = getUnwrappedType(types, (def as CompactType).type);
      switch (type.kind) {
        case TypeKind.Tuple:
          assert((type as TupleType).tuple.isEmpty);
          return type as TupleType;
        case TypeKind.Primitive:
          assert((type as PrimitiveType).primitive.name[0] == 'U');
          return CodecCompactType(integer: (type as PrimitiveType).primitive);
        default:
          throw Exception('Unexpected case: ${type.kind}');
      }

    case TypeKind.Composite:
      return CodecStructType(
          fields: (def as CompositeType).fields.map((field) {
        var name = assertNotNull(field.name);
        return CodecStructTypeFields(name: name!, type: field.type);
      }).toList());
    case TypeKind.Variant:
      List<Variant> variants = (def as VariantType).variants;
      Map<String, CodecVariant> variantsByName = <String, CodecVariant>{};
      Set<int> uniqueIndexes =
          Set<int>.from(variants.map((Variant v) => v.index));
      if (uniqueIndexes.length != variants.length) {
        throw Exception('Variant type $ti has duplicate case indexes');
      }

      // TODO: To replace with reduce function in dart
      var len = 0;
      variants.map((v) => v.index).skip(1).forEach((index) {
        len = max(len, index);
      });
      len += 1;
      List<CodecVariant?> placedVariants = <CodecVariant?>[]..length = len;
      for (var v in variants) {
        late CodecVariant cv;
        if (v.fields.isNotEmpty && v.fields[0].name == null) {
          switch (v.fields.length) {
            case 0:
              cv = CodecEmptyVariant(name: v.name, index: v.index);
              break;
            case 1:
              cv = CodecValueVariant(
                  name: v.name, index: v.index, type: v.fields[0].type);
              break;
            default:
              cv = CodecTupleVariant(
                  name: v.name,
                  index: v.index,
                  def: TupleType(
                      tuple: v.fields.map((Field field) {
                    assert(field.name == null);
                    return field.type;
                  }).toList()));
          }
        } else {
          cv = CodecStructVariant(
              name: v.name,
              index: v.index,
              def: CodecStructType(
                  fields: v.fields.map((field) {
                var name = assertNotNull(field.name)!;
                return CodecStructTypeFields(name: name, type: field.type);
              }).toList()));
        }
        placedVariants[v.index] = cv;
        variantsByName[cv.name] = cv;
      }
      return CodecVariantType(
        variants: placedVariants,
        variantsByName: variantsByName,
      );
    default:
      return def as CodecType;
  }
}

///
/// Check whether primitive is a valid [Primitive] or not
bool isPrimitive(Primitive primitive, List<Type> types, int ti) {
  final Type type = getUnwrappedType(types, ti);
  return type.kind == TypeKind.Primitive &&
      (type as PrimitiveType).primitive == primitive;
}

///
/// Convert list [Types] to [CodecTypes]
List<CodecType> toCodecTypes(List<Type> types) {
  List<CodecType> codecTypes = <CodecType>[]..length = types.length;
  for (var i = 0; i < types.length; i++) {
    codecTypes[i] = getCodecType(types, i);
  }
  return codecTypes;
}

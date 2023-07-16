import "dart:ffi" as ffi;

import "package:ffi/ffi.dart" as ffi;

import "../lc.dart";
import "../library.dart";

typedef _Native = ffi.Pointer<ffi.Utf8> Function(
    ffi.Int, ffi.Pointer<ffi.Utf8>);
typedef _Dart = ffi.Pointer<ffi.Utf8> Function(int, ffi.Pointer<ffi.Utf8>);

final _func = lib.lookupFunction<_Native, _Dart>("setlocale");

String? setLocale([LC category = LC.all, String? locale = ""]) {
  final localeName = locale == null ? ffi.nullptr : locale.toNativeUtf8();
  final output = _func(category.toInt(), localeName);
  if (output == ffi.nullptr) return null;
  return output.toDartString();
}

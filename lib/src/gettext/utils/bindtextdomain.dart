import "dart:ffi" as ffi;

import "package:ffi/ffi.dart" as ffi;

import "../library.dart";

typedef _Native = ffi.Pointer<ffi.Utf8> Function(
    ffi.Pointer<ffi.Utf8>, ffi.Pointer<ffi.Utf8>);
typedef _Dart = _Native;

final _func = lib.lookupFunction<_Native, _Dart>("bindtextdomain");

/// Specify that the [domainName] message catalog will be found
/// in [dirName] rather than in the system locale data base.
String? bindTextDomain(String domainName, String? dirName) {
  final dir = dirName == null ? ffi.nullptr : dirName.toNativeUtf8();
  final output = _func(domainName.toNativeUtf8(), dir);
  if (output == ffi.nullptr) return null;
  return output.toDartString();
}

import "dart:ffi" as ffi;

import "package:ffi/ffi.dart" as ffi;

import "../library.dart";

typedef _Native = ffi.Pointer<ffi.Utf8> Function(
    ffi.Pointer<ffi.Utf8>, ffi.Pointer<ffi.Utf8>);
typedef _Dart = _Native;

final _func = lib.lookupFunction<_Native, _Dart>("bind_textdomain_codeset");

/// Specify the character encoding in which the messages from the
/// [domainName] message catalog will be returned.
String? bindTextDomainCodeset(String domainName, String? codeset) {
  final encoding = codeset == null ? ffi.nullptr : codeset.toNativeUtf8();
  final output = _func(domainName.toNativeUtf8(), encoding);
  if (output == ffi.nullptr) return null;
  return output.toDartString();
}

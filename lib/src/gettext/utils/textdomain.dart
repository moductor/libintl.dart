import "dart:ffi" as ffi;

import "package:ffi/ffi.dart" as ffi;

import "../library.dart";

typedef _Native = ffi.Pointer<ffi.Utf8> Function(ffi.Pointer<ffi.Utf8>);
typedef _Dart = _Native;

final _func = lib.lookupFunction<_Native, _Dart>("textdomain");

/// Set the current default message catalog to [domainName].
/// If [domainName] is null, return the current default.
/// If [domainName] is "", reset to the default of "messages".
String? textDomain(String? domainName) {
  final domain = domainName == null ? ffi.nullptr : domainName.toNativeUtf8();
  final output = _func(domain);
  if (output == ffi.nullptr) return null;
  return output.toDartString();
}

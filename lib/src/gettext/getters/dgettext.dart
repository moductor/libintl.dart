import "dart:ffi" as ffi;

import "package:ffi/ffi.dart" as ffi;

import "../library.dart";

typedef _Native = ffi.Pointer<ffi.Utf8> Function(
    ffi.Pointer<ffi.Utf8>, ffi.Pointer<ffi.Utf8>);
typedef _Dart = _Native;

final _func = lib.lookupFunction<_Native, _Dart>("dgettext");

/// Look up [msgid] in the [domainName] message catalog for the current
/// LC_MESSAGES locale.
String dgettext(String domainName, String msgid) =>
    _func(domainName.toNativeUtf8(), msgid.toNativeUtf8()).toDartString();

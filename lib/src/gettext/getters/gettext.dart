import "dart:ffi" as ffi;

import "package:ffi/ffi.dart" as ffi;

import "../library.dart";

typedef _Native = ffi.Pointer<ffi.Utf8> Function(ffi.Pointer<ffi.Utf8>);
typedef _Dart = _Native;

final _func = lib.lookupFunction<_Native, _Dart>("gettext");

/// Look up [msgid] in the current default message catalog for the current
/// LC_MESSAGES locale.  If not found, returns [msgid] itself (the default
/// text).
String gettext(String msgid) => _func(msgid.toNativeUtf8()).toDartString();

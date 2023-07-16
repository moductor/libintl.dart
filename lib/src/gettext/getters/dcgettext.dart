import "dart:ffi" as ffi;

import "package:ffi/ffi.dart" as ffi;

import "../lc.dart";
import "../library.dart";

typedef _Native = ffi.Pointer<ffi.Utf8> Function(
    ffi.Pointer<ffi.Utf8>, ffi.Pointer<ffi.Utf8>, ffi.Int);
typedef _Dart = ffi.Pointer<ffi.Utf8> Function(
    ffi.Pointer<ffi.Utf8>, ffi.Pointer<ffi.Utf8>, int);

final _func = lib.lookupFunction<_Native, _Dart>("dcgettext");

/// Look up [msgid] in the [domainName] message catalog for the current
/// [category] locale.
String dcgettext(String domainName, String msgid, LC category) =>
    _func(domainName.toNativeUtf8(), msgid.toNativeUtf8(), category.toInt())
        .toDartString();

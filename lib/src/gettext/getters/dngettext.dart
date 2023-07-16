import "dart:ffi" as ffi;

import "package:ffi/ffi.dart" as ffi;

import "../library.dart";
import "dgettext.dart";

typedef _Native = ffi.Pointer<ffi.Utf8> Function(ffi.Pointer<ffi.Utf8>,
    ffi.Pointer<ffi.Utf8>, ffi.Pointer<ffi.Utf8>, ffi.UnsignedLong);
typedef _Dart = ffi.Pointer<ffi.Utf8> Function(
    ffi.Pointer<ffi.Utf8>, ffi.Pointer<ffi.Utf8>, ffi.Pointer<ffi.Utf8>, int);

final _func = lib.lookupFunction<_Native, _Dart>("dngettext");

/// Similar to [dgettext] but select the plural form corresponding to the
/// number [n].
String dngettext(String domainName, String msgid1, String msgid2, int n) =>
    _func(domainName.toNativeUtf8(), msgid1.toNativeUtf8(),
            msgid2.toNativeUtf8(), n)
        .toDartString();

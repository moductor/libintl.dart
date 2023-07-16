import "dart:ffi" as ffi;

import "package:ffi/ffi.dart" as ffi;

import "../lc.dart";
import "../library.dart";
import "dcgettext.dart";

typedef _Native = ffi.Pointer<ffi.Utf8> Function(ffi.Pointer<ffi.Utf8>,
    ffi.Pointer<ffi.Utf8>, ffi.Pointer<ffi.Utf8>, ffi.UnsignedLong, ffi.Int);
typedef _Dart = ffi.Pointer<ffi.Utf8> Function(ffi.Pointer<ffi.Utf8>,
    ffi.Pointer<ffi.Utf8>, ffi.Pointer<ffi.Utf8>, int, int);

final _func = lib.lookupFunction<_Native, _Dart>("dcngettext");

/// Similar to [dcgettext] but select the plural form corresponding to the
/// number [n].
String dcngettext(
        String domainName, String msgid1, String msgid2, int n, LC category) =>
    _func(domainName.toNativeUtf8(), msgid1.toNativeUtf8(),
            msgid2.toNativeUtf8(), n, category.toInt())
        .toDartString();

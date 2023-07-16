# libintl

Dart bindings for [GetText](https://www.gnu.org/software/gettext/) implementations.

---

`libintl` provides a Dart bindings for the C GetText API, as well as a simple string extractor from source code.

## Usage

First of all you need to have one of the GetText implementing libraries installed on your system. `libintl` doesn't ship any by default.

When the library is initialized, it's automatically looking for `glib`, `libintl` and `libc` in the known paths. You can also specify the path to the shared library manually.

### Initialization

First of all the library needs to be initialized:

```dart
import "package:libintl/libintl.dart" as intl;

void main() {
  intl.init();
}
```

The lirary is initialized automatically, so this is optional, if you don't need to specify the shared library path manually. If yes, you need to run the function with the shared library `File` as an argument:

```dart
import "dart:io";
import "package:libintl/libintl.dart" as intl;

void main() {
  intl.init(File("/usr/lib64/libc.so.6"));
}
```

If loading of the library fails, `LibraryException` is thrown.

### Initial configuration

Next, you need to initialize the locale data:

```dart
import "package:libintl/libintl.dart" as intl;

void main() {
  intl.setLocale(intl.LC.all, "");
  intl.bindTextDomain("my_text_domain", "/usr/share/locale");
  intl.bindTextDomainCodeset("my_text_domain", "UTF-8");
  intl.textDomain("my_text_domain");
}
```

For more information you can check the links bellow:

- https://www.gnu.org/software/gettext/manual/html_node/Triggering.html
- https://docs.gtk.org/glib/i18n.html

### Marking strings as translatable

The most common use case could look similar to this:

```dart
import "package:format/format.dart";
import "package:libintl/libintl.dart" as intl;

const _ = intl.gettext;

void main() {
  intl.setLocale(intl.LC.all, "");
  intl.bindTextDomain("my_text_domain", "/usr/share/locale");
  intl.bindTextDomainCodeset("my_text_domain", "UTF-8");
  intl.textDomain("my_text_domain");

  print(_("Hello, GetText!"));

  print(intl.gettext("You can also use the `gettext` function directly."));

  int count = 10;
  print(
    intl
        .ngettext(
          "The directory contains {} file.",
          "The directory contains {} files.",
          count,
        )
        .format(count),
  );
}
```

## String extraction

The package also includes a tool and library for string extraction from source code.

### CLI tool

The program can be run with the `dart run libintl` command.

The most common usage could look like:

```bash
dart run libintl --from-code=UTF-8 -F my_source_file.dart -o my_text_domain.pot --package-name=my_text_domain
```

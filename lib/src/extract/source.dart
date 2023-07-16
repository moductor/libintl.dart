import "dart:io";

import "catalog.dart";
import "entry.dart";
import "extract_settings.dart";

/// The source file representation.
///
/// It has an [extract] method, that returns a list of [Entry]s extracted
/// from the file. It can be used later to add to a [Catalog].
abstract interface class Source {
  final File file;

  Source(this.file);

  List<Entry> extract(ExtractSettings settings);
}

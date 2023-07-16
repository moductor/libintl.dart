import "dart:io";

import "catalog.dart";
import "dart_source.dart";
import "entry.dart";
import "extract_settings.dart";
import "source.dart";
import "xgettext_source.dart";

/// Handles string extraction from [files].
class Extractor {
  final List<File> files;
  final ExtractSettings settings;

  Extractor(this.files, this.settings);

  Catalog extractCatalog() => Catalog(
        entries: extractEntries(),
        settings: settings,
      );

  List<Entry> extractEntries() {
    final List<File> exceptionFiles = [];

    final List<Entry> entries = [];
    for (var file in files) {
      try {
        entries.addAll(_getSourceForFile(file).extract(settings));
      } on FileSystemException {
        exceptionFiles.add(file);
      }
    }

    if (exceptionFiles.isNotEmpty) throw FileEncodingException(exceptionFiles);

    return entries;
  }

  Source _getSourceForFile(File file) {
    final basename = file.path.split("/").reversed.toList()[0];
    final extension = basename.split(".").reversed.toList()[0];
    if (extension == "dart") return DartSource(file);
    return XgettextSource(file);
  }
}

class FileEncodingException implements Exception {
  final List<File> files;

  String get message => toString();

  FileEncodingException(this.files);

  @override
  String toString() {
    return files
        .map((file) => "Error: Wrong encoding for the ${file.path} file.")
        .join("\n");
  }
}

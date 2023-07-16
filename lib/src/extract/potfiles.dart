import "dart:io";

/// The POTFILES file representation.
///
/// https://www.gnu.org/software/gettext/manual/html_node/po_002fPOTFILES_002ein.html
class Potfiles {
  final File file;

  List<File> get files => getFiles();

  Potfiles(this.file);

  List<File> getFiles() {
    return file
        .readAsLinesSync()
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty && !line.startsWith("#"))
        .map((path) => File(path))
        .toList();
  }
}

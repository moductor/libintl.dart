import "dart:io";

import "catalog.dart";
import "entry.dart";
import "extract_settings.dart";
import "source.dart";

class XgettextSource implements Source {
  @override
  final File file;

  XgettextSource(this.file);

  @override
  List<Entry> extract(ExtractSettings settings) {
    final res = Process.runSync(
      "xgettext",
      [
        "--output=-",
        "--from-code=${_escape(settings.encoding.name)}",
        if (settings.tag != null) "-c${_escape(settings.tag!)}",
        "--width=${settings.textWidth}",
        file.path
      ],
      stdoutEncoding: settings.encoding,
    );

    if (res.exitCode != 0) {
      throw FileSystemException(_formatError(res.stderr), file.path);
    }

    final catalog = Catalog.fromString(settings, res.stdout as String);
    return catalog.entries;
  }

  static String _escape(String val) {
    val = val.replaceAll("'", "\\'");
    val = val.replaceAll('"', '\\"');
    return val;
  }

  static String _formatError(String stderr) {
    return stderr
        .split("\n")
        .where((line) => line.startsWith("xgettext: "))
        .map((line) => line.replaceFirst("xgettext: ", ""))
        .where((line) => !line.startsWith("warning: "))
        .join("\n");
  }
}

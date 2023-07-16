import "dart:io";

import "package:analyzer/dart/analysis/utilities.dart";
import "package:analyzer/dart/ast/ast.dart";

import "entry.dart";
import "extract_settings.dart";
import "message_finding_visitor.dart";
import "source.dart";

class DartSource implements Source {
  @override
  final File file;

  DartSource(this.file);

  @override
  List<Entry> extract(ExtractSettings settings) {
    final root = _parseFile(settings, file);
    final visitor = MessageFindingVisitor(settings, file);
    root.accept(visitor);
    return visitor.entries;
  }

  CompilationUnit _parseFile(ExtractSettings settings, File file) {
    final content = file.readAsStringSync(encoding: settings.encoding);
    final result = parseString(content: content);

    if (result.errors.isNotEmpty) {
      throw FormatException();
    }

    return result.unit;
  }
}

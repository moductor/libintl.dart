import "dart:io";

import "package:analyzer/dart/ast/ast.dart";
import "package:analyzer/dart/ast/token.dart";
import "package:analyzer/dart/ast/visitor.dart";

import "entry.dart";
import "extract_settings.dart";
import "parsers.dart";

typedef Parser = Entry Function(
  ExtractSettings,
  File,
  MethodInvocation,
  List<String>,
);

class MessageFindingVisitor extends GeneralizingAstVisitor {
  static const package = "package:libintl/libintl.dart";

  static const Map<String, Parser> functions = {
    "gettext": parseGettext,
    "dgettext": parseDgettext,
    "dcgettext": parseDcgettext,
    "ngettext": parseNgettext,
    "dngettext": parseDngettext,
    "dcngettext": parseDcngettext,
    "pgettext": parsePgettext,
    "dpgettext": parseDpgettext,
    "dcpgettext": parseDcpgettext,
  };

  final File file;

  final List<Entry> entries = [];

  bool _imported = false;
  String? _importPrefix;
  final Map<String, String> _aliases = {};
  final List<String> _currentComments = [];

  final ExtractSettings settings;

  MessageFindingVisitor(this.settings, this.file);

  /// Finds the import prefix of the library.
  @override
  visitImportDirective(ImportDirective node) {
    // Only if the import isn't done yet and if it is an import of the library.
    if (_imported || node.uri.stringValue != package) return;
    _imported = true;
    if (node.prefix != null) _importPrefix = node.prefix!.name;
  }

  /// Finds all the aliases for GetText functions.
  @override
  visitVariableDeclaration(VariableDeclaration node) {
    // Only when imported and for constants whose value is an identifier.
    if (!_imported || !node.isConst || node.initializer is! Identifier) {
      return super.visitVariableDeclaration(node);
    }

    String alias = node.name.lexeme; // The name of the alias.
    String aliased; // The function it aliases.

    // Has the identifier prefix?
    if (node.initializer is PrefixedIdentifier) {
      // Valid only if the library is also imported with a prefix.
      if (_importPrefix == null) return;

      final initializer = node.initializer as PrefixedIdentifier;

      // Continue if the prefixes doesn't match.
      if (initializer.prefix.name != _importPrefix) return;

      aliased = initializer.identifier.name;
    } else {
      aliased = (node.initializer as SimpleIdentifier).name;
    }

    if (!functions.keys.contains(aliased)) return;

    _aliases[alias] = aliased;
  }

  /// Loads string comments.
  @override
  visitExpressionStatement(ExpressionStatement node) {
    if (settings.tag == null) return super.visitExpressionStatement(node);

    // Load all comments before the statement.
    _currentComments.addAll(_formatComments(_getComments(node.beginToken)));
    // Process the statement.
    super.visitExpressionStatement(node);
    // Clear the comments.
    _currentComments.clear();
  }

  @override
  visitMethodInvocation(MethodInvocation node) {
    if (!_imported) return;

    if (node.realTarget != null &&
        (node.realTarget is! SimpleIdentifier ||
            (node.realTarget as SimpleIdentifier).name != _importPrefix)) {
      return super.visitMethodInvocation(node);
    }

    final name = node.methodName.name;
    if (!functions.keys.contains(name) && !_aliases.keys.contains(name)) {
      return super.visitMethodInvocation(node);
    }

    final parse = functions[name] ?? functions[_aliases[name]];
    if (parse == null) return;
    entries.add(parse(settings, file, node, _currentComments));
  }

  /// Gets all comments before the given [codeToken].
  List<Token> _getComments(Token codeToken) {
    final List<Token> comments = [];
    Token? comment = codeToken.precedingComments;
    while (comment != null) {
      comments.add(comment);
      comment = comment.next;
    }
    return comments;
  }

  /// Formats the [rawComments] list returned by [_getComments].
  List<String> _formatComments(List<Token> rawComments) {
    final List<String> comments = [];
    for (var commentToken in rawComments) {
      var comment = commentToken.lexeme;

      if (comment.startsWith("/*") && comment.endsWith("*/")) {
        comments.addAll(_formatMultilineComment(comment).split("\n"));
        continue;
      }

      if (!comment.startsWith("//")) continue;

      if (comment.startsWith("///")) comment = comment.replaceFirst("/", "");
      comments.addAll(_formatSinglelineComment(comment).split("\n"));
    }

    return comments
        .where(
          (comment) => comment.startsWith("${settings.tag}"),
        )
        .toList();
  }

  String _formatMultilineComment(String comment) {
    comment = comment.replaceFirst("/*", "").replaceFirst("*/", "");
    comment = comment.split("\n").map((line) {
      line = line.trim();
      if (line.startsWith("*")) line = line.replaceFirst("*", "").trim();
      return line;
    }).join("\n");
    return comment;
  }

  String _formatSinglelineComment(String comment) {
    return comment.replaceFirst("//", "").trim();
  }
}

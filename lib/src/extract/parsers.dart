import "dart:io";

import "package:analyzer/dart/ast/ast.dart";

import "entry.dart";
import "extract_settings.dart";
import "file_row_util.dart";
import "reference.dart";

Expression _getArg(MethodInvocation invocation, int i) {
  return invocation.argumentList.arguments[i];
}

String _getStringArg(MethodInvocation invocation, int i) {
  final arg = _getArg(invocation, i);

  if (arg is! SimpleStringLiteral) {
    throw Exception("`${arg.toString()}` is not a constant string!");
  }

  String output = Entry.removeQuotes(arg.literal.toString());
  if (arg.isSingleQuoted) output = output.replaceAll('"', '\\"');

  return output;
}

Entry _prepareParsing(
  ExtractSettings settings,
  File file,
  MethodInvocation invocation,
  List<String> comments,
) {
  return Entry(
    extractedComment: comments,
    references: [
      Reference(file: file, row: getRowPosInFile(file, invocation.offset))
    ],
    settings: settings,
  );
}

Entry parseGettext(
  ExtractSettings settings,
  File file,
  MethodInvocation invocation,
  List<String> comments,
) {
  final entry = _prepareParsing(settings, file, invocation, comments);
  entry.msgid = _getStringArg(invocation, 0);
  return entry;
}

Entry parseDgettext(
  ExtractSettings settings,
  File file,
  MethodInvocation invocation,
  List<String> comments,
) {
  final entry = _prepareParsing(settings, file, invocation, comments);
  entry.msgid = _getStringArg(invocation, 1);
  return entry;
}

const parseDcgettext = parseDgettext;

Entry parseNgettext(
  ExtractSettings settings,
  File file,
  MethodInvocation invocation,
  List<String> comments,
) {
  final entry = _prepareParsing(settings, file, invocation, comments);
  entry.msgid = _getStringArg(invocation, 0);
  entry.msgidPlural = _getStringArg(invocation, 1);
  return entry;
}

Entry parseDngettext(
  ExtractSettings settings,
  File file,
  MethodInvocation invocation,
  List<String> comments,
) {
  final entry = _prepareParsing(settings, file, invocation, comments);
  entry.msgid = _getStringArg(invocation, 1);
  entry.msgidPlural = _getStringArg(invocation, 2);
  return entry;
}

const parseDcngettext = parseDngettext;

Entry parsePgettext(
  ExtractSettings settings,
  File file,
  MethodInvocation invocation,
  List<String> comments,
) {
  final entry = _prepareParsing(settings, file, invocation, comments);
  entry.msgctxt = _getStringArg(invocation, 0);
  entry.msgid = _getStringArg(invocation, 1);
  return entry;
}

Entry parseDpgettext(
  ExtractSettings settings,
  File file,
  MethodInvocation invocation,
  List<String> comments,
) {
  final entry = _prepareParsing(settings, file, invocation, comments);
  entry.msgctxt = _getStringArg(invocation, 1);
  entry.msgid = _getStringArg(invocation, 2);
  return entry;
}

const parseDcpgettext = parseDpgettext;

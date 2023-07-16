import "dart:io";

import "entry.dart";
import "extract_settings.dart";

/// The PO file catalog representation.
///
/// https://www.gnu.org/software/gettext/manual/html_node/PO-Files.html
class Catalog {
  Entry? header;
  final List<Entry> entries = [];
  final ExtractSettings settings;

  Catalog({
    Entry? header,
    List<Entry> entries = const [],
    required this.settings,
  }) {
    this.header?.indentTranslatorComment = false;
    this.entries.addAll(entries);
  }

  factory Catalog.fromString(ExtractSettings settings, String catalog) {
    final entryStrings = catalog.trim().split("\n\n");

    // Get the header entry.
    Entry? header = Entry.fromString(settings, entryStrings[0]);
    // We care only if the msgid is "".
    if (header.msgid == "") {
      entryStrings.removeAt(0);
    } else {
      header = null;
    }

    // Convert the rest of the list into a list of entries.
    final entriesIter = entryStrings.map((e) => Entry.fromString(settings, e));
    final entries = List<Entry>.from(entriesIter);

    return Catalog(header: header, entries: entries, settings: settings);
  }

  factory Catalog.fromFile(ExtractSettings settings, File file) {
    return Catalog.fromString(settings, file.readAsStringSync());
  }

  /// Join together duplicate entries.
  void reduceDuplicates() {
    // The new list of entries.
    final List<Entry> newEntries = [];

    for (var entry in entries) {
      // The duplicate that comes before the current entry.
      Entry? prevEntry;

      try {
        prevEntry = newEntries.firstWhere((other) {
          // The msgid must be the same.
          if (entry.msgid != other.msgid) return false;

          // As well as the msgctxt.
          if (entry.msgctxt != other.msgctxt) return false;

          // And the plurals must match, or at least one of them must be null.
          if (entry.msgidPlural != other.msgidPlural &&
              entry.msgidPlural != null &&
              other.msgidPlural != null) {
            return false;
          }

          // And we don't join entries, that don't have msgstr empty.
          if (entry.msgstr.isNotEmpty || other.msgstr.isNotEmpty) return false;
          if (entry.msgstrList.isNotEmpty || other.msgstrList.isNotEmpty) {
            return false;
          }

          return true;
        });
      } on StateError {
        //
      }

      if (prevEntry == null) {
        newEntries.add(entry);
        continue;
      }

      prevEntry.translatorComment.addAll(entry.translatorComment);
      final translatorComment = prevEntry.translatorComment.toSet().toList();
      prevEntry.translatorComment.clear();
      prevEntry.translatorComment.addAll(translatorComment);

      prevEntry.extractedComment.addAll(entry.extractedComment);
      final extractedComment = prevEntry.extractedComment.toSet().toList();
      prevEntry.extractedComment.clear();
      prevEntry.extractedComment.addAll(extractedComment);

      prevEntry.references.addAll(entry.references);

      if (prevEntry.msgidPlural == null && entry.msgidPlural != null) {
        prevEntry.msgidPlural = entry.msgidPlural;
        prevEntry.msgstrList.clear();
        prevEntry.msgstrList.addAll(entry.msgstrList);
      }
    }

    entries.clear();
    entries.addAll(newEntries);
  }

  @override
  String toString() {
    final List<Entry> output = [];
    if (header != null) output.add(header!);
    output.addAll(entries);
    return output.join("\n\n");
  }

  static Entry getDefaultHeaderEntry(ExtractSettings settings) {
    return Entry(
      msgid: "",
      msgstr: getHeaderMsgstr(
        package: settings.packageName,
        version: settings.packageVersion,
        reportBugsTo: settings.reportBugsTo,
      ),
      translatorComment: [
        getHeaderComment(
          package: settings.packageName,
          copyrightHolder: settings.copyrightHolder,
        )
      ],
      flags: ["fuzzy"],
      settings: settings,
    );
  }

  static String getHeaderComment({
    String? package,
    String? copyrightHolder,
  }) {
    package ??= "PACKAGE";
    copyrightHolder ??= "THE $package'S COPYRIGHT HOLDER";

    return "SOME DESCRIPTIVE TITLE.\n"
        "Copyright (C) YEAR $copyrightHolder\n"
        "This file is distributed under the same license as the $package package.\n"
        "FIRST AUTHOR <EMAIL@ADDRESS>, YEAR.\n";
  }

  static String getHeaderMsgstr({
    String? package,
    String? version,
    String reportBugsTo = "",
    String? potCreationDate,
    String poRevisionDate = "YEAR-MO-DA HO:MI+ZONE",
    String lastTranslator = "FULL NAME <EMAIL@ADDRESS>",
    String languageTeam = "LANGUAGE <LL@li.org>",
    String language = "",
    String charset = "CHARSET",
    int? nplurals,
    String plural = "EXPRESSION",
  }) {
    potCreationDate ??= formatPoDateTime(DateTime.now());

    final pkgver = package == null
        ? "PACKAGE VERSION"
        : "$package${version == null ? "" : " $version"}";

    return "Project-Id-Version: $pkgver\\n"
        "Report-Msgid-Bugs-To: $reportBugsTo\\n"
        "POT-Creation-Date: $potCreationDate\\n"
        "PO-Revision-Date: $poRevisionDate\\n"
        "Last-Translator: $lastTranslator\\n"
        "Language-Team: $languageTeam\\n"
        "Language: $language\\n"
        "MIME-Version: 1.0\\n"
        "Content-Type: text/plain; charset=$charset\\n"
        "Content-Transfer-Encoding: 8bit\\n"
        "Plural-Forms: nplurals=${nplurals ?? "INTEGER"}; plural=$plural;\\n";
  }

  static String formatPoDateTime(DateTime dt) {
    final tzOff = dt.timeZoneOffset;
    final tzPref = tzOff.isNegative ? "-" : "+";
    final tzH = (tzOff.inMinutes.abs() / 60).floor().toString().padLeft(2, "0");
    final tzM = (tzOff.inMinutes.abs() % 60).toString().padLeft(2, "0");
    final tz = "$tzPref$tzH$tzM";

    final date = "${dt.year}-${dt.month}-${dt.day}";
    final time = "${dt.hour}:${dt.minute}$tz";

    return "$date $time";
  }
}

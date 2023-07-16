import "extract_settings.dart";
import "reference.dart";

/// The PO file entry representation.
///
/// https://www.gnu.org/software/gettext/manual/html_node/PO-Files.html
///
/// ```
/// #  translator-comments
/// #. extracted-comments
/// #: reference…
/// #, flag…
/// #| msgid previous-untranslated-string
/// msgid untranslated-string
/// msgstr translated-string
/// ```
///
/// It's created only for the purpose of extracting strings from Dart code,
/// so we don't support all format features, such as the previous msgid.
class Entry {
  final List<String> translatorComment = [];
  final List<String> extractedComment = [];

  final List<Reference> references = [];

  final List<String> flags = [];

  String msgid;
  String? msgidPlural;
  String? msgctxt;

  String msgstr;
  final List<String> msgstrList = [];

  bool indentTranslatorComment = true;

  final ExtractSettings settings;

  Entry({
    List<String> translatorComment = const [],
    List<String> extractedComment = const [],
    List<String> flags = const [],
    this.msgid = "",
    this.msgidPlural,
    this.msgctxt,
    this.msgstr = "",
    List<String> msgstrList = const [],
    List<Reference> references = const [],
    required this.settings,
  }) {
    this.translatorComment.addAll(translatorComment);
    this.extractedComment.addAll(extractedComment);
    this.flags.addAll(flags);
    this.msgstrList.addAll(msgstrList);
    this.references.addAll(references);
  }

  /// Parses the string representation of [Entry]
  ///
  /// This method never fails. It tries to create an instance of [Entry] from
  /// any string. Therefore, it is not good to use it for validation.
  factory Entry.fromString(ExtractSettings settings, String value) {
    final entry = Entry(settings: settings, msgstrList: []);
    final lines = value.trim().split("\n");

    for (int i = 0; i < lines.length; i++) {
      final isLast = (i == (lines.length - 1));
      final line = lines[i].trim();

      // For all the comments.
      if (line.startsWith("#")) {
        // Parse reference.
        if (line.startsWith("#:")) {
          final references = line
              .replaceFirst("#:", "")
              .trim()
              .split(" ")
              .map((part) => Reference.fromString(part))
              .where((reference) => reference != null)
              .map((reference) => reference as Reference);

          entry.references.addAll(references);
          continue;
        }

        // Parse flags.
        if (line.startsWith("#,")) {
          final flagList = line.replaceFirst("#,", "").trim().split(",");
          entry.flags.addAll(flagList.map((flag) => flag.trim()));
          continue;
        }

        // Parse extracted comments.
        if (line.startsWith("#.")) {
          entry.extractedComment.add(line.replaceFirst("#.", "").trim());
          continue;
        }

        // Parse translator's comments.
        entry.translatorComment.add(line.replaceFirst("#", "").trim());
        continue;
      }

      // For all the prefixed values.

      // Parse plural msgid.
      if (line.startsWith("msgid_plural")) {
        // Get the first line.
        entry.msgidPlural =
            removeQuotes(line.replaceFirst("msgid_plural", "").trim());

        // If the next line starts with quotes.
        if (!isLast && lines[i + 1].trim().startsWith('"')) {
          // Iterate through the next lines starting with quotes.
          for (int j = i + 1;
              j < lines.length && lines[j].trim().startsWith('"');
              j++) {
            // Add the content to the original string;
            entry.msgidPlural = entry.msgidPlural! + removeQuotes(lines[j]);
          }
        }

        continue;
      }

      // Parse msgid.
      if (line.startsWith("msgid")) {
        // Get the first line.
        entry.msgid = removeQuotes(line.replaceFirst("msgid", "").trim());

        // If the next line starts with quotes.
        if (!isLast && lines[i + 1].trim().startsWith('"')) {
          // Iterate through the next lines starting with quotes.
          for (int j = i + 1;
              j < lines.length && lines[j].trim().startsWith('"');
              j++) {
            entry.msgid = entry.msgid + removeQuotes(lines[j]);
          }
        }

        continue;
      }

      // Parse indexed msgstr.
      if (line.startsWith("msgstr[")) {
        // Get the first line. We don't care about the index, just the position.
        var content = removeQuotes(
          line.replaceFirst("${line.split("]")[0]}]", "").trim(),
        );

        // If the next line starts with quotes.
        if (!isLast && lines[i + 1].trim().startsWith('"')) {
          // Iterate through the next lines starting with quotes.
          for (int j = i + 1;
              j < lines.length && lines[j].trim().startsWith('"');
              j++) {
            // Append the next line to the string.
            content += removeQuotes(lines[j]);
          }
        }

        // Add the string to the list.
        entry.msgstrList.add(content);

        continue;
      }

      // Parse msgstr.
      if (line.startsWith("msgstr")) {
        // Get the first line.
        entry.msgstr = removeQuotes(line.replaceFirst("msgstr", "").trim());

        // If the next line starts with quotes.
        if (!isLast && lines[i + 1].trim().startsWith('"')) {
          // Iterate through the next lines starting with quotes.
          for (int j = i + 1;
              j < lines.length && lines[j].trim().startsWith('"');
              j++) {
            entry.msgstr = entry.msgstr + removeQuotes(lines[j]);
          }
        }

        continue;
      }

      // Parse msgctxt.
      if (line.startsWith("msgctxt")) {
        // Get the first line.
        entry.msgctxt = removeQuotes(line.replaceFirst("msgctxt", "").trim());

        // If the next line starts with quotes.
        if (!isLast && lines[i + 1].trim().startsWith('"')) {
          // Iterate through the next lines starting with quotes.
          for (int j = i + 1;
              j < lines.length && lines[j].trim().startsWith('"');
              j++) {
            entry.msgctxt = entry.msgctxt! + removeQuotes(lines[j]);
          }
        }

        continue;
      }
    }

    // Clear msgstr list if it's empty.
    bool empty = true;
    for (var element in entry.msgstrList) {
      if (element.trim().isNotEmpty) {
        empty = false;
        break;
      }
    }
    if (empty) entry.msgstrList.clear();

    return entry;
  }

  /// Generates the string representation of this [Entry].
  @override
  String toString() {
    List<String> output = [];

    for (var comment in translatorComment) {
      final prefix = "#${indentTranslatorComment ? " " : ""}";
      output.add("$prefix $comment");
    }

    for (var comment in extractedComment) {
      output.add("#. $comment");
    }

    for (var reference in references) {
      output.add("#: $reference");
    }

    if (flags.isNotEmpty) output.add("#, ${flags.join(", ")}");

    if (msgctxt != null) output.add(toMultiLine(settings, "msgctxt", msgctxt!));

    output.add(toMultiLine(settings, "msgid", msgid));

    if (msgidPlural != null) {
      output.add(toMultiLine(settings, "msgid_plural", msgidPlural!));
      if (msgstrList.isNotEmpty) {
        for (int i = 0; i < msgstrList.length; i++) {
          output.add(toMultiLine(settings, "msgstr[$i]", msgstrList[i]));
        }
      } else {
        output.add('msgstr[0] ""');
        output.add('msgstr[1] ""');
      }
    } else {
      output.add(toMultiLine(settings, "msgstr", msgstr));
    }

    return output.join("\n");
  }

  /// Trims quotes (the first and the last character).
  static String removeQuotes(String value) =>
      value.substring(1, value.length - 1);

  /// Converts single line [value] into [prefix]ed multi line PO string.
  ///
  /// For example, this call:
  /// ```dart
  /// _toMultiLine("msgid", "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.");
  /// ```
  /// returns following:
  /// ```po
  /// msgid ""
  /// "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod "
  /// "tempor incididunt ut labore et dolore magna aliqua."
  /// ```
  static String toMultiLine(
      ExtractSettings settings, String prefix, String value) {
    // We create multi lines just for strings that doesn't contain `\n` or are
    // longer than the set text width including the length of the prefix.
    if (!value.contains("\\n") &&
        '$prefix "$value"'.length <= settings.textWidth) {
      return '$prefix "$value"'; // Counting the quotes and the space as well.
    }

    // The ideal would be to split the text along `\n` and it would fit into
    // the text width. Let's give it a try.
    // Also, we need to put that `\n` back.
    final lines = value.split("\\n");
    for (int i = 0; i < lines.length - 1; i++) {
      lines.insert(i, "${lines.removeAt(i)}\\n");
    }

    // Let's check how it went. We will go through each line and correct those
    // that are longer than the set text width.
    for (int i = 0; i < lines.length; i++) {
      var line = lines[i];

      // It worked? Then skip this line.
      if (line.length + 2 <= settings.textWidth) {
        continue;
      }

      // Remove the line from the list, we'll add two new ones back later.
      lines.removeAt(i);

      final words = line.split(" "); // List of words in the line.
      var part = ""; // The first part of the line that fits in the set width.

      // Gradually add words until they fit into the set text width.
      // + 3 = quotes + space
      while (part.length + words[0].length + 3 <= settings.textWidth) {
        part += "${words.removeAt(0)} "; // Add the space back as well.
      }

      // Insert both parts of the line in the original place.
      lines.insertAll(i, [part, line.replaceFirst(part, "")]);
    }

    return [
      '$prefix ""',
      // Filter out blank lines and enclose them in quotes.
      ...lines.where((line) => line.isNotEmpty).map((line) => '"$line"')
    ].join("\n"); // Concatenate the rows back into a single string.
  }
}

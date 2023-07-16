import "dart:convert";
import "dart:io";

import "package:args/args.dart";
import "package:libintl/extract.dart";

void main(List<String> args) async {
  final parser = ArgParser(usageLineLength: 80);
  _initParser(parser);

  if (args.isEmpty) _printHelp(parser);

  final results = parser.parse(args);

  if (results["help"] as bool) _printHelp(parser);

  final List<String> errors = [];
  final List<File> inputs = [];
  File output;

  if (results["files-from"] != null) {
    final potfile = File(results["files-from"] as String);
    if (!potfile.existsSync()) {
      errors.add(_getFileDoesntExistError(potfile));
    } else {
      final potfiles = Potfiles(potfile);

      for (var file in potfiles.files) {
        if (!file.existsSync()) {
          errors.add(_getFileDoesntExistError(file));
          continue;
        }

        inputs.add(file);
      }
    }
  }

  if (results["file"] != null) {
    final files = (results["file"] as Iterable<String>).map((f) => File(f));

    for (var file in files) {
      if (!file.existsSync()) {
        errors.add(_getFileDoesntExistError(file));
        continue;
      }

      inputs.add(file);
    }
  }

  if (results["directory"] != null) {
    final dirs = results["directory"] as Iterable<String>;

    for (var dir in dirs) {
      final directory = Directory(dir);
      if (!directory.existsSync()) {
        errors.add(_getFileDoesntExistError(directory));
        continue;
      }

      final files = directory
          .listSync(recursive: true)
          .map((entity) => File(entity.path));

      for (var file in files) {
        if (!file.existsSync()) {
          errors.add(_getFileDoesntExistError(file));
          continue;
        }

        inputs.add(file);
      }
    }
  }

  assert(results["output"] != null);
  output = File(results["output"] as String);

  if (errors.isNotEmpty) {
    print(errors.join("\n"));
    exit(1);
  }

  final settings = _parseSettings(results);
  final extractor = Extractor(inputs, settings);

  Catalog catalog;

  try {
    catalog = extractor.extractCatalog();
  } catch (e) {
    print(e);
    exit(1);
  }

  catalog.reduceDuplicates();

  if (!(results["omit-header"] as bool)) {
    catalog.header = Catalog.getDefaultHeaderEntry(settings);
  }

  if (output.path == "-") {
    print(catalog);
    exit(0);
  }

  output.writeAsStringSync(catalog.toString());
}

Never _printHelp(ArgParser parser) {
  print(
    "libintl extractor - string extracting tool for libintl\n"
    "\n"
    "${parser.usage}",
  );

  return exit(0);
}

String _getFileDoesntExistError(FileSystemEntity file) {
  return "Error: ${file.path} doesn't exist!";
}

void _initParser(ArgParser parser) {
  // Input file location section.

  parser.addSeparator("Input file location:");

  parser.addOption(
    "files-from",
    abbr: "f",
    valueHelp: "FILE",
    help: "Get list of input files from FILE.",
  );

  parser.addMultiOption(
    "file",
    abbr: "F",
    valueHelp: "FILE",
    help: "Add FILE to list for input files search.",
  );

  parser.addMultiOption(
    "directory",
    abbr: "D",
    valueHelp: "DIRECTORY",
    help: "Add DIRECTORY to list for input files search.",
  );

  // Output file location section.

  parser.addSeparator("Output file location:");

  parser.addOption(
    "output",
    abbr: "o",
    valueHelp: "FILE",
    help: "Write output to specified file.",
    mandatory: true,
  );

  // Input file configuration section.

  parser.addSeparator("Input file configuration:");

  parser.addOption(
    "from-code",
    valueHelp: "NAME",
    help: "Encoding of input files.\n"
        "Defaults to ASCII.",
  );

  parser.addOption(
    "add-comments",
    abbr: "c",
    valueHelp: "TAG",
    help: "Place comment blocks starting with TAG and "
        "preceding keyword lines in output file.\n"
        'Set to "" to place all comment blocks preceding '
        "keyword lines in output file.",
  );

  // Output file configuration section.

  parser.addSeparator("Output file configuration:");

  parser.addOption(
    "width",
    abbr: "w",
    valueHelp: "NUMBER",
    help: "Text width of the output.\n"
        "Defaults to 80 characters.",
  );

  parser.addOption(
    "copyright-holder",
    valueHelp: "STRING",
    help: "Set copyright holder in output.",
  );

  parser.addOption(
    "package-name",
    valueHelp: "PACKAGE",
    help: "Set package name in output.",
  );

  parser.addOption(
    "package-version",
    valueHelp: "VERSION",
    help: "Set package version in output.",
  );

  parser.addOption(
    "msgid-bugs-address",
    valueHelp: "EMAIL@ADDRESS",
    help: "Set report address for msgid bugs.",
  );

  parser.addFlag(
    "omit-header",
    negatable: false,
    help: "Don't write header with 'msgid \"\"' entry.",
  );

  // Informative output section.

  parser.addSeparator("Informative output:");

  parser.addFlag(
    "help",
    abbr: "h",
    negatable: false,
    help: "Display this help and exit.",
  );
}

ExtractSettings _parseSettings(ArgResults results) {
  final settings = ExtractSettings();

  if (results["from-code"] != null) {
    final encoding = Encoding.getByName(results["from-code"] as String);
    if (encoding != null) settings.encoding = encoding;
  }

  if (results["add-comments"] != null) {
    settings.tag = results["add-comments"] as String;
  }

  if (results["width"] != null) {
    settings.textWidth = int.parse(results["width"] as String);
  }

  if (results["copyright-holder"] != null) {
    settings.copyrightHolder = results["copyright-holder"] as String;
  }

  if (results["package-name"] != null) {
    settings.packageName = results["package-name"] as String;
  }

  if (results["package-version"] != null) {
    settings.packageVersion = results["package-version"] as String;
  }

  if (results["msgid-bugs-address"] != null) {
    settings.reportBugsTo = results["msgid-bugs-address"] as String;
  }

  return settings;
}

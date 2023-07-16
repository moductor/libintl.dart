import "dart:ffi" as ffi;
import "dart:io";

/// Initializes the libintl static [lib].
///
/// Optionally you can provide the static library [file] path.
///
/// If loading of the library fails, [LibraryException] is thrown.
void init([File? file]) => _Library.init(file);

/// The static library libintl uses.
///
/// The getter also tries to automatically [init] the library.
ffi.DynamicLibrary get lib {
  init();
  return _Library.library.lib;
}

/// Exception, that can happen while initializing the static [lib].
enum LibraryException implements Exception {
  libraryNotFound,
  libraryLoadingFailed;
}

/// Handles the library initialization and owns the [lib] instance.
class _Library {
  /// The static [lib] path.
  final File file;

  /// The static library.
  final ffi.DynamicLibrary lib;

  _Library._(this.file, this.lib);

  /// The only instance of this class.
  ///
  /// It is initialized with the private constructor used in the [init] method.
  static _Library get library => _library!;

  /// Private member for [library].
  static _Library? _library;

  /// Initializes the static [lib] and the [library] instance.
  ///
  /// Throws [LibraryException] on error.
  static void init([File? file]) {
    // Return if already initialized.
    if (_library != null) return;

    // If no file was provided try to find the default one.
    file ??= _getLibFile();

    // If nothing was found, throw exception.
    if (file == null) throw LibraryException.libraryNotFound;

    ffi.DynamicLibrary lib;

    try {
      // Try to open the library file.
      lib = ffi.DynamicLibrary.open(file.path);
    } on ArgumentError {
      // If anything fails, throw exception.
      throw LibraryException.libraryLoadingFailed;
    }

    // Create the only library instance.
    _library = _Library._(file, lib);
  }
}

/// Wrapper for [_findLibFile] using the current platform name.
File? _getLibFile() {
  final platform = _getPlatformName();
  return _findLibFile(_dirs[platform]!, _extensions[platform]!);
}

/// Returns the current platform name.
String _getPlatformName() {
  if (Platform.isWindows) {
    return "windows";
  } else if (Platform.isMacOS) {
    return "macos";
  }
  return "linux";
}

/// Gets the first file in dir [paths], that matches the [_libs] name
/// with [extension], or `null` when nothing was found.
File? _findLibFile(List<String> paths, String extension) {
  try {
    return _listFiles(paths).firstWhere((file) {
      final name = _getBaseName(file);
      for (var lib in _libs) {
        if (name.startsWith("$lib.$extension")) return true;
      }
      return false;
    });
  } on StateError {
    return null;
  }
}

/// Gets all files in dir [paths].
List<File> _listFiles(List<String> paths) {
  List<File> files = [];
  for (var path in paths) {
    final dir = Directory(path);
    if (!dir.existsSync()) continue;
    files.addAll(dir.listSync().where((element) {
      return element.statSync().type == FileSystemEntityType.file;
    }).map((file) => File(file.path)));
  }
  return files;
}

/// Gets basename for the [file].
String _getBaseName(FileSystemEntity file) {
  return file.path.split(Platform.pathSeparator).reversed.toList()[0];
}

// Config for the default static library files.

final _libs = [
  "libglib-2.0",
  "libintl",
  "libc",
];

final _dirs = {
  "linux": [
    "/usr/lib64",
    "/usr/local/lib64",
    "/usr/lib",
    "/usr/local/lib",
  ],
  "windows": Platform.environment["PATH"]!.split(";"),
  "macos": [
    "/usr/lib",
    "/usr/local/lib",
  ],
};

final _extensions = {
  "linux": "so",
  "windows": "dll",
  "macos": "dylib",
};

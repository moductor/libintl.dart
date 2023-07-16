import "dart:io";

/// Representation of the file reference line in the PO file entry.
///
/// ```
/// #: file_name:line_number
/// ```
class Reference {
  final File file;
  final int? row;

  Reference({required this.file, this.row});

  static Reference? fromString(String value) {
    final list = value.trim().split(":");
    if (list.isEmpty || list.length > 2) return null;
    return Reference(
        file: File(list.removeAt(0)),
        row: (list.isNotEmpty) ? int.parse(list[0]) : null);
  }

  @override
  String toString() => "${file.path}${(row != null) ? ":$row" : ""}";
}

import "dart:io";

/// Converts the [offset] number into the row number in [file].
int getRowPosInFile(File file, int offset) {
  final lines = file.readAsStringSync().split("\n");

  // -1 because we are incrementing the value right away.
  int currentRow = -1;

  while (offset > 0) {
    // Gradually subtract individual line lengths and increase the row number.
    currentRow++;
    final line = "${lines[currentRow]}\n";
    offset = offset - line.length;
  }

  // +1 because we need the human readable index.
  return currentRow + 1;
}

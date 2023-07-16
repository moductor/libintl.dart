import "dart:convert";

class ExtractSettings {
  Encoding encoding = Encoding.getByName("ASCII")!;
  int textWidth = 80;

  String? tag;

  String? copyrightHolder;
  String? packageName;
  String? packageVersion;
  String reportBugsTo = "";
}

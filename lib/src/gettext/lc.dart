/// The purposes that locales serve are grouped into categories, so that a user
/// or a program can choose the locale for each category independently.
enum LC {
  /// Selects the character classification category of the C locale.
  ctype,

  /// Selects the numeric formatting category of the C locale.
  numeric,

  /// Selects the time formatting category of the C locale.
  time,

  /// Selects the collation category of the C locale.
  collate,

  /// Selects the monetary formatting category of the C locale.
  monetary,

  /// The language that should be used.
  messages,

  /// Selects the entire C locale.
  all;

  /// Converts this instance of LC into int.
  int toInt() => values.indexOf(this);

  /// Converts the int [value] into an instance of LC.
  static LC fromInt(int value) => values[value];
}

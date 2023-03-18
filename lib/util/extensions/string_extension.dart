extension StringExtension on String {
  String get extractMainUrl {
    final String origin = Uri.parse(this).origin;

    return origin;
  }

  String get getFileNameFromPath {
    return substring(lastIndexOf('\\') + 1, lastIndexOf('.'));
  }

  /// Very basic!
  String get cleanWindows {
    return replaceAll("[\\*/\\\\!\\|:?<>]", "_").replaceAll("(%22)", "_");
  }
}

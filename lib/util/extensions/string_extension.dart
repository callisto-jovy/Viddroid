extension StringExtension on String {
  String get extractMainUrl {
    final String origin = Uri.parse(this).origin;

    return origin;
  }
}

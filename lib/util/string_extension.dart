extension StringExtension on String {
  String get extractMainUrl => Uri.parse(this).origin;
}

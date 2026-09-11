class StringParser {
  static String parseString(String mainString, String parseBy) {
    if (mainString.contains('&&') && mainString.contains('=')) {
      final parts = mainString.split('&&');
      List<String> tokenPart = [];

      for (final element in parts) {
        if (element.contains(parseBy)) {
          tokenPart = element.split('$parseBy=');
        }
      }
      if (tokenPart.isNotEmpty) {
        return tokenPart.last;
      }
      return '';
    }
    return '';
  }

  static String obfuscateMiddle(String input) {
    if (input.length <= 7) {
      return input;
    }
    final start = input.substring(0, 4);
    final end = input.substring(input.length - 3);
    final middle = '*' * (input.length - 7);
    return '$start$middle$end';
  }
}

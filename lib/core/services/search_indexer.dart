class SearchIndexer {
  /// The core normalization pipeline: lowercase, remove punctuation, remove extra whitespace.
  static String normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Generates a list of unique search tokens (at least 3 characters long).
  static List<String> tokenize(String text) {
    final normalized = normalize(text);
    if (normalized.isEmpty) return [];
    
    return normalized
        .split(' ')
        .where((token) => token.length >= 3)
        .toSet() // Ensure uniqueness
        .toList();
  }

  /// Privacy Masking: Masks credit cards, long account numbers, etc.
  /// Example: 1234 5678 9012 3456 -> ****3456
  static String maskSensitiveData(String text) {
    // 1. Mask 13-19 digit card numbers (handling potential spaces/dashes)
    final cardRegex = RegExp(r'\b(?:\d[ -]*?){13,19}\b');
    
    return text.replaceAllMapped(cardRegex, (match) {
      final digits = match.group(0)!.replaceAll(RegExp(r'[ -]'), '');
      if (digits.length < 4) return digits;
      return '****${digits.substring(digits.length - 4)}';
    });
  }

  /// The complete pipeline for preparing a searchable blob.
  static ({String content, List<String> tokens}) index(String rawText) {
    // 1. Mask sensitive info FIRST
    final masked = maskSensitiveData(rawText);
    
    // 2. Normalize and Tokenize
    final normalized = normalize(masked);
    final tokens = tokenize(normalized);
    
    return (content: normalized, tokens: tokens);
  }
}

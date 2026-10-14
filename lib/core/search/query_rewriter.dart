class QueryRewriter {
  static List<String> rewrite(String originalQuery) {
    final queries = <String>[originalQuery];
    
    // Extract key terms by removing filler words
    final stopWords = {'the', 'a', 'an', 'is', 'are', 'was', 'were', 'what', 'how', 'why', 'when', 'where', 'who', 'which', 'can', 'could', 'would', 'should', 'will', 'do', 'does', 'did', 'to', 'of', 'in', 'for', 'on', 'with', 'at', 'by', 'from', 'it', 'this', 'that', 'and', 'or', 'but', 'not', 'i', 'you', 'we', 'they', 'my', 'your', 'tell', 'me', 'about', 'give', 'find', 'search'};
    
    final words = originalQuery.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '').split(RegExp(r'\s+'));
    final keyTerms = words.where((w) => w.length > 2 && !stopWords.contains(w)).toList();
    
    if (keyTerms.isNotEmpty && keyTerms.length < words.length) {
      queries.add(keyTerms.join(' '));
    }
    
    // Add a "best results" variant
    if (!originalQuery.contains('best') && !originalQuery.contains('top')) {
      queries.add('best $originalQuery');
    }
    
    return queries.take(3).toList();
  }
}

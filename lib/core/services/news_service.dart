import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

class NewsArticle {
  final String title;
  final String? description;
  final String source;
  final String? imageUrl;
  final String url;
  final DateTime publishedAt;
  final String category;

  const NewsArticle({
    required this.title,
    this.description,
    required this.source,
    this.imageUrl,
    required this.url,
    required this.publishedAt,
    required this.category,
  });

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(publishedAt);

    if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class _RSSFeed {
  final String url;
  final String sourceName;
  final String category;

  const _RSSFeed({
    required this.url,
    required this.sourceName,
    required this.category,
  });
}

class NewsService {
  // Free RSS feeds for skin-related news
  static const List<_RSSFeed> _feeds = [
    // Science & Research
    _RSSFeed(
      url: 'https://www.sciencedaily.com/rss/health_medicine/skin_care.xml',
      sourceName: 'Science Daily',
      category: 'Research',
    ),
    _RSSFeed(
      url: 'https://www.sciencedaily.com/rss/health_medicine/cosmetics.xml',
      sourceName: 'Science Daily',
      category: 'Products',
    ),
    // Medical News
    _RSSFeed(
      url: 'https://www.news-medical.net/tag/feed/Dermatology.aspx',
      sourceName: 'News Medical',
      category: 'Health',
    ),
    // Health News
    _RSSFeed(
      url: 'https://www.eurekalert.org/rss/biology.xml',
      sourceName: 'EurekAlert',
      category: 'Research',
    ),
    // WebMD
    _RSSFeed(
      url: 'https://rssfeeds.webmd.com/rss/rss.aspx?RSSSource=RSS_PUBLIC',
      sourceName: 'WebMD',
      category: 'Health',
    ),
  ];

  /// Fetch skin-related news from RSS feeds
  static Future<List<NewsArticle>> getSkinNews({int pageSize = 30}) async {
    final List<NewsArticle> allArticles = [];

    // Fetch from all feeds concurrently
    final futures = _feeds.map((feed) => _fetchFeed(feed));
    final results = await Future.wait(futures);

    for (final articles in results) {
      allArticles.addAll(articles);
    }

    // Sort by date (newest first)
    allArticles.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

    // Filter to skin-related content and limit
    final filtered = allArticles.where((article) {
      final text = '${article.title} ${article.description ?? ''}'.toLowerCase();
      return text.contains('skin') ||
          text.contains('dermat') ||
          text.contains('acne') ||
          text.contains('eczema') ||
          text.contains('wrinkle') ||
          text.contains('moistur') ||
          text.contains('sunscreen') ||
          text.contains('spf') ||
          text.contains('collagen') ||
          text.contains('cosmetic') ||
          text.contains('beauty') ||
          text.contains('skincare') ||
          text.contains('anti-aging') ||
          text.contains('psoriasis') ||
          text.contains('rosacea') ||
          text.contains('melanoma') ||
          text.contains('complexion') ||
          text.contains('pore') ||
          text.contains('serum') ||
          text.contains('retinol') ||
          text.contains('vitamin c') ||
          text.contains('hyaluronic');
    }).take(pageSize).toList();

    // If not enough filtered, return all sorted
    if (filtered.length < 5) {
      return allArticles.take(pageSize).toList();
    }

    return filtered;
  }

  static Future<List<NewsArticle>> _fetchFeed(_RSSFeed feed) async {
    try {
      final response = await http.get(
        Uri.parse(feed.url),
        headers: {
          'User-Agent': 'Mozilla/5.0 (compatible; SkinSync/1.0)',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return _parseRSS(response.body, feed.sourceName, feed.category);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static List<NewsArticle> _parseRSS(String xmlString, String source, String category) {
    try {
      final document = xml.XmlDocument.parse(xmlString);
      final items = document.findAllElements('item');

      return items.map((item) {
        final title = _getElementText(item, 'title');
        final description = _cleanDescription(_getElementText(item, 'description'));
        final link = _getElementText(item, 'link');
        final pubDate = _parseDate(_getElementText(item, 'pubDate'));
        final imageUrl = _extractImageUrl(item);

        // Determine category based on content
        final detectedCategory = _detectCategory(title, description, category);

        return NewsArticle(
          title: title,
          description: description.isEmpty ? null : description,
          source: source,
          imageUrl: imageUrl,
          url: link,
          publishedAt: pubDate,
          category: detectedCategory,
        );
      }).where((article) => article.title.isNotEmpty && article.url.isNotEmpty).toList();
    } catch (e) {
      return [];
    }
  }

  static String _getElementText(xml.XmlElement item, String tagName) {
    try {
      final element = item.findElements(tagName).firstOrNull;
      if (element != null) {
        return element.innerText.trim();
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  static String _cleanDescription(String description) {
    // Remove HTML tags
    String cleaned = description.replaceAll(RegExp(r'<[^>]*>'), '');
    // Decode HTML entities
    cleaned = cleaned
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'");
    // Remove extra whitespace
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
    // Limit length
    if (cleaned.length > 300) {
      cleaned = '${cleaned.substring(0, 297)}...';
    }
    return cleaned;
  }

  static DateTime _parseDate(String dateString) {
    if (dateString.isEmpty) return DateTime.now();

    try {
      // Try RFC 2822 format (common in RSS)
      // Example: "Tue, 21 May 2024 14:30:00 GMT"
      final patterns = [
        RegExp(r'(\d{1,2})\s+(\w{3})\s+(\d{4})\s+(\d{2}):(\d{2}):(\d{2})'),
      ];

      for (final pattern in patterns) {
        final match = pattern.firstMatch(dateString);
        if (match != null) {
          final day = int.parse(match.group(1)!);
          final monthStr = match.group(2)!;
          final year = int.parse(match.group(3)!);
          final hour = int.parse(match.group(4)!);
          final minute = int.parse(match.group(5)!);
          final second = int.parse(match.group(6)!);

          final months = {
            'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
            'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
          };

          final month = months[monthStr] ?? 1;
          return DateTime(year, month, day, hour, minute, second);
        }
      }

      // Try ISO 8601 format
      return DateTime.tryParse(dateString) ?? DateTime.now();
    } catch (e) {
      return DateTime.now();
    }
  }

  static String? _extractImageUrl(xml.XmlElement item) {
    try {
      // Check for media:content
      final mediaContent = item.findElements('media:content').firstOrNull;
      if (mediaContent != null) {
        final url = mediaContent.getAttribute('url');
        if (url != null && url.isNotEmpty) return url;
      }

      // Check for media:thumbnail
      final mediaThumbnail = item.findElements('media:thumbnail').firstOrNull;
      if (mediaThumbnail != null) {
        final url = mediaThumbnail.getAttribute('url');
        if (url != null && url.isNotEmpty) return url;
      }

      // Check for enclosure
      final enclosure = item.findElements('enclosure').firstOrNull;
      if (enclosure != null) {
        final type = enclosure.getAttribute('type') ?? '';
        if (type.startsWith('image/')) {
          final url = enclosure.getAttribute('url');
          if (url != null && url.isNotEmpty) return url;
        }
      }

      // Try to extract from description
      final description = _getElementText(item, 'description');
      final imgMatch = RegExp(r'<img[^>]+src="([^"]+)"').firstMatch(description);
      if (imgMatch != null) {
        return imgMatch.group(1);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  static String _detectCategory(String title, String description, String defaultCategory) {
    final text = '$title $description'.toLowerCase();

    if (text.contains('study') || text.contains('research') ||
        text.contains('scientist') || text.contains('discover') ||
        text.contains('found that') || text.contains('according to')) {
      return 'Research';
    } else if (text.contains('product') || text.contains('brand') ||
               text.contains('launch') || text.contains('cream') ||
               text.contains('serum') || text.contains('moisturizer')) {
      return 'Products';
    } else if (text.contains('cancer') || text.contains('disease') ||
               text.contains('condition') || text.contains('treatment') ||
               text.contains('diagnosis') || text.contains('symptoms')) {
      return 'Health';
    } else if (text.contains('tip') || text.contains('how to') ||
               text.contains('guide') || text.contains('routine') ||
               text.contains('advice') || text.contains('ways to')) {
      return 'Tips';
    } else if (text.contains('trend') || text.contains('celebrity') ||
               text.contains('popular') || text.contains('viral')) {
      return 'Trends';
    }

    return defaultCategory;
  }
}

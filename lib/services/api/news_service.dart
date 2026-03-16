import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

import '../../models/news_item.dart';
import '../storage/local_storage_service.dart';

class NewsService {
  NewsService._();
  static final NewsService instance = NewsService._();

  static const String _defaultRss =
      'https://www.sciencedaily.com/rss/plants_animals.xml';

  Future<List<NewsItem>> fetchPlantNews() async {
    const cacheKey = 'plant_news_feed';
    final cached = LocalStorageService.instance.getCachedApiResponse(cacheKey);
    if (cached != null && cached['items'] is List) {
      return _fromCachedList(cached['items'] as List<dynamic>);
    }

    try {
      final response = await http.get(Uri.parse(_defaultRss));
      if (response.statusCode != 200) return const [];
      final xml = XmlDocument.parse(utf8.decode(response.bodyBytes));
      final items = xml.findAllElements('item').take(10);

      final news = items.map((item) {
        final title = item.getElement('title')?.innerText ?? 'Untitled';
        final description =
            item.getElement('description')?.innerText ?? 'No summary available';
        final link = item.getElement('link')?.innerText ?? '';
        final pubDateRaw = item.getElement('pubDate')?.innerText ?? '';
        return NewsItem(
          title: title,
          summary: description,
          link: link,
          publishedAt: DateTime.tryParse(pubDateRaw),
        );
      }).toList();

      await LocalStorageService.instance.cacheApiResponse(
        key: cacheKey,
        data: {
          'items':
              news
                  .map(
                    (e) => {
                      'title': e.title,
                      'summary': e.summary,
                      'link': e.link,
                      'publishedAt': e.publishedAt?.toIso8601String(),
                    },
                  )
                  .toList(),
        },
        ttl: const Duration(days: 1),
      );
      return news;
    } catch (_) {
      return const [];
    }
  }

  List<NewsItem> _fromCachedList(List<dynamic> rawItems) {
    return rawItems
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .map(
          (json) => NewsItem(
            title: json['title']?.toString() ?? 'Untitled',
            summary: json['summary']?.toString() ?? '',
            link: json['link']?.toString() ?? '',
            publishedAt: DateTime.tryParse(json['publishedAt']?.toString() ?? ''),
          ),
        )
        .toList();
  }
}

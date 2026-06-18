import 'package:http/http.dart' as http;
import '../models/story_model.dart';
import 'rss_parser.dart';

abstract class HomeRemoteDataSource {
  Future<List<StoryModel>> getNewsStories({
    required String category,
    required String countryCode,
    required String languageCode,
  });
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final http.Client client;

  HomeRemoteDataSourceImpl({required this.client});

  @override
  Future<List<StoryModel>> getNewsStories({
    required String category,
    required String countryCode,
    required String languageCode,
  }) async {
    final categories = category.split(',').where((c) => c.trim().isNotEmpty).toList();
    
    if (categories.length > 1) {
      try {
        final futures = categories.map((cat) => _fetchSingleCategory(
          category: cat.trim(),
          countryCode: countryCode,
          languageCode: languageCode,
        ));
        
        final results = await Future.wait(futures);
        
        final Map<int, StoryModel> mergedMap = {};
        for (var list in results) {
          for (var story in list) {
            mergedMap[story.id] = story;
          }
        }
        
        final mergedList = mergedMap.values.toList();
        // Sort descending by publication time
        mergedList.sort((a, b) => b.time.compareTo(a.time));
        return mergedList;
      } catch (e) {
        throw Exception('Failed to fetch multi-category news: $e');
      }
    } else {
      return _fetchSingleCategory(
        category: category,
        countryCode: countryCode,
        languageCode: languageCode,
      );
    }
  }

  Future<List<StoryModel>> _fetchSingleCategory({
    required String category,
    required String countryCode,
    required String languageCode,
  }) async {
    final String url;
    final catUpper = category.toUpperCase();
    
    if (catUpper == 'HEADLINES' || category.trim().isEmpty) {
      url = 'https://news.google.com/rss?hl=$languageCode&gl=$countryCode&ceid=$countryCode:$languageCode';
    } else {
      url = 'https://news.google.com/rss/headlines/section/topic/$catUpper?hl=$languageCode&gl=$countryCode&ceid=$countryCode:$languageCode';
    }

    try {
      final response = await client.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final body = response.body;
        return RssParser.parseGoogleNewsRss(body);
      } else {
        throw Exception('Server Error: Status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch news: $e');
    }
  }

  // Keep for backwards compatibility/DI lookup if any other feature uses it directly
  Future<List<StoryModel>> getTopStories() async {
    return getNewsStories(
      category: 'headlines',
      countryCode: 'US',
      languageCode: 'en',
    );
  }
}

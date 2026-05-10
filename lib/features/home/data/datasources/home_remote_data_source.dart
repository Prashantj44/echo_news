import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/story_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<StoryModel>> getTopStories();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final http.Client client;

  HomeRemoteDataSourceImpl({required this.client});

  @override
  Future<List<StoryModel>> getTopStories() async {
    final response = await client.get(
      Uri.parse('https://hacker-news.firebaseio.com/v0/topstories.json'),
    );

    if (response.statusCode == 200) {
      final List<int> ids = List<int>.from(json.decode(response.body)).take(30).toList();
      
      final storyFutures = ids.map((id) => client.get(
        Uri.parse('https://hacker-news.firebaseio.com/v0/item/$id.json'),
      ));

      final storyResponses = await Future.wait(storyFutures);
      
      final List<StoryModel> stories = [];
      for (var storyResponse in storyResponses) {
        if (storyResponse.statusCode == 200) {
          stories.add(StoryModel.fromJson(json.decode(storyResponse.body)));
        }
      }
      return stories;
    } else {
      throw Exception('Server Error');
    }
  }
}

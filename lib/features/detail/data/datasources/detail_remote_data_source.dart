import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/comment_model.dart';

abstract class DetailRemoteDataSource {
  Future<List<CommentModel>> getComments(List<int> commentIds);
}

class DetailRemoteDataSourceImpl implements DetailRemoteDataSource {
  final http.Client client;

  DetailRemoteDataSourceImpl({required this.client});

  @override
  Future<List<CommentModel>> getComments(List<int> commentIds) async {
    final commentFutures = commentIds.map((id) => client.get(
      Uri.parse('https://hacker-news.firebaseio.com/v0/item/$id.json'),
    ));

    final commentResponses = await Future.wait(commentFutures);
    
    final List<CommentModel> comments = [];
    for (var response in commentResponses) {
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data['type'] == 'comment' && data['deleted'] != true) {
          comments.add(CommentModel.fromJson(data));
        }
      }
    }
    return comments;
  }
}

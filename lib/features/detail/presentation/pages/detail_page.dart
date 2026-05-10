import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../injection_container.dart';
import '../../../home/domain/entities/story.dart';
import '../manager/detail_bloc.dart';
import '../manager/detail_event.dart';
import '../manager/detail_state.dart';
import '../widgets/comment_tile.dart';

class DetailPage extends StatelessWidget {
  final Story story;

  const DetailPage({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DetailBloc>()..add(FetchComments(commentIds: story.kids ?? [])),
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F6EF),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFF6600),
          title: const Text('Story Details', style: TextStyle(color: Colors.black)),
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      story.title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    if (story.url != null) ...[
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => launchUrl(Uri.parse(story.url!)),
                        child: Text(
                          story.url!,
                          style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline, fontSize: 14),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      'by ${story.by} | ${story.score} points',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Divider(thickness: 1),
              BlocBuilder<DetailBloc, DetailState>(
                builder: (context, state) {
                  if (state is DetailLoading) {
                    return const Center(child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(color: Color(0xFFFF6600)),
                    ));
                  } else if (state is DetailLoaded) {
                    if (state.comments.isEmpty) {
                      return const Center(child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text('No comments yet.'),
                      ));
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.comments.length,
                      itemBuilder: (context, index) {
                        return CommentTile(comment: state.comments[index]);
                      },
                    );
                  } else if (state is DetailError) {
                    return Center(child: Text(state.message));
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/service_locator.dart';
import '../cubit/comment_cubit.dart';

@RoutePage()
class CommentsPage extends StatefulWidget {
  const CommentsPage({super.key, required this.videoId});
  final String videoId;
  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final controller = TextEditingController();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => sl<CommentCubit>()..load(widget.videoId),
    child: Scaffold(
      appBar: AppBar(title: const Text('Comments')),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<CommentCubit, CommentState>(
              builder: (context, state) {
                if (state.loading && state.comments.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  itemCount: state.comments.length,
                  itemBuilder: (context, index) => ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(state.comments[index].text),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: 'Add a comment',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      context.read<CommentCubit>().post(
                        widget.videoId,
                        controller.text,
                      );
                      controller.clear();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

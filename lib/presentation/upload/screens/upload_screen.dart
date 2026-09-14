import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/upload_cubit.dart';

@RoutePage()
class UploadPage extends StatefulWidget {
  const UploadPage({super.key});
  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final title = TextEditingController();
  final description = TextEditingController();
  final category = TextEditingController();
  final tags = TextEditingController();
  @override
  void dispose() {
    title.dispose();
    description.dispose();
    category.dispose();
    tags.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Upload video')),
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: BlocConsumer<UploadCubit, UploadState>(
        listener: (context, state) {
          if (state is UploadDone) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Uploaded, processing…')),
            );
            context.router.pop();
          }
        },
        builder: (context, state) {
          final ready = state is UploadReady;
          final uploading = state is Uploading;
          return ListView(
            children: [
              TextField(
                controller: title,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: description,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: category,
                decoration: const InputDecoration(
                  labelText: 'Category (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: tags,
                decoration: const InputDecoration(
                  labelText: 'Tags, comma separated',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: uploading
                    ? null
                    : () => context.read<UploadCubit>().pick(),
                icon: const Icon(Icons.video_library),
                label: Text(
                  ready ? state.file.path.split('/').last : 'Choose video',
                ),
              ),
              if (uploading) ...[
                const SizedBox(height: 20),
                LinearProgressIndicator(value: state.progress),
                const SizedBox(height: 8),
                Text('${(state.progress * 100).round()}%'),
              ],
              if (state is UploadError)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    state.message,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: ready && !uploading
                    ? () => context.read<UploadCubit>().upload(
                        title.text.trim(),
                        description.text.trim(),
                        category: category.text.trim(),
                        tags: tags.text
                            .split(',')
                            .map((tag) => tag.trim())
                            .where((tag) => tag.isNotEmpty)
                            .toList(),
                      )
                    : null,
                child: const Text('Upload'),
              ),
            ],
          );
        },
      ),
    ),
  );
}

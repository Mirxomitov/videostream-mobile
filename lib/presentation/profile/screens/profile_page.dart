import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/service_locator.dart';
import '../../player/screens/player_page.dart';
import '../cubit/profile_cubit.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => sl<ProfileCubit>()..load(),
    child: Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state.loading && state.data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = state.data;
          if (data == null) {
            return Center(child: Text(state.error ?? 'Could not load profile'));
          }
          return ListView(
            children: [
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(
                  data.fullName?.isNotEmpty == true
                      ? data.fullName!
                      : 'Set your name',
                ),
                subtitle: Text(data.phone ?? ''),
                trailing: const Icon(Icons.edit),
                onTap: () => _editName(context, data.fullName ?? ''),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text('Watch history'),
              ),
              if (data.history.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Videos you watch will appear here.'),
                ),
              ...data.history.map(
                (video) => ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(video.title),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => PlayerPage(video: video),
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text('Your videos'),
              ),
              if (data.uploads.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Your ready uploads will appear here.'),
                ),
              ...data.uploads.map(
                (video) => ListTile(
                  leading: const Icon(Icons.video_library_outlined),
                  title: Text(video.title),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => PlayerPage(video: video),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ),
  );

  Future<void> _editName(BuildContext context, String current) async {
    final controller = TextEditingController(text: current);
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Display name'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result != null && context.mounted) {
      await context.read<ProfileCubit>().updateName(result);
    }
  }
}

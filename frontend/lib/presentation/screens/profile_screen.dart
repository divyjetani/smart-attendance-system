import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), automaticallyImplyLeading: false),
      body: user == null
          ? const Center(child: Text('Not logged in'))
          : Center(
              child: Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        child: Text(user.name[0].toUpperCase(), style: const TextStyle(fontSize: 40)),
                      ),
                      const SizedBox(height: 16),
                      Text(user.name, style: Theme.of(context).textTheme.titleLarge),
                      Text(user.email, style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 8),
                      Text('Role: ${user.role.toUpperCase()}', style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
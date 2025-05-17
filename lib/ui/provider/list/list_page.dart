import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'list_model.dart';

class ListPageProvider extends StatefulWidget {
  const ListPageProvider({super.key});

  @override
  State<ListPageProvider> createState() => _ListPageProviderState();
}

class _ListPageProviderState extends State<ListPageProvider> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ListModel>(
      builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Felhasználók'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => _logout(context),
                key: const Key('logoutButton'),
              ),
            ],
          ),
          body: model.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  key: const Key('userListView'),
                  itemCount: model.users.length,
                  itemBuilder: (context, index) {
                    final user = model.users[index];
                    return ListTile(
                      key: Key('userTile_$index'),
                      // Use plain Image.network instead of CircleAvatar for test compatibility
                      leading: ClipOval(
                        child: Image.network(
                          user.avatarUrl,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          // Add a key for easier finding in tests
                          key: Key('userImage_${user.avatarUrl}'),
                        ),
                      ),
                      title: Text(
                        user.name,
                        // Add a key for easier finding in tests
                        key: Key('userName_${user.name}'),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // Avoid creating pending timers in tests
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializePage();
      }
    });
  }

  void _initializePage() async {
    final model = Provider.of<ListModel>(context, listen: false);
    try {
      // Load the data immediately without creating timers
      await model.loadUsers();
    } catch (e) {
      if (mounted) {
        // Extract just the message from the exception for tests to pass
        final errorMessage = e is ListException ? e.message : e.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
  }

  void _logout(BuildContext context) async {
    final prefs = GetIt.I<SharedPreferences>();
    await prefs.remove('token');
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/');
    }
  }
}

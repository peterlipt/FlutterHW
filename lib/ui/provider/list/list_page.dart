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
              ),
            ],
          ),
          body: model.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: model.users.length,
                  itemBuilder: (context, index) {
                    final user = model.users[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(user.avatarUrl),
                      ),
                      title: Text(user.name),
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
    SchedulerBinding.instance.addPostFrameCallback((_) => _initializePage());
  }

  void _initializePage() async {
    final model = Provider.of<ListModel>(context, listen: false);
    try {
      await model.loadUsers();
    } on ListException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
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

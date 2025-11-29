import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/auth_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _loading = true;
  List<dynamic> _notes = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetch());
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final api = auth.authService.api;
      // ADAPT: ensure ApiService has getNotifications()
      final data = await api.getNotifications();
      if (mounted) setState(() => _notes = data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load notifications: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markRead(dynamic note) async {
    final id = note['id'];
    if (id == null) return;
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final api = auth.authService.api;
      // ADAPT: ensure ApiService has markNotificationRead(id)
      await api.markNotificationRead(id);
      await _fetch();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to mark read: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications', style: GoogleFonts.poppins()),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _notes.isEmpty
          ? Center(
              child: Text('No notifications', style: GoogleFonts.poppins()),
            )
          : RefreshIndicator(
              onRefresh: _fetch,
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: _notes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, i) {
                  final n = _notes[i];
                  final title = n['title'] ?? n['message'] ?? 'Notification';
                  final body = n['body'] ?? n['message'] ?? '';
                  final isRead = n['is_read'] == true || n['read'] == true;
                  return Card(
                    color: isRead ? Colors.white : Colors.blue.shade50,
                    child: ListTile(
                      leading: Icon(Icons.notifications),
                      title: Text(
                        title,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(body),
                      trailing: isRead
                          ? null
                          : TextButton(
                              onPressed: () => _markRead(n),
                              child: Text('Mark read'),
                            ),
                      onTap: () {
                        // navigate to detail if exists
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }
}

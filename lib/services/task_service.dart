import 'package:supabase_flutter/supabase_flutter.dart';

class TaskService {
  final client = Supabase.instance.client;

  Future insertTask(String title, DateTime date) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) throw "User tidak login";

    return await client.from('tasks').insert({
      'user_id': userId,
      'title': title,
      'date': date.toIso8601String(),
    });
  }

  Future<List<dynamic>> getTasksByDate(DateTime date) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) throw "User tidak login";

    return await client
        .from('tasks')
        .select()
        .eq('user_id', userId)
        .eq('date', date.toIso8601String())
        .order('created_at');
  }

  Future<List<dynamic>> getUpcomingTasks() async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) throw "User tidak login";

    return await client
        .from('tasks')
        .select()
        .eq('user_id', userId)
        .gt('date', DateTime.now().toIso8601String())
        .order('date');
  }

  Future<List<dynamic>> getCompleted() async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) throw "User tidak login";

    return await client
        .from('tasks')
        .select()
        .eq('user_id', userId)
        .eq('is_completed', true)
        .order('date');
  }

  Future updateCompleted(String id, bool value) async {
    return await client
        .from('tasks')
        .update({'is_completed': value})
        .eq('id', id);
  }

  Future deleteTask(String id) async {
    return await client.from('tasks').delete().eq('id', id);
  }
}

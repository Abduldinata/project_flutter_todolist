import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class TaskService {
  final client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getAllTasks() async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) throw "User tidak login";

    final response = await client
        .from('tasks')
        .select()
        .eq('user_id', userId)
        .order('date', ascending: true)
        .order('created_at', ascending: false);

    return (response as List).cast<Map<String, dynamic>>();
  }

  Future insertTask({
    required String title,
    required DateTime date,
    String? description,
    String? priority,
  }) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) throw "User tidak login";

    final formattedDate =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    final data = {
      'user_id': userId,
      'title': title,
      'date': formattedDate,
      'description': description,
      'priority': priority ?? 'medium',
      'is_done': false,
      'created_at': DateTime.now().toIso8601String(),
    };

    return await client.from('tasks').insert(data);
  }

  Future updateTask({
    required String taskId,
    String? title,
    String? description,
    DateTime? date,
    String? priority,
    bool? isDone,
  }) async {
    final updates = <String, dynamic>{};

    if (title != null) updates['title'] = title;
    if (description != null) updates['description'] = description;
    if (date != null) {
      updates['date'] =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    }
    if (priority != null) updates['priority'] = priority;
    if (isDone != null) updates['is_done'] = isDone;

    updates['updated_at'] = DateTime.now().toIso8601String();

    return await client.from('tasks').update(updates).eq('id', taskId);
  }

  Future<List<Map<String, dynamic>>> getTasksByDate(DateTime date) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) throw "User tidak login";

    final formattedDate =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    final response = await client
        .from('tasks')
        .select()
        .eq('user_id', userId)
        .eq('date', formattedDate)
        .order('created_at');

    return (response as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getUpcomingTasks() async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) throw "User tidak login";

    final today = DateTime.now();
    final formattedToday =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    final response = await client
        .from('tasks')
        .select()
        .eq('user_id', userId)
        .gt('date', formattedToday)
        .order('date');

    return (response as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>?> getTaskById(String taskId) async {
    try {
      final response = await client
          .from('tasks')
          .select()
          .eq('id', taskId)
          .maybeSingle();

      return response; // 👈 cast dihapus
    } catch (e) {
      debugPrint("Error getting task by ID: $e");
      return null;
    }
  }


  Future<List<Map<String, dynamic>>> getCompletedTasks() async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) throw "User tidak login";

    final response = await client
        .from('tasks')
        .select()
        .eq('user_id', userId)
        .eq('is_done', true) // Hanya task yang selesai
        .order('updated_at', ascending: false); // Urutkan dari yang terbaru

    return (response as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getCompleted() async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) throw "User tidak login";

    final response = await client
        .from('tasks')
        .select()
        .eq('user_id', userId)
        .eq('is_done', true)
        .order('updated_at', ascending: false);

    return (response as List).cast<Map<String, dynamic>>();
  }

  Future updateCompleted(String id, bool value) async {
    return await client
        .from('tasks')
        .update({'is_done': value})
        .eq('id', id);
  }

  Future deleteTask(String id) async {
    return await client.from('tasks').delete().eq('id', id);
  }
}

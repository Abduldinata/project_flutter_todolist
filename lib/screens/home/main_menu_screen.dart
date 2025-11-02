import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:get/get.dart';
import '../../controllers/theme_controller.dart';
import '../../services/supabase_service.dart';
import '../../models/task_model.dart';
import '../profile/profile_screen.dart';


class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  final SupabaseService _supabase = SupabaseService();
  List<Task> _tasks = [];
  bool _isLoading = true;
  int _currentIndex = 2; // default tab "Tugas"

  final iconList = <IconData>[
    Icons.inbox, // 0
    Icons.calendar_month, // 1
    Icons.check_box, // 2
    Icons.history, // 3
  ];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    try {
      final data = await _supabase.getTasks();
      setState(() => _tasks = data);
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat tugas: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleTask(Task task) async {
    try {
      await _supabase.updateTaskStatus(task.id, !task.isDone);
      _loadTasks();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> _deleteTask(int id) async {
    try {
      await _supabase.deleteTask(id);
      _loadTasks();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  void _showAddDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Tambah Tugas Baru'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Judul'),
            ),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Deskripsi'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              if (titleCtrl.text.isNotEmpty) {
                await _supabase.addTask(titleCtrl.text, descCtrl.text);
                Get.back();
                _loadTasks();
              } else {
                Get.snackbar('Error', 'Judul tidak boleh kosong');
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final isDark = themeController.isDarkMode.value;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          ['Inbox', 'Kalender', 'Daftar Tugas', 'Riwayat'][_currentIndex],
        ),
        centerTitle: true,
        actions: [
          // 🌙☀️ Tombol tema
          Obx(() {
            final dark = themeController.isDarkMode.value;
            return IconButton(
              icon: Icon(dark ? Icons.wb_sunny : Icons.nights_stay),
              onPressed: () => themeController.toggleTheme(),
            );
          }),

          // 👤 Tombol profil di kanan atas
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profil',
            onPressed: () {
              Get.to(() => const ProfilScreen());
            },
          ),
        ],
      ),

      // 📋 Body sesuai tab
      body: _buildPage(),

      // ➕ FAB hanya di tab "Tugas"
      floatingActionButton: _currentIndex == 2
          ? FloatingActionButton(
              onPressed: _showAddDialog,
              backgroundColor: Colors.indigo,
              child: const Icon(Icons.add),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // 🌈 Bottom Navigation Bar
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: iconList,
        activeIndex: _currentIndex,
        gapLocation: GapLocation.none,
        notchSmoothness: NotchSmoothness.defaultEdge,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        activeColor: Colors.indigo,
        inactiveColor: isDark ? Colors.grey[400]! : Colors.grey[600]!,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }

  Widget _buildPage() {
    switch (_currentIndex) {
      case 0:
        return const Center(child: Text('Inbox Kosong'));
      case 1:
        return const Center(child: Text('Kalender'));
      case 2:
        return _buildTodoList();
      case 3:
        return const Center(child: Text('Riwayat Kosong'));
      default:
        return const SizedBox();
    }
  }

  Widget _buildTodoList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_tasks.isEmpty) {
      return const Center(child: Text('Belum ada tugas.'));
    }

    return ListView.builder(
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        final task = _tasks[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            title: Text(
              task.title,
              style: TextStyle(
                decoration: task.isDone
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
            subtitle: Text(task.description ?? ''),
            leading: Checkbox(
              value: task.isDone,
              onChanged: (_) => _toggleTask(task),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteTask(task.id),
            ),
          ),
        );
      },
    );
  }
}

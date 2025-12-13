import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/theme_tokens.dart';
import '../../services/task_service.dart';
import '../../widgets/task_tile.dart';

class SearchPopup extends StatefulWidget {
  const SearchPopup({super.key});

  @override
  State<SearchPopup> createState() => _SearchPopupState();
}

class _SearchPopupState extends State<SearchPopup> {
  final TextEditingController _searchCtrl = TextEditingController();
  final TaskService _taskService = TaskService();

  List<Map<String, dynamic>> searchResults = [];
  bool searching = false;
  bool hasSearched = false;
  String? _searchQuery;

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        searchResults = [];
        hasSearched = true;
        searching = false;
        _searchQuery = null;
      });
      return;
    }

    setState(() {
      searching = true;
      _searchQuery = query;
    });

    try {
      final allTasks = await _taskService.getAllTasks();

      final searchLower = query.toLowerCase();
      final results = allTasks.where((task) {
        final title = task['title']?.toString().toLowerCase() ?? '';
        final description = task['description']?.toString().toLowerCase() ?? '';
        return title.contains(searchLower) || description.contains(searchLower);
      }).toList();

      setState(() {
        searchResults = results;
        searching = false;
        hasSearched = true;
      });
    } catch (e) {
      debugPrint("Error searching tasks: $e");
      setState(() => searching = false);
      Get.snackbar(
        "Error",
        "Gagal melakukan pencarian: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _toggleTaskCompletion(String taskId, bool currentValue) async {
    try {
      await _taskService.updateCompleted(taskId, !currentValue);
      if (_searchQuery != null) {
        await _performSearch(_searchQuery!);
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Gagal update: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _deleteTask(String taskId, String title) async {
    final confirm = await Get.dialog(
      AlertDialog(
        title: const Text("Hapus Task"),
        content: Text("Yakin hapus '$title'?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _taskService.deleteTask(taskId);
        if (_searchQuery != null) {
          await _performSearch(_searchQuery!);
        }
        Get.snackbar(
          "Success",
          "Task berhasil dihapus",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          "Error",
          "Gagal menghapus: ${e.toString()}",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  void _clearSearch() {
    setState(() {
      _searchCtrl.clear();
      searchResults = [];
      hasSearched = false;
      searching = false;
      _searchQuery = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: (isDark ? NeuDark.concave : Neu.concave).copyWith(
          color: scheme.surface,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Search Tasks",
                        style: AppStyle.title.copyWith(color: scheme.onSurface),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: scheme.onSurface),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Search Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: (isDark ? NeuDark.convex : Neu.convex).copyWith(
                      color: scheme.surface,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            autofocus: true,
                            style: AppStyle.normal.copyWith(
                              color: scheme.onSurface,
                            ),
                            decoration: InputDecoration(
                              hintText: "Cari task...",
                              border: InputBorder.none,
                              hintStyle: AppStyle.smallGray.copyWith(
                                color: scheme.onSurface.withValues(alpha: 0.55),
                              ),
                            ),
                            onChanged: (value) {
                              // supaya tombol clear langsung update
                              setState(() {});

                              // Debounce search
                              Future.delayed(
                                const Duration(milliseconds: 300),
                                () {
                                  if (!mounted) return;
                                  if (_searchCtrl.text == value) {
                                    _performSearch(value);
                                  }
                                },
                              );
                            },
                            onSubmitted: _performSearch,
                          ),
                        ),
                        if (_searchCtrl.text.isNotEmpty)
                          IconButton(
                            onPressed: _clearSearch,
                            icon: Icon(
                              Icons.clear,
                              size: 20,
                              color: scheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        IconButton(
                          onPressed: () => _performSearch(_searchCtrl.text),
                          icon: Icon(
                            Icons.search,
                            size: 20,
                            color: scheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Results Section
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: _buildSearchResults(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (searching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_outlined,
              size: 64,
              color: scheme.onSurface.withValues(alpha: 0.35),
            ),
            const SizedBox(height: 16),
            Text(
              "Cari task kamu",
              style: AppStyle.smallGray.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Ketik di search bar untuk mencari task",
              style: AppStyle.smallGray.copyWith(
                fontSize: 12,
                color: scheme.onSurface.withValues(alpha: 0.55),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (searchResults.isEmpty) {
      final q = _searchCtrl.text;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_outlined,
              size: 64,
              color: scheme.onSurface.withValues(alpha: 0.35),
            ),
            const SizedBox(height: 16),
            Text(
              "Tidak ditemukan",
              style: AppStyle.smallGray.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              q.isNotEmpty
                  ? "Tidak ada task dengan kata kunci '$q'"
                  : "Masukkan kata kunci pencarian",
              style: AppStyle.smallGray.copyWith(
                fontSize: 12,
                color: scheme.onSurface.withValues(alpha: 0.55),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final task = searchResults[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TaskTile(
            task: task,
            onToggleCompletion: _toggleTaskCompletion,
            onDelete: _deleteTask,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }
}

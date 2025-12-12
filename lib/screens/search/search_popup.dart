import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/task_service.dart';
import '../../widgets/task_tile.dart';
import '../../utils/neumorphic_decoration.dart';

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
      Theme(
        data: Get.theme,
        child: AlertDialog(
          title: Text("Hapus Task", style: Get.textTheme.titleMedium),
          content: Text("Yakin hapus '$title'?", style: Get.textTheme.bodyMedium),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text("Batal", style: Get.textTheme.bodyMedium),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Get.theme.colorScheme.error,
              ),
              child: Text(
                "Hapus", 
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: Get.theme.colorScheme.onError,
                ),
              ),
            ),
          ],
        ),
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
    final textTheme = theme.textTheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.75,
        margin: const EdgeInsets.all(20),
        decoration: Neu.concave(context).copyWith(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header dengan search bar
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  // Title dan Close Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Cari Tugas",
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.onSurface,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: Neu.convex(context),
                          child: Icon(
                            Icons.close,
                            size: 20,
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Search Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: Neu.convex(context).copyWith(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: scheme.onSurface.withOpacity(0.6),
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            autofocus: true,
                            style: textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurface,
                            ),
                            decoration: InputDecoration(
                              hintText: "Cari judul atau deskripsi...",
                              border: InputBorder.none,
                              hintStyle: textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurface.withOpacity(0.5),
                              ),
                            ),
                            onChanged: (value) {
                              // Update UI untuk clear button
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
                          GestureDetector(
                            onTap: _clearSearch,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: scheme.onSurface.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.clear,
                                size: 18,
                                color: scheme.onSurface.withOpacity(0.6),
                              ),
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
                color: scheme.surface,
                child: _buildSearchResults(context),
              ),
            ),
            
            // Footer dengan info
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total ditemukan: ${searchResults.length}",
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  if (hasSearched && searchResults.isNotEmpty)
                    Text(
                      "Tekan Enter untuk mencari lagi",
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    if (searching) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: scheme.primary),
            const SizedBox(height: 16),
            Text(
              "Mencari...",
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    if (!hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_rounded,
              size: 72,
              color: scheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              "Cari tugas kamu",
              style: textTheme.titleMedium?.copyWith(
                color: scheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "Ketik di atas untuk mencari tugas berdasarkan judul atau deskripsi",
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurface.withOpacity(0.5),
                ),
              ),
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
              Icons.search_off_rounded,
              size: 72,
              color: scheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              "Tidak ditemukan",
              style: textTheme.titleMedium?.copyWith(
                color: scheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                q.isNotEmpty
                    ? "Tidak ada tugas yang cocok dengan '$q'"
                    : "Masukkan kata kunci pencarian",
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurface.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 12),
      physics: const BouncingScrollPhysics(),
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final task = searchResults[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/theme_tokens.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/task_tile.dart';
import '../../services/task_service.dart';
import '../../utils/app_routes.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final TaskService _taskService = TaskService();

  List<Map<String, dynamic>> filteredTasks = [];
  bool loading = true;
  int navIndex = 3;

  // Filter state
  bool filterByPriority = false;
  String selectedPriority = 'medium'; // high, medium, low
  bool filterByStatus = false;
  bool showCompleted = false;
  bool filterByDate = false;
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  Future<void> loadFilteredTasks() async {
    setState(() => loading = true);
    try {
      final allTasks = await _taskService.getAllTasks();

      // Apply filters
      List<Map<String, dynamic>> result = allTasks;

      // Filter by priority
      if (filterByPriority) {
        result = result.where((task) {
          final taskPriority =
              task['priority']?.toString().toLowerCase() ?? 'medium';
          return taskPriority == selectedPriority.toLowerCase();
        }).toList();
      }

      // Filter by status
      if (filterByStatus) {
        result = result.where((task) {
          final isDone = task['is_done'] ?? false;
          return showCompleted ? isDone : !isDone;
        }).toList();
      }

      // Filter by date range
      if (filterByDate && selectedStartDate != null) {
        result = result.where((task) {
          final taskDateStr = task['date']?.toString();
          if (taskDateStr == null) return false;

          try {
            final taskDate = DateTime.parse("${taskDateStr}T00:00:00Z");

            if (selectedEndDate != null) {
              // Date range filter
              return taskDate.isAfter(
                    selectedStartDate!.subtract(const Duration(days: 1)),
                  ) &&
                  taskDate.isBefore(
                    selectedEndDate!.add(const Duration(days: 1)),
                  );
            } else {
              // Single date filter
              return taskDate.year == selectedStartDate!.year &&
                  taskDate.month == selectedStartDate!.month &&
                  taskDate.day == selectedStartDate!.day;
            }
          } catch (e) {
            return false;
          }
        }).toList();
      }

      setState(() => filteredTasks = result);
    } catch (e) {
      debugPrint("Error loading filtered tasks: $e");
      Get.snackbar(
        "Error",
        "Gagal memuat tasks: ${e.toString()}",
        backgroundColor: Colors.red.withAlpha((0.9 * 255).round()),
        colorText: Colors.white,
      );
    }
    setState(() => loading = false);
  }

  Future<void> _toggleTaskCompletion(String taskId, bool currentValue) async {
    try {
      await _taskService.updateCompleted(taskId, !currentValue);
      await loadFilteredTasks();
    } catch (e, st) {
      debugPrint("Error update task: $e\n$st");
      Get.snackbar(
        "Error",
        "Terjadi kesalahan saat mengupdate task",
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
        await loadFilteredTasks();
        Get.snackbar("Success", "Task berhasil dihapus");
      } catch (e) {
        Get.snackbar("Error", "Gagal menghapus: $e");
      }
    }
  }

  void _resetFilters() {
    setState(() {
      filterByPriority = false;
      selectedPriority = 'medium';
      filterByStatus = false;
      showCompleted = false;
      filterByDate = false;
      selectedStartDate = null;
      selectedEndDate = null;
    });
    loadFilteredTasks();
  }

  void _applyFilters() {
    loadFilteredTasks();
  }

  @override
  void initState() {
    super.initState();
    loadFilteredTasks();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Filter Tasks",
                    style: AppStyle.title.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Row(
                    children: [
                      if (_hasActiveFilters())
                        GestureDetector(
                          onTap: _resetFilters,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: AppColors.blue.withAlpha(
                                (0.1 * 255).round(),
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "Reset All",
                              style: AppStyle.smallGray.copyWith(
                                color: AppColors.blue,
                              ),
                            ),
                          ),
                        ),
                      GestureDetector(
                        onTap: () {
                          debugPrint("Navigating to settings...");
                          Get.toNamed(AppRoutes.settings)?.catchError((error) {
                            debugPrint("Navigation error: $error");
                            Get.snackbar(
                              "Error",
                              "Gagal membuka pengaturan",
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                          });
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 40,
                          height: 40,
                          padding: const EdgeInsets.all(8),
                          decoration: (isDark ? NeuDark.convex : Neu.convex),
                          child: Icon(
                            Icons.settings,
                            color: theme.colorScheme.onSurface,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Filter Options Card
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // Priority Filter Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: (isDark ? NeuDark.concave : Neu.concave)
                            .copyWith(color: theme.colorScheme.surface),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Filter by Priority",
                                  style: AppStyle.subtitle.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface, // ikut dark/light
                                  ),
                                ),
                                Switch(
                                  value: filterByPriority,
                                  onChanged: (value) {
                                    setState(() => filterByPriority = value);
                                    _applyFilters();
                                  },
                                  activeThumbColor: AppColors.blue,
                                  activeTrackColor: AppColors.blue.withValues(
                                    alpha: 0.3,
                                  ),
                                  inactiveThumbColor: isDark
                                      ? Colors.grey[300]
                                      : Colors.grey[400],
                                  inactiveTrackColor: isDark
                                      ? Colors.grey[800]!.withValues(alpha: 0.5)
                                      : Colors.grey[300]!.withValues(
                                          alpha: 0.5,
                                        ),
                                  trackOutlineColor:
                                      WidgetStateProperty.resolveWith(
                                        (states) =>
                                            states.contains(
                                              WidgetState.selected,
                                            )
                                            ? AppColors.blue
                                            : (isDark
                                                  ? Colors.grey[700]
                                                  : Colors.grey[400]),
                                      ),
                                ),
                              ],
                            ),
                            if (filterByPriority) ...[
                              const SizedBox(height: 12),
                              _buildPriorityOptions(),
                            ],
                          ],
                        ),
                      ),

                      // Status Filter Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: (isDark ? NeuDark.concave : Neu.concave)
                            .copyWith(color: theme.colorScheme.surface),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Filter by Status",
                                  style: AppStyle.subtitle.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface, // ikut dark/light
                                  ),
                                ),
                                Switch(
                                  value: filterByStatus,
                                  onChanged: (value) {
                                    setState(() => filterByStatus = value);
                                    _applyFilters();
                                  },
                                  activeThumbColor: AppColors.blue,
                                  activeTrackColor: AppColors.blue.withValues(
                                    alpha: 0.3,
                                  ),
                                  inactiveThumbColor: isDark
                                      ? Colors.grey[300]
                                      : Colors.grey[400],
                                  inactiveTrackColor: isDark
                                      ? Colors.grey[800]!.withValues(alpha: 0.5)
                                      : Colors.grey[300]!.withValues(
                                          alpha: 0.5,
                                        ),
                                  trackOutlineColor:
                                      WidgetStateProperty.resolveWith(
                                        (states) =>
                                            states.contains(
                                              WidgetState.selected,
                                            )
                                            ? AppColors.blue
                                            : (isDark
                                                  ? Colors.grey[700]
                                                  : Colors.grey[400]),
                                      ),
                                ),
                              ],
                            ),
                            if (filterByStatus) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  _buildStatusOption("Belum Selesai", false),
                                  const SizedBox(width: 12),
                                  _buildStatusOption("Selesai", true),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Date Filter Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: (isDark ? NeuDark.concave : Neu.concave)
                            .copyWith(color: theme.colorScheme.surface),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Filter by Date",
                                  style: AppStyle.subtitle.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface, // ikut dark/light
                                  ),
                                ),
                                Switch(
                                  value: filterByDate,
                                  onChanged: (value) {
                                    setState(() => filterByDate = value);
                                    _applyFilters();
                                  },
                                  activeThumbColor: AppColors.blue,
                                  activeTrackColor: AppColors.blue.withValues(
                                    alpha: 0.3,
                                  ),
                                  inactiveThumbColor: isDark
                                      ? Colors.grey[300]
                                      : Colors.grey[400],
                                  inactiveTrackColor: isDark
                                      ? Colors.grey[800]!.withValues(alpha: 0.5)
                                      : Colors.grey[300]!.withValues(
                                          alpha: 0.5,
                                        ),
                                  trackOutlineColor:
                                      WidgetStateProperty.resolveWith(
                                        (states) =>
                                            states.contains(
                                              WidgetState.selected,
                                            )
                                            ? AppColors.blue
                                            : (isDark
                                                  ? Colors.grey[700]
                                                  : Colors.grey[400]),
                                      ),
                                ),
                              ],
                            ),
                            if (filterByDate) ...[
                              const SizedBox(height: 12),
                              _buildDateFilters(),
                            ],
                          ],
                        ),
                      ),

                      // Results Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: (isDark ? NeuDark.concave : Neu.concave)
                            .copyWith(color: theme.colorScheme.surface),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Results",
                                  style: AppStyle.subtitle.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface, // ikut dark/light
                                  ),
                                ),
                                Text(
                                  "${filteredTasks.length} task${filteredTasks.length != 1 ? 's' : ''}",
                                  style: AppStyle.smallGray.copyWith(
                                    color: AppColors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (!loading && filteredTasks.isEmpty)
                              Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.filter_alt_outlined,
                                      size: 48,
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.5),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      "No tasks match your filters",
                                      style: AppStyle.smallGray,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Try adjusting your filter criteria",
                                      style: AppStyle.smallGray.copyWith(
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else if (loading)
                              const Center(child: CircularProgressIndicator())
                            else
                              ...filteredTasks.map(
                                (task) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: TaskTile(
                                    task: task,
                                    onToggleCompletion: _toggleTaskCompletion,
                                    onDelete: _deleteTask,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNav(
        index: navIndex,
        onTap: (i) {
          if (i == navIndex) return;
          setState(() => navIndex = i);
          if (i == 0) Get.offAllNamed("/inbox");
          if (i == 1) Get.offAllNamed("/today");
          if (i == 2) Get.offAllNamed("/upcoming");
        },
      ),
    );
  }

  Widget _buildPriorityOptions() {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final priorities = [
      {'value': 'high', 'label': 'Tinggi'},
      {'value': 'medium', 'label': 'Sedang'},
      {'value': 'low', 'label': 'Rendah'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: priorities.map((p) {
        final value = p['value']!;
        final label = p['label']!;
        final isSelected = selectedPriority == value;

        final bgColor = isSelected ? scheme.primary : scheme.surface;

        final textColor = isSelected
            ? scheme.onPrimary
            : scheme.onSurface.withAlpha((0.8 * 255).round());

        return GestureDetector(
          onTap: () {
            setState(() => selectedPriority = value);
            _applyFilters();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration:
                (isSelected
                        ? (isDark ? NeuDark.pressed : Neu.pressed)
                        : (isDark ? NeuDark.convex : Neu.convex))
                    .copyWith(color: bgColor),
            child: Text(
              label,
              style: AppStyle.normal.copyWith(
                color: textColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatusOption(String label, bool isCompleted) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = showCompleted == isCompleted;

    // 🔥 Warna chip dipilih & tidak dipilih dari theme
    final Color bgColor = isSelected
        ? scheme
              .primary // dipilih → biru/light theme atau biru/dark theme
        : scheme.surface; // tidak dipilih → putih/light atau abu gelap/dark

    final Color textColor = isSelected
        ? scheme
              .onPrimary // teks putih saat dipilih
        : scheme.onSurface; // teks normal saat tidak dipilih

    return GestureDetector(
      onTap: () {
        setState(() => showCompleted = isCompleted);
        _applyFilters();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration:
            (isSelected
                    ? (isDark ? NeuDark.pressed : Neu.pressed)
                    : (isDark ? NeuDark.convex : Neu.convex))
                .copyWith(color: bgColor),
        child: Text(
          label,
          style: AppStyle.normal.copyWith(
            color: textColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildDateFilters() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor = theme.colorScheme.onSurface; // aman untuk dark/light
    final hintColor = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final iconHintColor = theme.colorScheme.onSurface.withValues(alpha: 0.5);

    return Column(
      children: [
        // Start Date
        GestureDetector(
          onTap: () async {
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedStartDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              builder: (context, child) {
                // biar dialog date picker juga enak di dark mode
                return Theme(
                  data: theme.copyWith(
                    colorScheme: isDark
                        ? theme.colorScheme.copyWith(
                            surface: theme.colorScheme.surface,
                            onSurface: Colors.white,
                          )
                        : theme.colorScheme,
                  ),
                  child: child!,
                );
              },
            );

            if (picked != null) {
              setState(() => selectedStartDate = picked);
              _applyFilters();
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: (isDark ? NeuDark.convex : Neu.convex).copyWith(
              color: theme.colorScheme.surface,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedStartDate == null
                      ? "Pilih Tanggal Awal"
                      : "Dari: ${_formatDate(selectedStartDate!)}",
                  style: AppStyle.normal.copyWith(
                    color: selectedStartDate == null ? hintColor : textColor,
                  ),
                ),
                Icon(
                  Icons.calendar_today_outlined,
                  color: selectedStartDate == null
                      ? iconHintColor
                      : theme.colorScheme.onSurface,
                ),
              ],
            ),
          ),
        ),

        // End Date (Optional)
        GestureDetector(
          onTap: () async {
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate:
                  selectedEndDate ?? (selectedStartDate ?? DateTime.now()),
              firstDate: selectedStartDate ?? DateTime(2000),
              lastDate: DateTime(2100),
              builder: (context, child) {
                return Theme(
                  data: theme.copyWith(
                    colorScheme: isDark
                        ? theme.colorScheme.copyWith(
                            surface: theme.colorScheme.surface,
                            onSurface: Colors.white,
                          )
                        : theme.colorScheme,
                  ),
                  child: child!,
                );
              },
            );

            if (picked != null) {
              setState(() => selectedEndDate = picked);
              _applyFilters();
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: (isDark ? NeuDark.convex : Neu.convex).copyWith(
              color: theme.colorScheme.surface,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedEndDate == null
                      ? "Pilih Tanggal Akhir (Opsional)"
                      : "Sampai: ${_formatDate(selectedEndDate!)}",
                  style: AppStyle.normal.copyWith(
                    color: selectedEndDate == null ? hintColor : textColor,
                  ),
                ),
                Icon(
                  Icons.calendar_today_outlined,
                  color: selectedEndDate == null
                      ? iconHintColor
                      : theme.colorScheme.onSurface,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  bool _hasActiveFilters() {
    return filterByPriority || filterByStatus || filterByDate;
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}

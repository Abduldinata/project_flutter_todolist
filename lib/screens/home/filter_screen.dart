import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/theme_tokens.dart';
import '../../utils/neumorphic_decoration.dart';
import '../../theme/theme_controller.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/task_tile.dart';
import '../../services/task_service.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final TaskService _taskService = TaskService();
  final ThemeController _themeController = Get.find<ThemeController>();

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
    } catch (e) {
      Get.snackbar("Error", "Gagal update: $e");
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
                  if (_hasActiveFilters())
                    GestureDetector(
                      onTap: _resetFilters,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.blue.withAlpha((0.1 * 255).round()),
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
                ],
              ),

              const SizedBox(height: 20),

              // Filter Options Card
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // Theme Toggle Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: Neu.concave.copyWith(
                          color: theme.colorScheme.surface,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Obx(
                                  () => Icon(
                                    _themeController.isDarkMode.value
                                        ? Icons.dark_mode
                                        : Icons.light_mode,
                                    color: AppColors.blue,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "Dark Mode",
                                  style: AppStyle.subtitle.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface, // mengikuti mode
                                  ),
                                ),
                              ],
                            ),
                            Obx(
                              () => Switch(
                                value: _themeController.isDarkMode.value,
                                onChanged: (value) {
                                  _themeController.toggleTheme();
                                },
                                activeThumbColor: AppColors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Priority Filter Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: Neu.concave.copyWith(
                          color: theme.colorScheme.surface,
                        ),
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
                                    if (value) _applyFilters();
                                  },
                                  activeThumbColor: AppColors.blue,
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
                        decoration: Neu.concave.copyWith(
                          color: theme.colorScheme.surface,
                        ),
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
                                    if (value) _applyFilters();
                                  },
                                  activeThumbColor: AppColors.blue,
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
                        decoration: Neu.concave.copyWith(
                          color: theme.colorScheme.surface,
                        ),
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
                                    if (value) _applyFilters();
                                  },
                                  activeThumbColor: AppColors.blue,
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
                        decoration: Neu.concave.copyWith(
                          color: theme.colorScheme.surface,
                        ),
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
                                      color: Colors.grey[400],
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
    final theme = Theme.of(context);
    final List<Map<String, String>> priorities = [
      {'value': 'high', 'label': 'Tinggi'},
      {'value': 'medium', 'label': 'Sedang'},
      {'value': 'low', 'label': 'Rendah'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: priorities.map((priority) {
        final String value = priority['value']!;
        final String label = priority['label']!;
        final bool isSelected = selectedPriority == value;

        // Warna dark mode → abu-abu
        final Color darkUnselected = const Color(0xFF2C2C2C); // abu-abu gelap
        final Color darkSelected = const Color(
          0xFF505050,
        ); // abu-abu lebih terang

        // Warna light mode → seperti biasa
        final Color lightUnselected = Colors.white;
        final Color lightSelected = const Color.fromARGB(255, 138, 138, 138);

        final bool isDark = theme.brightness == Brightness.dark;

        final Color bgColor = isDark
            ? (isSelected ? darkSelected : darkUnselected)
            : (isSelected ? lightSelected : lightUnselected);

        final Color textColor = isDark ? Colors.white : Colors.black87;

        return GestureDetector(
          onTap: () {
            setState(() => selectedPriority = value);
            _applyFilters();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: (isSelected ? Neu.pressed : Neu.convex).copyWith(
              color: bgColor,
            ),
            child: Text(
              label,
              style: AppStyle.normal.copyWith(color: textColor),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatusOption(String label, bool isCompleted) {
    final theme = Theme.of(context);
    final isSelected = showCompleted == isCompleted;
    return GestureDetector(
      onTap: () {
        setState(() => showCompleted = isCompleted);
        _applyFilters();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: isSelected
            ? Neu.pressed.copyWith(
                color: isCompleted
                    ? Colors.green.withAlpha((0.8 * 255).round())
                    : Colors.orange.withAlpha((0.8 * 255).round()),
              )
            : Neu.convex,
        child: Text(
          label,
          style: AppStyle.normal.copyWith(
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildDateFilters() {
    final theme = Theme.of(context);
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
            decoration: Neu.convex.copyWith(color: theme.colorScheme.surface),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedStartDate == null
                      ? "Pilih Tanggal Awal"
                      : "Dari: ${_formatDate(selectedStartDate!)}",
                  style: AppStyle.normal,
                ),
                Icon(
                  Icons.calendar_today_outlined,
                  color: selectedStartDate == null
                      ? theme.disabledColor
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
            );
            if (picked != null) {
              setState(() => selectedEndDate = picked);
              _applyFilters();
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: Neu.convex.copyWith(color: theme.colorScheme.surface),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedEndDate == null
                      ? "Pilih Tanggal Akhir (Opsional)"
                      : "Sampai: ${_formatDate(selectedEndDate!)}",
                  style: AppStyle.normal,
                ),
                Icon(
                  Icons.calendar_today_outlined,
                  color: selectedEndDate == null
                      ? theme.disabledColor
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

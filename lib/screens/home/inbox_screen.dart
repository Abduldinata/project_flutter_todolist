import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/theme_tokens.dart';
import '../../widgets/add_task_button.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/loading_widget.dart';
import '../../services/task_service.dart';
import '../add_task/add_task_popup.dart';
import '../task_detail/task_detail_screen.dart';
import '../home/filter_screen.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final TaskService _taskService = TaskService();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> allTasks = [];
  bool loading = true;
  int navIndex = 0;
  String selectedFilter = 'All';
  String searchQuery = '';

  // Filter berdasarkan priority yang ada di backend
  final List<String> filters = ['All', 'High', 'Medium', 'Low'];

  // Filter criteria dari filter screen
  Map<String, dynamic>? filterCriteria;

  @override
  void initState() {
    super.initState();
    loadTasks();
    _searchController.addListener(() {
      setState(() {
        searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadTasks() async {
    setState(() => loading = true);
    try {
      final fetchedTasks = await _taskService.getAllTasks();
      setState(() => allTasks = fetchedTasks);
    } catch (e) {
      debugPrint("Error loading inbox tasks: $e");
      Get.snackbar(
        "Error",
        "Failed to load tasks: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _toggleTaskCompletion(String taskId, bool currentValue) async {
    try {
      await _taskService.updateCompleted(taskId, !currentValue);
      await loadTasks();
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to update: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  DateTime? _parseDate(dynamic dateValue) {
    if (dateValue == null) return null;
    try {
      final dateStr = dateValue.toString().split('T')[0];
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      }
    } catch (e) {
      debugPrint("Error parsing date: $e");
    }
    return null;
  }

  bool _isTodayTask(Map<String, dynamic> task) {
    final taskDate = _parseDate(task['date']);
    if (taskDate == null) return false;

    final now = DateTime.now();
    return taskDate.year == now.year &&
        taskDate.month == now.month &&
        taskDate.day == now.day;
  }

  bool _isNextWeekTask(Map<String, dynamic> task) {
    final taskDate = _parseDate(task['date']);
    if (taskDate == null) return false;

    final now = DateTime.now();
    final nextWeekStart = now.add(Duration(days: 7 - now.weekday));
    return taskDate.isAfter(nextWeekStart.subtract(const Duration(days: 1)));
  }

  String _getCategoryFromPriority(String? priority) {
    if (priority == null) return 'Medium';
    final p = priority.toLowerCase();

    // Return priority directly (High, Medium, Low)
    if (p == 'high' || p == 'urgent') {
      return 'High';
    } else if (p == 'medium') {
      return 'Medium';
    } else if (p == 'low') {
      return 'Low';
    }
    return 'Medium';
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'high':
      case 'urgent':
        return Colors.red;
      case 'medium':
        return AppColors.blue;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  List<Map<String, dynamic>> _getFilteredTasks() {
    // Start with all tasks
    List<Map<String, dynamic>> result = List.from(allTasks);

    // Apply search filter FIRST if search query exists
    // This ensures search works on all tasks before other filters
    if (searchQuery.isNotEmpty && searchQuery.trim().isNotEmpty) {
      final query = searchQuery.toLowerCase().trim();
      result = result.where((task) {
        final title = (task['title']?.toString() ?? '').toLowerCase();
        final description = (task['description']?.toString() ?? '')
            .toLowerCase();
        final priority = (task['priority']?.toString() ?? '').toLowerCase();

        // Search in title, description, and priority
        final matches =
            title.contains(query) ||
            description.contains(query) ||
            priority.contains(query);

        // Debug print untuk membantu troubleshooting
        if (kDebugMode && matches) {
          debugPrint('Search match found: ${task['title']}');
        }

        return matches;
      }).toList();
    }

    // Apply filter criteria from filter screen if available
    if (filterCriteria != null) {
      // Filter by priority
      if (filterCriteria!['filterByPriority'] == true) {
        final selectedPriority =
            filterCriteria!['selectedPriority']?.toString().toLowerCase() ??
            'medium';
        result = result.where((task) {
          final taskPriority =
              task['priority']?.toString().toLowerCase() ?? 'medium';
          return taskPriority == selectedPriority;
        }).toList();
      }

      // Filter by status
      if (filterCriteria!['filterByStatus'] == true) {
        final showCompleted = filterCriteria!['showCompleted'] == true;
        result = result.where((task) {
          final isDone = task['is_done'] ?? false;
          return showCompleted ? isDone : !isDone;
        }).toList();
      }

      // Filter by date range
      if (filterCriteria!['filterByDate'] == true &&
          filterCriteria!['selectedStartDate'] != null) {
        try {
          final startDate = DateTime.parse(
            filterCriteria!['selectedStartDate'],
          );
          final endDateStr = filterCriteria!['selectedEndDate'];

          result = result.where((task) {
            final taskDateStr = task['date']?.toString();
            if (taskDateStr == null) return false;

            try {
              final taskDate = DateTime.parse("${taskDateStr}T00:00:00Z");

              if (endDateStr != null) {
                // Date range filter
                final endDate = DateTime.parse(endDateStr);
                return taskDate.isAfter(
                      startDate.subtract(const Duration(days: 1)),
                    ) &&
                    taskDate.isBefore(endDate.add(const Duration(days: 1)));
              } else {
                // Single date filter
                return taskDate.year == startDate.year &&
                    taskDate.month == startDate.month &&
                    taskDate.day == startDate.day;
              }
            } catch (e) {
              return false;
            }
          }).toList();
        } catch (e) {
          debugPrint("Error parsing filter dates: $e");
        }
      }
    } else {
      // Apply simple priority filter from horizontal buttons
      // Only filter incomplete tasks if search is not active
      // If search is active, show all matching tasks (including completed)
      if (searchQuery.isEmpty) {
        final incompleteTasks = result
            .where((task) => (task['is_done'] ?? false) == false)
            .toList();

        if (selectedFilter == 'All') {
          return incompleteTasks;
        }

        return incompleteTasks.where((task) {
          final priority = task['priority']?.toString() ?? 'medium';
          return priority.toLowerCase() == selectedFilter.toLowerCase();
        }).toList();
      } else {
        // If search is active, apply priority filter on search results
        if (selectedFilter == 'All') {
          return result;
        }

        return result.where((task) {
          final priority = task['priority']?.toString() ?? 'medium';
          return priority.toLowerCase() == selectedFilter.toLowerCase();
        }).toList();
      }
    }

    return result;
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  int _getRemainingTasksCount() {
    return allTasks.where((task) => (task['is_done'] ?? false) == false).length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final filteredTasks = _getFilteredTasks();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Inbox',
                              style: AppStyle.title.copyWith(
                                color: isDark ? Colors.white : AppColors.text,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_getFormattedDate()} • ${_getRemainingTasksCount()} tasks remaining',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          final result = await Get.to(
                            () => const FilterScreen(),
                          );
                          if (result != null &&
                              result is Map<String, dynamic>) {
                            setState(() {
                              filterCriteria = result;
                              // Reset simple filter when using advanced filter
                              selectedFilter = 'All';
                            });
                          }
                        },
                        icon: Icon(
                          Icons.tune,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: (isDark ? NeuDark.convex : Neu.convex).copyWith(
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.text,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search tasks...',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.grey[500] : Colors.grey[400],
                      fontSize: 16,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      size: 20,
                    ),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                            },
                            icon: Icon(
                              Icons.clear,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                              size: 20,
                            ),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Filter Buttons
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: filters.length,
                itemBuilder: (context, index) {
                  final filter = filters[index];
                  final isSelected = selectedFilter == filter;

                  return GestureDetector(
                    onTap: () {
                      setState(() => selectedFilter = filter);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.blue
                            : (isDark ? AppColors.darkCard : Colors.grey[200]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          filter,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                      ? Colors.grey[300]
                                      : Colors.grey[700]),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Task List
            Expanded(
              child: loading
                  ? TaskCardLoading(isDark: isDark)
                  : filteredTasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            searchQuery.isNotEmpty
                                ? Icons.search_off
                                : Icons.inbox_outlined,
                            size: 64,
                            color: isDark ? Colors.grey[600] : Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            searchQuery.isNotEmpty
                                ? 'No tasks found for "$searchQuery"'
                                : 'No tasks',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      physics: const BouncingScrollPhysics(),
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = filteredTasks[index];
                        return _buildInboxTaskCard(task, isDark);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: AddTaskButton(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (ctx) => const AddTaskPopup()),
          );

          if (result != null &&
              result['text'] != null &&
              result['date'] != null) {
            try {
              await _taskService.insertTask(
                title: result['text'].toString(),
                date: result['date'] as DateTime,
                description: result['description']?.toString(),
                priority: result['priority']?.toString(),
              );
              await loadTasks();
              Get.snackbar(
                "Success",
                "Task added successfully",
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            } catch (e) {
              Get.snackbar(
                "Error",
                "Failed to add task: ${e.toString()}",
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            }
          }
        },
      ),
      bottomNavigationBar: BottomNav(
        index: navIndex,
        onTap: (i) {
          if (i == navIndex) return;
          setState(() => navIndex = i);
          if (i == 1) Get.offAllNamed("/today");
          if (i == 2) Get.offAllNamed("/upcoming");
          if (i == 3) Get.offAllNamed("/settings");
        },
      ),
    );
  }

  Widget _buildInboxTaskCard(Map<String, dynamic> task, bool isDark) {
    final taskId = task['id']?.toString() ?? '';
    final title = task['title']?.toString() ?? 'No Title';
    final isDone = task['is_done'] ?? false;
    final priority = task['priority']?.toString() ?? 'medium';
    final category = _getCategoryFromPriority(priority);
    final isToday = _isTodayTask(task);
    final isNextWeek = _isNextWeekTask(task);
    final isHighPriority =
        priority.toLowerCase() == 'high' || priority.toLowerCase() == 'urgent';

    final categoryColor = _getCategoryColor(category);

    return GestureDetector(
      onTap: () {
        Get.to(() => TaskDetailScreen(task: task));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: isDark ? NeuDark.concave : Neu.concave,
        child: Row(
          children: [
            // Checkbox
            GestureDetector(
              onTap: () {
                if (taskId.isNotEmpty) {
                  _toggleTaskCompletion(taskId, isDone);
                }
              },
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isDone ? AppColors.blue : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDone
                        ? AppColors.blue
                        : (isDark ? Colors.grey[600]! : Colors.grey[400]!),
                    width: 2,
                  ),
                ),
                child: isDone
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            // Task Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDone
                          ? (isDark ? Colors.grey[600] : Colors.grey[400])
                          : (isDark ? Colors.white : AppColors.text),
                      decoration: isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Category Tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: categoryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Date/Status Info
                      if (isToday)
                        Text(
                          'Due Today',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        )
                      else if (isNextWeek)
                        Text(
                          'Next Week',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      if (isHighPriority && !isToday && !isNextWeek)
                        Row(
                          children: [
                            const SizedBox(width: 8),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'High Priority',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
            // Flag/Icon
            Icon(
              isHighPriority ? Icons.flag : Icons.flag_outlined,
              color: isHighPriority
                  ? Colors.orange
                  : (isDark ? Colors.grey[600] : Colors.grey[400]),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

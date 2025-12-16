import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/theme_tokens.dart';
import '../../widgets/add_task_button.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/loading_widget.dart';
import '../../controllers/task_controller.dart';
import '../add_task/add_task_popup.dart';
import '../task_detail/task_detail_screen.dart';
import '../../services/sound_service.dart';
import '../../utils/app_routes.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final TaskController _taskController = Get.find<TaskController>();
  final TextEditingController _searchController = TextEditingController();
  int navIndex = 0;
  String selectedStatusFilter = 'All'; // All atau History
  String selectedPriorityFilter = 'All'; // All, High, Medium, Low
  String searchQuery = '';

  final List<String> filters = ['All', 'High', 'Medium', 'Low', 'History'];
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  bool isDateFilterActive = false;

  @override
  void initState() {
    super.initState();
    _taskController.loadAllTasks();
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

  Future<void> _toggleTaskCompletion(String taskId, bool currentValue) async {
    try {
      await _taskController.toggleTaskCompletion(taskId, currentValue);
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
    List<Map<String, dynamic>> result = List.from(_taskController.allTasks);

    if (searchQuery.isNotEmpty && searchQuery.trim().isNotEmpty) {
      final query = searchQuery.toLowerCase().trim();
      result = result.where((task) {
        final title = (task['title']?.toString() ?? '').toLowerCase();
        final description = (task['description']?.toString() ?? '')
            .toLowerCase();
        final priority = (task['priority']?.toString() ?? '').toLowerCase();

        final matches =
            title.contains(query) ||
            description.contains(query) ||
            priority.contains(query);
        return matches;
      }).toList();
    }

    if (isDateFilterActive && selectedStartDate != null) {
      result = result.where((task) {
        final taskDateStr = task['date']?.toString();
        if (taskDateStr == null) return false;

        try {
          final taskDate = DateTime.parse("${taskDateStr}T00:00:00Z");

          if (selectedEndDate != null) {
            return taskDate.isAfter(
                  selectedStartDate!.subtract(const Duration(days: 1)),
                ) &&
                taskDate.isBefore(
                  selectedEndDate!.add(const Duration(days: 1)),
                );
          } else {
            return taskDate.year == selectedStartDate!.year &&
                taskDate.month == selectedStartDate!.month &&
                taskDate.day == selectedStartDate!.day;
          }
        } catch (e) {
          return false;
        }
      }).toList();
    }

    List<Map<String, dynamic>> statusFilteredTasks;
    if (selectedStatusFilter == 'History') {
      statusFilteredTasks = result
          .where((task) => (task['is_done'] ?? false) == true)
          .toList();
    } else {
      if (searchQuery.isEmpty) {
        statusFilteredTasks = result
            .where((task) => (task['is_done'] ?? false) == false)
            .toList();
      } else {
        statusFilteredTasks = result;
      }
    }

    if (selectedPriorityFilter == 'All') {
      return statusFilteredTasks;
    }

    return statusFilteredTasks.where((task) {
      final priority = task['priority']?.toString() ?? 'medium';
      final category = _getCategoryFromPriority(priority);
      return category.toLowerCase() == selectedPriorityFilter.toLowerCase();
    }).toList();
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
    return _taskController.allTasks
        .where((task) => (task['is_done'] ?? false) == false)
        .length;
  }

  String _formatDate(DateTime date) {
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
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final filteredTasks = _getFilteredTasks();

      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.bg,
        body: Column(
          children: [
            Obx(() {
              if (_taskController.isOfflineMode.value) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  color: Colors.orange.withValues(alpha: 0.9),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Offline Mode - View only',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            Expanded(
              child: SafeArea(
                child: Column(
                  children: [
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
                                        color: isDark
                                            ? Colors.white
                                            : AppColors.text,
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
                            ],
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        decoration: (isDark ? NeuDark.convex : Neu.convex)
                            .copyWith(
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
                              color: isDark
                                  ? Colors.grey[500]
                                  : Colors.grey[400],
                              fontSize: 16,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
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

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate:
                                      selectedStartDate ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: isDark
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.copyWith(
                                                surface: Theme.of(
                                                  context,
                                                ).colorScheme.surface,
                                                onSurface: Colors.white,
                                              )
                                            : Theme.of(context).colorScheme,
                                      ),
                                      child: child!,
                                    );
                                  },
                                );

                                if (picked != null) {
                                  setState(() {
                                    selectedStartDate = picked;
                                    selectedEndDate = null;
                                    isDateFilterActive = true;
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration:
                                    (isDark ? NeuDark.convex : Neu.convex)
                                        .copyWith(
                                          border: Border.all(
                                            color: isDateFilterActive
                                                ? AppColors.blue
                                                : (isDark
                                                      ? Colors.white.withValues(
                                                          alpha: 0.1,
                                                        )
                                                      : Colors.grey.withValues(
                                                          alpha: 0.2,
                                                        )),
                                            width: isDateFilterActive ? 2 : 1,
                                          ),
                                        ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today_outlined,
                                      size: 18,
                                      color: isDateFilterActive
                                          ? AppColors.blue
                                          : (isDark
                                                ? Colors.grey[400]
                                                : Colors.grey[600]),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        selectedStartDate == null
                                            ? 'Filter by Date'
                                            : _formatDate(selectedStartDate!),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isDateFilterActive
                                              ? AppColors.blue
                                              : (isDark
                                                    ? Colors.grey[400]
                                                    : Colors.grey[600]),
                                          fontWeight: isDateFilterActive
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (isDateFilterActive) ...[
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () async {
                                DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate:
                                      selectedEndDate ??
                                      (selectedStartDate ?? DateTime.now()),
                                  firstDate:
                                      selectedStartDate ?? DateTime(2000),
                                  lastDate: DateTime(2100),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: isDark
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.copyWith(
                                                surface: Theme.of(
                                                  context,
                                                ).colorScheme.surface,
                                                onSurface: Colors.white,
                                              )
                                            : Theme.of(context).colorScheme,
                                      ),
                                      child: child!,
                                    );
                                  },
                                );

                                if (picked != null) {
                                  setState(() {
                                    selectedEndDate = picked;
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration:
                                    (isDark ? NeuDark.convex : Neu.convex)
                                        .copyWith(
                                          border: Border.all(
                                            color: AppColors.blue,
                                            width: 2,
                                          ),
                                        ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today_outlined,
                                      size: 18,
                                      color: AppColors.blue,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      selectedEndDate == null
                                          ? 'End Date'
                                          : _formatDate(selectedEndDate!),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.blue,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedStartDate = null;
                                  selectedEndDate = null;
                                  isDateFilterActive = false;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.close,
                                  size: 18,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: filters.length,
                        itemBuilder: (context, index) {
                          final filter = filters[index];

                          bool isSelected = false;
                          if (filter == 'All') {
                            isSelected =
                                selectedStatusFilter == 'All' &&
                                selectedPriorityFilter == 'All';
                          } else if (filter == 'History') {
                            isSelected = selectedStatusFilter == 'History';
                          } else {
                            isSelected = selectedPriorityFilter == filter;
                          }

                          return GestureDetector(
                            onTap: () {
                              SoundService().playSound(SoundType.tap);
                              setState(() {
                                if (filter == 'All') {
                                  selectedStatusFilter = 'All';
                                  selectedPriorityFilter = 'All';
                                } else if (filter == 'History') {
                                  selectedStatusFilter =
                                      selectedStatusFilter == 'History'
                                      ? 'All'
                                      : 'History';
                                } else {
                                  selectedPriorityFilter =
                                      selectedPriorityFilter == filter
                                      ? 'All'
                                      : filter;
                                }
                              });
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
                                    : (isDark
                                          ? AppColors.darkCard
                                          : Colors.grey[200]),
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

                    Expanded(
                      child: _taskController.isLoading.value
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
                                    color: isDark
                                        ? Colors.grey[600]
                                        : Colors.grey[400],
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
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
            ),
          ],
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
                await _taskController.addTask(
                  title: result['text'].toString(),
                  date: result['date'] as DateTime,
                  description: result['description']?.toString(),
                  priority: result['priority']?.toString(),
                );
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
            if (i == 1) Get.offAllNamed(AppRoutes.today);
            if (i == 2) Get.offAllNamed(AppRoutes.upcoming);
            if (i == 3) Get.offAllNamed(AppRoutes.settings);
          },
        ),
      );
    });
  }

  Widget _buildInboxTaskCard(Map<String, dynamic> task, bool isDark) {
    final taskId = task['id']?.toString() ?? '';
    final title = task['title']?.toString() ?? 'No Title';
    final description = task['description']?.toString();
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
        SoundService().playSound(SoundType.tap);
        Get.to(() => TaskDetailScreen(task: task));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: isDark ? NeuDark.concave : Neu.concave,
        child: Row(
          children: [
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDone
                                ? (isDark ? Colors.grey[600] : Colors.grey[400])
                                : (isDark ? Colors.white : AppColors.text),
                            decoration: isDone
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
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
                      const SizedBox(width: 6),
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
                        )
                      else if (isHighPriority)
                        Row(
                          children: [
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
                  if (description != null && description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDone
                            ? (isDark ? Colors.grey[600] : Colors.grey[400])
                            : (isDark ? Colors.grey[400] : Colors.grey[600]),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
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

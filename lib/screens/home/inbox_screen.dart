import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/theme_tokens.dart';
import '../../widgets/add_task_button.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/task_card.dart';
import '../../controllers/task_controller.dart';
import '../../models/task_model.dart';
import '../add_task/add_task_popup.dart';

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

  // Helper function untuk cek apakah task sudah lewat tanggal hari ini (overdue)
  bool _isTaskOverdue(Task task) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(task.date.year, task.date.month, task.date.day);
    return taskDate.isBefore(today);
  }

  List<Task> _getFilteredTasks() {
    List<Task> result = List.from(_taskController.allTasks);

    if (searchQuery.isNotEmpty && searchQuery.trim().isNotEmpty) {
      final query = searchQuery.toLowerCase().trim();
      result = result.where((task) {
        final title = (task.title).toLowerCase();
        final description = (task.description ?? '').toLowerCase();
        final priority = task.priority.toLowerCase();

        final matches =
            title.contains(query) ||
            description.contains(query) ||
            priority.contains(query);
        return matches;
      }).toList();
    }

    if (isDateFilterActive && selectedStartDate != null) {
      result = result.where((task) {
        final taskDate = task.date;

        if (selectedEndDate != null) {
          return taskDate.isAfter(
                selectedStartDate!.subtract(const Duration(days: 1)),
              ) &&
              taskDate.isBefore(selectedEndDate!.add(const Duration(days: 1)));
        } else {
          return taskDate.year == selectedStartDate!.year &&
              taskDate.month == selectedStartDate!.month &&
              taskDate.day == selectedStartDate!.day;
        }
      }).toList();
    }

    List<Task> statusFilteredTasks;
    if (selectedStatusFilter == 'History') {
      // History: Task yang sudah selesai ATAU task yang sudah lewat tanggal hari ini
      statusFilteredTasks = result
          .where((task) => task.isDone == true || _isTaskOverdue(task))
          .toList();
    } else {
      if (searchQuery.isEmpty) {
        // All: Task yang belum selesai DAN belum lewat tanggal (belum overdue)
        statusFilteredTasks = result
            .where((task) => task.isDone == false && !_isTaskOverdue(task))
            .toList();
      } else {
        statusFilteredTasks = result;
      }
    }

    if (selectedPriorityFilter == 'All') {
      return statusFilteredTasks;
    }

    return statusFilteredTasks.where((task) {
      final category = _getCategoryFromPriority(task.priority);
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
        .where((task) => task.isDone == false)
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
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
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
                                    Flexible(
                                      child: Text(
                                        selectedEndDate == null
                                            ? 'End Date'
                                            : _formatDate(selectedEndDate!),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.blue,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
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
                                return TaskCard(
                                  task: task,
                                  onToggleCompletion: _toggleTaskCompletion,
                                );
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
            if (i == 1) Get.offAllNamed("/today");
            if (i == 2) Get.offAllNamed("/upcoming");
            if (i == 3) Get.offAllNamed("/settings");
          },
        ),
      );
    });
  }
}

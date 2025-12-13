import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/theme_tokens.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  // Filter state
  bool filterByPriority = false;
  String selectedPriority = 'medium'; // high, medium, low
  bool filterByStatus = false;
  bool showCompleted = false;
  bool filterByDate = false;
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

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
  }

  void _applyFilters() {
    // Filter preview logic removed - filters will be applied in inbox screen
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // Simpan Button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Return filter criteria ke inbox
                      Get.back(
                        result: {
                          'filterByPriority': filterByPriority,
                          'selectedPriority': selectedPriority,
                          'filterByStatus': filterByStatus,
                          'showCompleted': showCompleted,
                          'filterByDate': filterByDate,
                          'selectedStartDate': selectedStartDate
                              ?.toIso8601String(),
                          'selectedEndDate': selectedEndDate?.toIso8601String(),
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Simpan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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

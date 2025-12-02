import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_style.dart';
import '../../widgets/add_task_button.dart';
import '../../widgets/bottom_nav.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  int navIndex = 3;

  bool showInbox = true;
  bool showToday = true;
  bool showUpcoming = true;
  bool showCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Filter", style: AppStyle.title),
              const SizedBox(height: 20),

              SwitchListTile(
                value: showInbox,
                onChanged: (v) => setState(() => showInbox = v),
                activeThumbColor: AppColors.blue,
                title: const Text("Inbox", style: AppStyle.normal),
              ),
              SwitchListTile(
                value: showToday,
                onChanged: (v) => setState(() => showToday = v),
                activeThumbColor: AppColors.blue,
                title: const Text("Today", style: AppStyle.normal),
              ),
              SwitchListTile(
                value: showUpcoming,
                onChanged: (v) => setState(() => showUpcoming = v),
                activeThumbColor: AppColors.blue,
                title: const Text("Upcoming", style: AppStyle.normal),
              ),
              SwitchListTile(
                value: showCompleted,
                onChanged: (v) => setState(() => showCompleted = v),
                activeThumbColor: AppColors.blue,
                title: const Text("Completed", style: AppStyle.normal),
              ),

              const SizedBox(height: 12),
              const Text(
                "Gunakan filter untuk mengatur tampilan task.",
                style: AppStyle.smallGray,
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: AddTaskButton(
        onTap: () {
          // opsional
        },
      ),

      bottomNavigationBar: BottomNav(
        index: navIndex,
        onTap: (i) {
          if (i == navIndex) return;
          setState(() => navIndex = i);
          if (i == 0) Navigator.pushReplacementNamed(context, "/inbox");
          if (i == 1) Navigator.pushReplacementNamed(context, "/today");
          if (i == 2) Navigator.pushReplacementNamed(context, "/upcoming");
        },
      ),
    );
  }
}

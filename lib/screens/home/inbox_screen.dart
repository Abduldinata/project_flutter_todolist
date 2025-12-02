import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_style.dart';
import '../../widgets/add_task_button.dart';
import '../../widgets/bottom_nav.dart';
import '../search/search_popup.dart';
import '../profile/profile_screen.dart';
import '../add_task/add_task_popup.dart';


class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  int navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Top bar: title + icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Inbox", style: AppStyle.title),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () async {
                          await showDialog(
                            context: context,
                            builder: (ctx) => const SearchPopup(),
                          );
                        },
                        icon: const Icon(Icons.search, size: 26),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (ctx) => const ProfileScreen(),
                            ),
                          );
                        },
                        child: const CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // History section
              Align(
                alignment: Alignment.centerLeft,
                child: Text("History", style: AppStyle.subtitle),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "○ Text 1\n○ Text 2\n○ Text 3",
                  style: AppStyle.normal,
                ),
              ),

              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Today", style: AppStyle.subtitle),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "○ Text 1\n○ Text 2\n○ Text 3",
                  style: AppStyle.normal,
                ),
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: AddTaskButton(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (ctx) => const AddTaskPopup()),
          );
          if (result != null) {
            debugPrint("Task baru: ${result['text']} | ${result['date']}");
          }
        },
      ),

      bottomNavigationBar: BottomNav(
        index: navIndex,
        onTap: (i) {
          if (i == navIndex) return;
          setState(() => navIndex = i);
          if (i == 1) Navigator.pushReplacementNamed(context, "/today");
          if (i == 2) Navigator.pushReplacementNamed(context, "/upcoming");
          if (i == 3) Navigator.pushReplacementNamed(context, "/filter");
        },
      ),
    );
  }
}

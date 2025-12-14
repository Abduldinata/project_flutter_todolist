import 'package:flutter/material.dart';
import 'package:card_loading/card_loading.dart';
import '../theme/theme_tokens.dart';

class LoadingWidget extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const LoadingWidget({super.key, this.width, this.height, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return CardLoading(
      height: height ?? 50,
      width: width ?? 50,
      borderRadius: borderRadius ?? BorderRadius.circular(12),
    );
  }
}

class LoadingButton extends StatelessWidget {
  final Color? backgroundColor;
  final double? height;

  const LoadingButton({super.key, this.backgroundColor, this.height});

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.blue;

    return Container(
      height: height ?? 50,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: CardLoading(
          height: 30,
          width: 30,
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}

// Loading skeleton untuk task card list
class TaskCardLoading extends StatelessWidget {
  final int count;
  final bool isDark;

  const TaskCardLoading({super.key, this.count = 3, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: count,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: isDark ? NeuDark.concave : Neu.concave,
          child: Row(
            children: [
              // Checkbox skeleton
              CardLoading(
                height: 24,
                width: 24,
                borderRadius: BorderRadius.circular(12),
              ),
              const SizedBox(width: 16),
              // Content skeleton
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title skeleton
                    CardLoading(
                      height: 20,
                      width: double.infinity,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    const SizedBox(height: 8),
                    // Category and date skeleton
                    Row(
                      children: [
                        CardLoading(
                          height: 20,
                          width: 80,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        const SizedBox(width: 8),
                        CardLoading(
                          height: 16,
                          width: 60,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Flag icon skeleton
              CardLoading(
                height: 20,
                width: 20,
                borderRadius: BorderRadius.circular(10),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Loading skeleton untuk profile screen
class ProfileLoading extends StatelessWidget {
  final bool isDark;

  const ProfileLoading({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Profile header skeleton
          CardLoading(
            height: 100,
            width: 100,
            borderRadius: BorderRadius.circular(50),
          ),
          const SizedBox(height: 16),
          CardLoading(
            height: 24,
            width: 150,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(height: 8),
          CardLoading(
            height: 16,
            width: 200,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(height: 32),
          // Settings sections skeleton
          ...List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: isDark ? NeuDark.concave : Neu.concave,
                child: Row(
                  children: [
                    CardLoading(
                      height: 40,
                      width: 40,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CardLoading(
                            height: 18,
                            width: 120,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          const SizedBox(height: 8),
                          CardLoading(
                            height: 14,
                            width: 200,
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Loading skeleton untuk search results
class SearchLoading extends StatelessWidget {
  final int count;

  const SearchLoading({super.key, this.count = 3});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: count,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: isDark ? NeuDark.concave : Neu.concave,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardLoading(
                height: 20,
                width: double.infinity,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(height: 8),
              CardLoading(
                height: 16,
                width: 150,
                borderRadius: BorderRadius.circular(8),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Loading skeleton untuk today screen - hanya task cards
class TodayTaskLoading extends StatelessWidget {
  final bool isDark;

  const TodayTaskLoading({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // High Priority Section skeleton
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            CardLoading(
              height: 14,
              width: 100,
              borderRadius: BorderRadius.circular(7),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Task cards skeleton
        ...List.generate(
          2,
          (index) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: isDark ? NeuDark.concave : Neu.concave,
            child: Row(
              children: [
                CardLoading(
                  height: 24,
                  width: 24,
                  borderRadius: BorderRadius.circular(12),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CardLoading(
                              height: 20,
                              width: double.infinity,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          const SizedBox(width: 6),
                          CardLoading(
                            height: 20,
                            width: 60,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          const SizedBox(width: 6),
                          CardLoading(
                            height: 16,
                            width: 70,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      CardLoading(
                        height: 16,
                        width: 200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                CardLoading(
                  height: 20,
                  width: 20,
                  borderRadius: BorderRadius.circular(10),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Upcoming Section skeleton
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.blue,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            CardLoading(
              height: 14,
              width: 80,
              borderRadius: BorderRadius.circular(7),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Task cards skeleton
        ...List.generate(
          2,
          (index) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: isDark ? NeuDark.concave : Neu.concave,
            child: Row(
              children: [
                CardLoading(
                  height: 24,
                  width: 24,
                  borderRadius: BorderRadius.circular(12),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CardLoading(
                              height: 20,
                              width: double.infinity,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          const SizedBox(width: 6),
                          CardLoading(
                            height: 20,
                            width: 60,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          const SizedBox(width: 6),
                          CardLoading(
                            height: 16,
                            width: 70,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      CardLoading(
                        height: 16,
                        width: 180,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                CardLoading(
                  height: 20,
                  width: 20,
                  borderRadius: BorderRadius.circular(10),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // History Section skeleton
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[600] : Colors.grey[400],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            CardLoading(
              height: 14,
              width: 70,
              borderRadius: BorderRadius.circular(7),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Task cards skeleton
        ...List.generate(
          2,
          (index) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: isDark ? NeuDark.concave : Neu.concave,
            child: Row(
              children: [
                CardLoading(
                  height: 24,
                  width: 24,
                  borderRadius: BorderRadius.circular(12),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CardLoading(
                              height: 20,
                              width: double.infinity,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          const SizedBox(width: 6),
                          CardLoading(
                            height: 20,
                            width: 60,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          const SizedBox(width: 6),
                          CardLoading(
                            height: 16,
                            width: 70,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      CardLoading(
                        height: 16,
                        width: 180,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                CardLoading(
                  height: 20,
                  width: 20,
                  borderRadius: BorderRadius.circular(10),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

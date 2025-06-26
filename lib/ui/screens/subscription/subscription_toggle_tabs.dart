import 'package:flutter/material.dart';

class SubscriptionToggleTabs extends StatefulWidget {
  const SubscriptionToggleTabs({super.key});

  @override
  State<SubscriptionToggleTabs> createState() => _SubscriptionToggleTabsState();
}

class _SubscriptionToggleTabsState extends State<SubscriptionToggleTabs> {
  int selectedIndex = 0;

  final labels = ['Mobile Subscription', 'Speaker Subscription'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
          ), // Add horizontal padding
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(30),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      left:
                          selectedIndex *
                          (constraints.maxWidth / labels.length),
                      child: Container(
                        width: constraints.maxWidth / labels.length,
                        height: 36, // Adjust height as needed
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32),
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                    Row(
                      children: List.generate(labels.length, (index) {
                        final isSelected = selectedIndex == index;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => selectedIndex = index),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: Text(
                                  labels[index],
                                  style: TextStyle(
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : Colors.black54,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Content view below tab
      ],
    );
  }
}

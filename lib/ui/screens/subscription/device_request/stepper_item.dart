import 'package:flutter/material.dart';

class StepperItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isCompleted;

  const StepperItem({
    required this.label,
    this.isActive = false,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isActive ? Colors.black : Colors.grey,
          ),
        ),
        const SizedBox(height: 12), // Increased space here
        Container(
          padding:
              isCompleted
                  ? const EdgeInsets.all(0)
                  : const EdgeInsets.all(5), // No padding for completed
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border:
                isCompleted
                    ? null
                    : Border.all(
                      color:
                          isActive
                              ? const Color(0xFF2E7D32)
                              : Colors.grey.shade300,
                      width: 1,
                    ),
          ),
          child:
              isCompleted
                  ? const CircleAvatar(
                    radius: 11,
                    backgroundColor: Color(0xFF2E7D32),
                    child: Icon(Icons.check, size: 10, color: Colors.white),
                  )
                  : CircleAvatar(
                    radius: 6,
                    backgroundColor:
                        isActive
                            ? const Color(0xFF2E7D32)
                            : Colors.grey.shade300,
                  ),
        ),
      ],
    );
  }
}

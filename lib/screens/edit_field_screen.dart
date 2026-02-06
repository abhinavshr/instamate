import 'package:flutter/material.dart';

class EditFieldScreen extends StatelessWidget {
  final String title;
  final String initialValue;
  final int maxLines;

  const EditFieldScreen({
    super.key,
    required this.title,
    required this.initialValue,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: initialValue);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(title),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Done',
              style: TextStyle(
                color: Color(0xFF3797EF),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: controller,
                maxLines: maxLines,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  suffixIcon: controller.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: controller.clear,
                  )
                      : null,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Helper text (Instagram style)
            Text(
              _helperText(title),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _helperText(String field) {
    switch (field) {
      case 'Name':
        return 'Help people discover your account by using the name you’re known by.';
      case 'Username':
        return 'You can change your username anytime.';
      case 'Website':
        return 'Add a link to your website or profile.';
      case 'Bio':
        return 'Tell people a little about yourself.';
      default:
        return '';
    }
  }
}

import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // AppBar
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Image.asset(
          'assets/images/logo.png',
          height: 32,
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.favorite_border, color: Colors.black),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.message_outlined, color: Colors.black),
          ),
        ],
      ),

      body: Column(
        children: [
          _storiesSection(),
          const Divider(height: 1),
          Expanded(child: _feedSection()),
        ],
      ),

    );
  }

  // ---------------- STORIES ----------------
  Widget _storiesSection() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: 8,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFfeda75),
                        Color(0xFFd62976),
                        Color(0xFF962fbf),
                        Color(0xFF4f5bd5),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: const CircleAvatar(
                        backgroundColor: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'username',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------------- FEED ----------------
  Widget _feedSection() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post header
            ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.grey),
              title: const Text(
                'username',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: const Icon(Icons.more_vert),
            ),

            // Post image
            Container(
              height: 300,
              color: Colors.grey.shade300,
              child: const Center(
                child: Icon(Icons.image, size: 80, color: Colors.white),
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: const [
                  Icon(Icons.favorite_border),
                  SizedBox(width: 16),
                  Icon(Icons.chat_bubble_outline),
                  SizedBox(width: 16),
                  Icon(Icons.send_outlined),
                  Spacer(),
                  Icon(Icons.bookmark_border),
                ],
              ),
            ),

            // Likes
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                '1,234 likes',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            // Caption
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      text: 'username ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: 'This is a sample caption...'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 4 - Cards with Like',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const CardsScreen(),
    );
  }
}

class CardItem {
  final String title;
  final String subtitle;
  final String description;
  final String image;
  bool isLiked;
  CardItem({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.image,
    this.isLiked = false,
  });
}

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}
class _CardsScreenState extends State<CardsScreen> {
  final List<CardItem> items = [
    CardItem(
      title: 'Flutter',
      subtitle: 'Build beautiful native apps',
      description: 'Flutter is Google\'s UI toolkit for building beautiful, natively compiled applications for mobile, web, and desktop from a single codebase.',
      image: 'https://picsum.photos/seed/flutter/400/200',
    ),
    CardItem(
      title: 'Dart',
      subtitle: 'The language behind Flutter',
      description: 'Dart is a client-optimized language for fast apps on any platform. It is used to build Flutter applications.',
      image: 'https://picsum.photos/seed/dart/400/200',
    ),
    CardItem(
      title: 'Mobile Development',
      subtitle: 'iOS and Android from one codebase',
      description: 'Build native mobile apps for both iOS and Android using a single codebase with Flutter.',
      image: 'https://picsum.photos/seed/mobile/400/200',
    ),
  ];

  void toggleLike(int index) {
    setState(() {
      items[index].isLiked = !items[index].isLiked;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          items[index].isLiked
              ? 'You liked ${items[index].title} ❤️'
              : 'You unliked ${items[index].title}',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void openDetails(CardItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(item.title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item.image,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 12),
                Text(item.description),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab 4 - Cards with Like'),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () => openDetails(item),
              borderRadius: BorderRadius.circular(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Image.network(
                      item.image,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 150,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.image_not_supported, size: 50),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item.subtitle,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            item.isLiked
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: item.isLiked ? Colors.red : Colors.grey,
                          ),
                          onPressed: () => toggleLike(index),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
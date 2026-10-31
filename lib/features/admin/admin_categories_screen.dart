import 'package:flutter/material.dart';

class AdminCategoriesScreen extends StatefulWidget {
  const AdminCategoriesScreen({super.key});

  @override
  State<AdminCategoriesScreen> createState() => _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends State<AdminCategoriesScreen> {
  final List<Map<String, dynamic>> _categories = [
    {
      'id': 'land',
      'title': 'மனை / பிளாட் (Plots & Land)',
      'subtitle': 'வீட்டு மனை, வணிக மனை, விவசாய நிலம்',
      'image': 'assets/images/cat_land.png',
      'rec_image': 'assets/images/rec_land.png',
      'icon': Icons.terrain_rounded,
      'color': const Color(0xFF059669),
      'active': true,
    },
    {
      'id': 'house',
      'title': 'தனி வீடு / வில்லா (Individual House)',
      'subtitle': 'புதிய வீடு, பழைய வீடு, வில்லா',
      'image': 'assets/images/cat_house.png',
      'rec_image': 'assets/images/rec_house.png',
      'icon': Icons.home_rounded,
      'color': const Color(0xFF0284C7),
      'active': true,
    },
    {
      'id': 'farm',
      'title': 'தோட்டம் / பண்ணை (Farm Land)',
      'subtitle': 'தென்னந்தோப்பு, மாந்தோப்பு, விவசாய பூமி',
      'image': 'assets/images/cat_farm.png',
      'rec_image': 'assets/images/rec_farm.png',
      'icon': Icons.agriculture_rounded,
      'color': const Color(0xFF16A34A),
      'active': true,
    },
    {
      'id': 'apartment',
      'title': 'அடுக்குமாடி குடியிருப்பு (Apartments)',
      'subtitle': '1BHK, 2BHK, 3BHK பிளாட்கள்',
      'image': 'assets/images/cat_apartment.png',
      'rec_image': 'assets/images/rec_apartment.png',
      'icon': Icons.apartment_rounded,
      'color': const Color(0xFF7C3AED),
      'active': true,
    },
    {
      'id': 'rental',
      'title': 'வாடகை & லீஸ் (Rent & Lease)',
      'subtitle': 'வாடகை வீடு, கடை, அலுவலகம்',
      'image': 'assets/images/cat_rental.png',
      'rec_image': 'assets/images/rec_rental.png',
      'icon': Icons.key_rounded,
      'color': const Color(0xFFEA580C),
      'active': true,
    },
    {
      'id': 'commercial',
      'title': 'வணிக வளாகம் (Commercial)',
      'subtitle': 'வணிக கடை, குடோன், வணிக கட்டிடம்',
      'image': 'assets/images/cat_land.png',
      'rec_image': 'assets/images/rec_land.png',
      'icon': Icons.storefront_rounded,
      'color': const Color(0xFFD97706),
      'active': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F3D6E),
        elevation: 2,
        title: const Text(
          'கேட்டகரி மேலாண்மை (Categories)',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final color = cat['color'] as Color;

          return Card(
            elevation: 1.5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 65,
                      height: 65,
                      color: color.withValues(alpha: 0.1),
                      child: Image.asset(
                        cat['image'] as String,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(cat['icon'] as IconData, color: color, size: 32),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cat['title'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cat['subtitle'] as String,
                          style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.green.shade200),
                              ),
                              child: const Text(
                                'Active (நேரலை)',
                                style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, color: Color(0xFF0284C7)),
                    onPressed: () {
                      _showEditCategoryDialog(cat);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showEditCategoryDialog(Map<String, dynamic> cat) {
    final titleController = TextEditingController(text: cat['title']);
    final subtitleController = TextEditingController(text: cat['subtitle']);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${cat['title']} - திருத்தம்', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'கேட்டகரி பெயர்', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: subtitleController,
              decoration: const InputDecoration(labelText: 'விளக்க உரை', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ரத்து'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F3D6E)),
            onPressed: () {
              setState(() {
                cat['title'] = titleController.text.trim();
                cat['subtitle'] = subtitleController.text.trim();
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✅ கேட்டகரி விவரங்கள் புதுப்பிக்கப்பட்டன!'), behavior: SnackBarBehavior.floating),
              );
            },
            child: const Text('சேமி', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

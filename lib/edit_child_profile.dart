import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditChildProfileScreen extends StatefulWidget {
  final String childId;

  const EditChildProfileScreen({super.key, required this.childId});

  @override
  State<EditChildProfileScreen> createState() => _EditChildProfileScreenState();
}

class _EditChildProfileScreenState extends State<EditChildProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  String? selectedAge;
  List<String> selectedInterests = [];

  bool loading = true;

  // Age options 5–12
  final List<String> ageOptions =
  List.generate(8, (i) => (i + 5).toString());

  final List<String> interestOptions = const [
    "Animals",
    "Adventure",
    "Mystery",
    "Space",
    "Sports",
    "Funny stories",
  ];

  @override
  void initState() {
    super.initState();
    _loadChildData();
  }

  Future<void> _loadChildData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Not logged in")),
      );
      Navigator.pop(context);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('children')
          .doc(widget.childId)
          .get();

      if (!doc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Child profile not found.")),
        );
        Navigator.pop(context);
        return;
      }

      final data = doc.data() as Map<String, dynamic>;

      setState(() {
        nameController.text = data['childName'] ?? '';
        selectedAge = data['age']?.toString();
        selectedInterests =
        List<String>.from(data['interests'] ?? <String>[]);
        loading = false;
      });
    } catch (e) {
      print("Error loading child profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load profile.")),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _saveChanges() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (nameController.text.trim().isEmpty || selectedAge == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Name and age are required."),
        ),
      );
      return;
    }

    try {
      final ref = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('children')
          .doc(widget.childId);

      await ref.update({
        'childName': nameController.text.trim(),
        'age': selectedAge,
        'interests': selectedInterests,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Child profile updated.")),
      );
      Navigator.pop(context); // go back to Settings
    } catch (e) {
      print("Error updating child profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to save changes.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Child Profile"),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Name
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Child's name",
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),

            // Age
            DropdownButtonFormField<String>(
              value: selectedAge,
              decoration: const InputDecoration(
                labelText: "Age",
              ),
              items: ageOptions
                  .map(
                    (age) => DropdownMenuItem(
                  value: age,
                  child: Text("$age years old"),
                ),
              )
                  .toList(),
              onChanged: (v) => setState(() => selectedAge = v),
            ),
            const SizedBox(height: 16),

            // Interests
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Interests",
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              children: interestOptions.map((interest) {
                final selected =
                selectedInterests.contains(interest);
                return Padding(
                  padding:
                  const EdgeInsets.only(right: 8.0, bottom: 8.0),
                  child: ChoiceChip(
                    label: Text(interest),
                    selected: selected,
                    onSelected: (value) {
                      setState(() {
                        if (selected) {
                          selectedInterests.remove(interest);
                        } else {
                          selectedInterests.add(interest);
                        }
                      });
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveChanges,
                child: const Text("Save changes"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

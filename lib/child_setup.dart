// This Screen helps parents set up their childs profile after signing up.
// it collects basic info like their name, age, interests and reading habits. then it gets stores to Firestore.

import 'package:final_year_project/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'homepage.dart';

class ChildSetup extends StatefulWidget {
  const ChildSetup({super.key});

  @override
  State<ChildSetup> createState() => _ChildSetupState();
}

class _ChildSetupState extends State<ChildSetup> {
  // Controls the pages in the setup flow (3 pages total)
  final PageController _controller = PageController();
  int _page = 0;

  //Basic Information
  final TextEditingController nameController = TextEditingController();
  String? selectedAge;
  String? readingLevel;

  //Reading Habits
  String? readingFrequency;
  String? readingDuration;
  final List<String> selectedChallenges = [];
  String? readingGoal;

  //Interests and Motivation
  final List<String> selectedInterests = [];
  final List<String> selectedMotivation = [];

  //Colors for UI styling
  final Color bg = const Color(0xFFF9FAFB);
  final Color card = Colors.white;
  final Color primary = const Color(0xFF6CA8F1);
  final Color textDark = const Color(0xFF1E293B);
  final Color softGrey = const Color(0xFFCBD5E1);

  //Show short messages at the bottom of the screen
  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins()),
        backgroundColor: primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Check if the current page has all required fields filled
  bool _validateCurrentPage() {
    if (_page == 0) {
      if (nameController.text.trim().isEmpty ||
          selectedAge == null ||
          readingLevel == null) {
        _snack("Please fill out name, age, and reading confidence to continue.");
        return false;
      }
    } else if (_page == 1) {
      if (readingFrequency == null ||
          readingDuration == null ||
          selectedChallenges.isEmpty ||
          readingGoal == null) {
        _snack("Please complete this step before continuing.");
        return false;
      }
    } else if (_page == 2) {
      if (selectedInterests.isEmpty || selectedMotivation.isEmpty) {
        _snack("Please select at least one interest and one motivator.");
        return false;
      }
    }
    return true;
  }

  // Save child's information to Firestore
  Future<void> _saveProfile() async {
    final parent  = FirebaseAuth.instance.currentUser;
    if (parent == null) {
      _snack("You’re not signed in.");
      return;
    }

    try {
      final childRef = FirebaseFirestore.instance
          .collection('users')
          .doc(parent.uid)
          .collection('children')
          .doc();
      final childId = childRef.id;

      print("Creating child profile $childId under parent ${parent.uid}");

      // saving the full child profile
      await childRef.set({
        'childName': nameController.text.trim(),
        'age': selectedAge,
        'readingLevel': readingLevel,
        'readingFrequency': readingFrequency,
        'readingDuration': readingDuration,
        'challenges': selectedChallenges,
        'readingGoal': readingGoal,
        'interests': selectedInterests,
        'motivation': selectedMotivation,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print("Child saved under users/${parent.uid}/children/$childId");

      // small pause
      await Future.delayed(const Duration(milliseconds: 250));

      //go back to wrapper so it can decide where to go
      Get.offAll(() => const wrapper());
    } catch (e) {
      print("Error saving profile: $e");
      _snack("Failed to save profile");
    }
  }

  // Go to next page or finish setup
  void _next() async {
    if (!_validateCurrentPage()) return;
    if (_page < 2) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 260), curve: Curves.easeOut);
    } else {
      await _saveProfile();
    }
  }

  // Go back to previous page
  void _back() {
    if (_page > 0) {
      _controller.previousPage(
          duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
    }
  }

  // Little dots that show progress at the top
  Widget _dot(int index) {
    final bool active = index == _page;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 10,
      width: active ? 22 : 10,
      decoration: BoxDecoration(
        color: active ? primary : softGrey,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  // Section titles and hints
  Widget _sectionTitle(String t) => Text(
    t,
    style: GoogleFonts.poppins(
        fontSize: 22, fontWeight: FontWeight.w600, color: textDark),
  );

  Widget _hint(String t) => Text(
    t,
    style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
  );

  // The little selectable option boxes
  Widget _chipOption({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.only(right: 8, bottom: 8),
        decoration: BoxDecoration(
          color: selected ? primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? primary : softGrey),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: selected ? Colors.white : textDark,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _page1() {
    return _StepCard(
      color: card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("About your child"),
          const SizedBox(height: 8),
          _hint("We’ll use this to personalise the first plan."),
          const SizedBox(height: 20),

          // Child's name input
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: "Child’s name",
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 16),

          // Dropdown for age
          DropdownButtonFormField<String>(
            value: selectedAge,
            decoration: const InputDecoration(labelText: "Age"),
            items: List.generate(8, (i) => (i + 5).toString())
                .map((age) =>
                DropdownMenuItem(value: age, child: Text("$age years old")))
                .toList(),
            onChanged: (v) => setState(() => selectedAge = v),
          ),
          const SizedBox(height: 16),

          // Dropdown for reading confidence
          DropdownButtonFormField<String>(
            value: readingLevel,
            decoration:
            const InputDecoration(labelText: "Reading confidence"),
            items: const [
              "Just starting",
              "Getting better",
              "Reads on their own",
              "Advanced reader"
            ]
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) => setState(() => readingLevel = v),
          ),
        ],
      ),
    );
  }

  // --- Step 2 Page ---
  Widget _page2() {
    final challengeOptions = [
      "Sounding out words",
      "Reading smoothly",
      "Understanding stories",
      "Remembering new words",
      "Writing sentences",
    ];

    return _StepCard(
      color: card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("Reading habits"),
          const SizedBox(height: 8),
          _hint("This helps us set the right pace and support."),
          const SizedBox(height: 20),

          // Reading frequency
          DropdownButtonFormField<String>(
            value: readingFrequency,
            decoration:
            const InputDecoration(labelText: "How often do they read?"),
            items: const ["Rarely", "Sometimes", "Most days", "Every day"]
                .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                .toList(),
            onChanged: (v) => setState(() => readingFrequency = v),
          ),
          const SizedBox(height: 16),

          // Reading duration
          DropdownButtonFormField<String>(
            value: readingDuration,
            decoration:
            const InputDecoration(labelText: "Typical reading time"),
            items: const ["<10 min", "10–20 min", "20–30 min", "30+ min"]
                .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                .toList(),
            onChanged: (v) => setState(() => readingDuration = v),
          ),
          const SizedBox(height: 16),

          // Challenges
          Text("What’s most challenging?",
              style: GoogleFonts.poppins(fontSize: 16, color: textDark)),
          const SizedBox(height: 8),
          Wrap(
            children: challengeOptions.map((c) {
              final selected = selectedChallenges.contains(c);
              return _chipOption(
                label: c,
                selected: selected,
                onTap: () {
                  setState(() {
                    selected
                        ? selectedChallenges.remove(c)
                        : selectedChallenges.add(c);
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Main reading goal
          DropdownButtonFormField<String>(
            value: readingGoal,
            decoration: const InputDecoration(labelText: "Main goal"),
            items: const [
              "Improve confidence",
              "Enjoy reading",
              "Improve pronunciation",
              "Expand vocabulary"
            ]
                .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                .toList(),
            onChanged: (v) => setState(() => readingGoal = v),
          ),
        ],
      ),
    );
  }

  Widget _page3() {
    final interestOptions = [
      "Animals",
      "Adventure",
      "Mystery",
      "Space",
      "Sports",
      "Funny stories"
    ];
    final motivationOptions = [
      "Rewards",
      "Encouragement",
      "Competition",
      "Fun challenges",
      "Seeing progress"
    ];

    return _StepCard(
      color: card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("Interests & motivation"),
          const SizedBox(height: 8),
          _hint("We’ll pick stories and activities that match these."),
          const SizedBox(height: 20),

          // Interests
          Text("What stories do they enjoy?",
              style: GoogleFonts.poppins(fontSize: 16, color: textDark)),
          const SizedBox(height: 8),
          Wrap(
            children: interestOptions.map((i) {
              final selected = selectedInterests.contains(i);
              return _chipOption(
                label: i,
                selected: selected,
                onTap: () {
                  setState(() {
                    selected
                        ? selectedInterests.remove(i)
                        : selectedInterests.add(i);
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Motivation
          Text("What motivates them?",
              style: GoogleFonts.poppins(fontSize: 16, color: textDark)),
          const SizedBox(height: 8),
          Wrap(
            children: motivationOptions.map((m) {
              final selected = selectedMotivation.contains(m);
              return _chipOption(
                label: m,
                selected: selected,
                onTap: () {
                  setState(() {
                    selected
                        ? selectedMotivation.remove(m)
                        : selectedMotivation.add(m);
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  //Screen layout and buttons
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        title: Text("Child Setup",
            style: GoogleFonts.poppins(color: textDark)),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),

          // Progress dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, _dot),
          ),
          const SizedBox(height: 8),

          // Pages
          Expanded(
            child: PageView(
              controller: _controller,
              physics: const ClampingScrollPhysics(),
              onPageChanged: (i) => setState(() => _page = i),
              children: [
                _page1(),
                _page2(),
                _page3(),
              ],
            ),
          ),

          // Navigation buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _page == 0 ? null : _back,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: softGrey),
                      foregroundColor: textDark,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text("Back", style: GoogleFonts.poppins()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 2,
                    ),
                    child: Text(
                      _page == 2 ? "Finish" : "Next",
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// This widget just wraps each step in a nice card with padding and shadows
class _StepCard extends StatelessWidget {
  final Widget child;
  final Color color;
  const _StepCard({required this.child, required this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
          child: Card(
            color: color,
            elevation: 6,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            child: Padding(
              padding: const EdgeInsets.all(22.0),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

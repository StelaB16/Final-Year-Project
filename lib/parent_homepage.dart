import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'book_recommendation.dart';
import 'my_books.dart';

class ParentHomePage extends StatelessWidget {
  const ParentHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("Not logged in")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Little Readers"),
        centerTitle: true,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, size: 40),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Parent Profile"),
                  content: Text(
                    "Logged in as: ${user.email}",
                    style: const TextStyle(fontSize: 20),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Close")),
                    TextButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pop(context);
                      },
                      child: const Text("Logout"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('children')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No children yet"));
          }

          final children = snapshot.data!.docs;

          return ListView.builder(
            itemCount: children.length,
            itemBuilder: (context, index) {
              final childData =
              children[index].data() as Map<String, dynamic>;
              final childId = children[index].id;
              final interests = (childData["interests"] as List?) ?? [];

              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  title: Text(
                    childData['childName'] ?? 'Unknown child',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Age: ${childData['age']}\n"
                        "Reading level: ${childData['readingLevel']}\n"
                        "Interests: ${interests.join(', ')}",
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      final age = childData["age"].toString();
                      final interest =
                      interests.isNotEmpty ? interests.first : "children";

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookRecommendationScreen(
                            age: age,
                            interest: interest,
                            childId: childId,
                          ),
                        ),
                      );
                    },
                    child: const Text("Get Books"),
                  ),
                ),
              );
            },
          );
        },
      ),

      bottomNavigationBar: Container(
        height: 80,
        color: Theme.of(context).primaryColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.home_outlined,
                  color: Colors.white, size: 35),
            ),
            IconButton(
              onPressed: () async {
                final childrenSnapshot = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('children')
                    .get();

                if (childrenSnapshot.docs.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("No child profile found.")),
                  );
                  return;
                }

                final firstChildId = childrenSnapshot.docs.first.id;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => MyBooksScreen(childId: firstChildId)),
                );
              },
              icon: const Icon(Icons.menu_book_outlined,
                  color: Colors.white, size: 35),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.widgets_outlined,
                  color: Colors.white, size: 35),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.record_voice_over,
                  color: Colors.white, size: 35),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ParentHomePage extends StatelessWidget {
  const ParentHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text("Not logged in")));
    }

    // 1) listen to the list of child links
    return Scaffold(
      appBar: AppBar(title: const Text("Parent dashboard")),
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

          final childLinks = snapshot.data!.docs;

          return ListView.builder(
            itemCount: childLinks.length,
            itemBuilder: (context, index) {
              final link = childLinks[index];
              final childId = link.id;

              // 2) for each child link, load the actual child doc
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(childId)
                    .get(),
                builder: (context, childSnap) {
                  if (childSnap.connectionState == ConnectionState.waiting) {
                    return const ListTile(title: Text("Loading child..."));
                  }
                  if (!childSnap.hasData || !childSnap.data!.exists) {
                    return const ListTile(title: Text("Child not found"));
                  }

                  final data =
                  childSnap.data!.data() as Map<String, dynamic>;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['childName'] ?? 'Unknown child',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text("Age: ${data['age'] ?? '-'}"),
                          Text("Reading level: ${data['readingLevel'] ?? '-'}"),
                          Text("Reading freq: ${data['readingFrequency'] ?? '-'}"),
                          Text("Reading time: ${data['readingDuration'] ?? '-'}"),
                          const SizedBox(height: 4),
                          Text("Challenges: ${(data['challenges'] as List?)?.join(', ') ?? '-'}"),
                          Text("Interests: ${(data['interests'] as List?)?.join(', ') ?? '-'}"),
                          Text("Motivation: ${(data['motivation'] as List?)?.join(', ') ?? '-'}"),
                          Text("Goal: ${data['readingGoal'] ?? '-'}"),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

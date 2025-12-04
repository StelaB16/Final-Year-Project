import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'edit_child_profile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Not logged in")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // show parent email
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Parent account"),
            subtitle: Text(user.email ?? "No email"),
          ),
          const Divider(),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Text(
              "Child profiles",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          // List of children from Firestore
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
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
                  return const Center(child: Text("No child profiles yet."));
                }

                final children = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: children.length,
                  itemBuilder: (context, index) {
                    final childDoc = children[index];
                    final data =
                    childDoc.data() as Map<String, dynamic>;
                    final childName = data['childName'] ?? 'Unknown child';
                    final age = data['age']?.toString() ?? '?';

                    return ListTile(
                      leading: const Icon(Icons.child_care),
                      title: Text(childName),
                      subtitle: Text("Age: $age"),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditChildProfileScreen(
                                childId: childDoc.id,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),

          const Divider(),

          // Logout button at bottom
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context)
                      .popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

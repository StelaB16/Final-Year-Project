import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ParentHomePage extends StatelessWidget {
  const ParentHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    //get the current logged in parent
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text("Not logged in")));
    }

    // listen to the list of child links
    return Scaffold(
      appBar: AppBar(
        title: const Text("Little Readers"),
        centerTitle: true,
        elevation: 1,

        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, size: 40),
            onPressed: () {
              final user = FirebaseAuth.instance.currentUser;

              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Parent Profile"),
                  content: Text(
                    "Logged in as: ${user?.email}",
                    style: const TextStyle(fontSize: 24),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Close"),
                    ),
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
          //Handle loading, errors and empty lists
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

              // for each child link, load the actual child doc
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

                  final data = childSnap.data!.data() as Map<String, dynamic>;

                  //Show the childs info
                 return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Confirmation"),
                            content: const Text("Continue Reading?"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, "/book");
                                },
                                child: const Text("Yes"),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Cancel"),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            constraints: const BoxConstraints(
                              minWidth: 75,
                              minHeight: 120,
                            ),
                            margin: const EdgeInsets.all(15.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(style: BorderStyle.none),
                              image: const DecorationImage(
                                fit: BoxFit.cover,
                                image: AssetImage(
                                  "assets/images/google-books-to-pdf-1024x576.png",
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Container(
                                  alignment: Alignment.bottomLeft,
                                  padding: const EdgeInsets.only(
                                    top: 15,
                                    right: 15,
                                  ),
                                  child: const Text(
                                    "Lean UX: Applying Lean Principles to Improve User Experience",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.bottomLeft,
                                  margin: const EdgeInsets.only(top: 5, right: 15),
                                  child: const Text(
                                    "Josh Haze",
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 10, right: 15),
                                  alignment: Alignment.bottomLeft,
                                  child: Text(
                                    "Continue Reading",
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
      bottomNavigationBar: Container(
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            enableFeedback: false,
            onPressed: () {},
            icon: const Icon(
              Icons.home_outlined,
              color: Colors.white,
              size: 35,
            ),
          ),
          IconButton(
            enableFeedback: false,
            onPressed: () {},
            icon: const Icon(
              Icons.menu_book_outlined,
              color: Colors.white,
              size: 35,
            ),
          ),
          IconButton(
            enableFeedback: false,
            onPressed: () {},
            icon: const Icon(
              Icons.widgets_outlined,
              color: Colors.white,
              size: 35,
            ),
          ),
          IconButton(
            enableFeedback: false,
            onPressed: () {},
            icon: const Icon(
              Icons.record_voice_over,
              color: Colors.white,
              size: 35,
            ),
          ),
        ],
      ),
    ),

    );
  }
}

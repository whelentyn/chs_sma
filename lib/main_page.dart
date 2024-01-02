import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cooking_app/edit_profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'auth/login_screen.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final List<Map<String, dynamic>> _allResults = [];

  @override
  void initState() {
    super.initState();
    getUserRecipes(); // Fetch user recipes when the widget is initialized
  }

  Future<void> getUserRecipes() async {
    try {
      String? userId = _auth.currentUser!.uid;

      if (userId != null) {
        var userRecipeDocs = await FirebaseFirestore.instance
            .collection('UserRecipes')
            .where('user_id',
                isEqualTo: FirebaseFirestore.instance.doc('Users/$userId'))
            .get();

        List<String> recipeIds = [];
        for (var doc in userRecipeDocs.docs) {
          var recipeIdList = doc['recipe_id'];
          if (recipeIdList is List) {
            for (var recipeId in recipeIdList) {
              if (recipeId is DocumentReference) {
                recipeIds.add(recipeId.id);
              } else if (recipeId is String) {
                // If it's a String, use it directly
                recipeIds.add(recipeId);
              } else {
                print(
                    'Unexpected type in recipe_id list: ${recipeId.runtimeType}');
              }
            }
          } else {
            print('Unexpected type for recipe_id: ${recipeIdList.runtimeType}');
          }
        }
        List<Map<String, dynamic>> userRecipes = [];

        for (var recipeId in recipeIds) {
          var recipeDoc = await FirebaseFirestore.instance
              .collection('Recipes')
              .doc(recipeId)
              .get();

          if (recipeDoc.exists) {
            userRecipes
                .add(recipeDoc.data()!); // Assuming data exists and is not null
          }
        }
        setState(() {
          _allResults.addAll(userRecipes);
        });

        print('Number of recipes retrieved: ${_allResults.length}');
      } else {
        print('No user logged in');
      }
    } catch (e) {
      print(
          'An error occurred while retrieving user recipes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    String? _email = _auth.currentUser!.email;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cooking App"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const EditProfileScreen()));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CupertinoSearchTextField(
              onChanged: (value) {
                print("The search text is: $value");
              },
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => print("Breakfast tapped"),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                    // Background color
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        // Rounded corners
                        side: const BorderSide(
                            color: Colors.black, width: 2), // Border
                      ),
                    ),
                    padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20)), // Padding
                  ),
                  child: Text("Breakfast"),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => print("Dinner tapped"),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                    // Background color
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        // Rounded corners
                        side: const BorderSide(
                            color: Colors.black, width: 2), // Border
                      ),
                    ),
                    padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20)), // Padding
                  ),
                  child: Text("Dinner"),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => print("Dessert tapped"),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                    // Background color
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        // Rounded corners
                        side: const BorderSide(
                            color: Colors.black, width: 2), // Border
                      ),
                    ),
                    padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20)), // Padding
                  ),
                  child: Text("Dessert"),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => print("Lunch tapped"),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                    // Background color
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        // Rounded corners
                        side: const BorderSide(
                            color: Colors.black, width: 2), // Border
                      ),
                    ),
                    padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20)), // Padding
                  ),
                  child: const Text("Lunch"),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _allResults.length,
              itemBuilder: (context, index) {
                return Card(
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      color: Colors.black, // Set border color
                      width: 2.0, // Set border width
                    ),
                    borderRadius: BorderRadius.circular(
                        8.0),
                  ),
                  child: ListTile(
                    leading: _allResults[index]['image_url'] != null
                        ? Image.network(
                            _allResults[index]['image_url'],
                            width: 75,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : const SizedBox(width: 50, height: 50),
                    title: Text(
                      _allResults[index]['name'],
                    ),
                    subtitle: Text(
                      _allResults[index]['description'],
                    ),
                    trailing: Text(
                      _allResults[index]['preparation_time'],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle the camera icon press action.
          print("Camera icon tapped!");
        },
        // Camera icon
        backgroundColor: Colors.white,
        // Circle color
        // The elevation helps in giving the circular shadow confirming it's rounded
        elevation: 5.0,
        child: const Icon(Icons.camera_alt),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const BottomAppBar(
        color: Colors.amber, // Amber color for the bottom bar
        shape: CircularNotchedRectangle(), // Notch for FloatingActionButton
        notchMargin: 2.0, // Margin for the notch
      ),
    );
  }
}

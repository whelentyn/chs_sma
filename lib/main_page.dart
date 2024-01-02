import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'auth/login_screen.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final List<Map<String, dynamic>> _allResults =
      []; // Declared list to hold all recipes

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
            .where('user_id', isEqualTo: FirebaseFirestore.instance.doc('Users/$userId'))
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
                print('Unexpected type in recipe_id list: ${recipeId.runtimeType}');
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
            userRecipes.add(recipeDoc.data()!); // Assuming data exists and is not null
          }
        }
        setState(() {
          _allResults.addAll(userRecipes);
        });

        print('Number of recipes retrieved: ${_allResults.length}');
      } else {
        print('No user logged in'); // Log unsuccessful operation due to no user
      }
    } catch (e) {
      print('An error occurred while retrieving user recipes: $e'); // Log any exceptions
    }
  }

  @override
  Widget build(BuildContext context) {
    String? _email = _auth.currentUser!.email;
    return Scaffold(
        appBar: AppBar(
          leading: null,
          title: const Text("Cooking App"),
        ),
        body: ListView.builder(
          itemCount: _allResults.length,
          itemBuilder: (context, index) {
            return Card(
              shape: RoundedRectangleBorder(
                side: const BorderSide(
                  color: Colors.black,  // Set border color
                  width: 2.0,  // Set border width
                ),
                borderRadius: BorderRadius.circular(8.0),  // Optional: Set border radius
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
        ));
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cooking_app/edit_profile_screen.dart';
import 'package:cooking_app/photo_screen.dart';
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
  String _selectedCategory = 'All'; // Track the selected category
  final List<String> _recipeIds = [];

  @override
  void initState() {
    super.initState();
    _getUserRecipes(); // Fetch all recipes initially
  }

  Future<void> _getUserRecipes({String category = 'All'}) async {
    try {
      String? userId = _auth.currentUser?.uid;
      _recipeIds.clear();


      if (userId != null) {
        var userRecipeDocs = await FirebaseFirestore.instance
            .collection('UserRecipes')
            .where('user_id',
                isEqualTo: FirebaseFirestore.instance.doc('Users/$userId'))
            .get();

        for (var doc in userRecipeDocs.docs) {
          var recipeIdList = doc['recipe_id'];
          if (recipeIdList is List) {
            for (var recipeId in recipeIdList) {
              if (recipeId is DocumentReference) {
                _recipeIds.add(recipeId.id);
              }
            }
          }
        }

        List<Map<String, dynamic>> userRecipes = [];
        for (var recipeId in _recipeIds) {
          var recipeDoc = await FirebaseFirestore.instance
              .collection('Recipes')
              .doc(recipeId)
              .get();

          if (recipeDoc.exists &&
              (category == 'All' ||
                  recipeDoc.data()!['category'] == category)) {
            Map<String, dynamic> recipeData = recipeDoc.data()!;
            recipeData['id'] = recipeId; // Include the recipeId
            userRecipes.add(recipeData);
          }
        }

        setState(() {
          _allResults.clear();
          _allResults.addAll(userRecipes);
        });
      } else {
        print('No user logged in');
      }
    } catch (e) {
      print('An error occurred while retrieving user recipes: $e');
    }
  }

  void _onCategoryPressed(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _getUserRecipes(category: category);
  }

  Widget _buildCategoryButton(String label) {
    return TextButton(
      onPressed: () => _onCategoryPressed(label),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
            _selectedCategory == label ? Colors.grey : Colors.white),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
            side: const BorderSide(color: Colors.black, width: 2),
          ),
        ),
        padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(vertical: 10, horizontal: 20)),
      ),
      child: Text(label),
    );
  }

  Future<void> _removeRecipeFromUser(String? recipeId) async {
    try {
      String? userId = _auth.currentUser?.uid;

      if (userId != null && recipeId != null) {
        String fullPath = recipeId.contains('/') ? recipeId : 'Recipes/$recipeId';
        print("Full path to remove: $fullPath"); // Debug

        var userRecipeQuery = await FirebaseFirestore.instance
            .collection('UserRecipes')
            .where('user_id', isEqualTo: FirebaseFirestore.instance.doc('Users/$userId'))
            .get();

        if (userRecipeQuery.docs.isNotEmpty) {
          DocumentReference userRecipesRef = userRecipeQuery.docs.first.reference;

          await userRecipesRef.update({
            'recipe_id': FieldValue.arrayRemove([FirebaseFirestore.instance.doc(fullPath)])
          });

          print("Recipe with path $fullPath should be removed from user $userId");

          _getUserRecipes(category: _selectedCategory);
        } else {
          print("No UserRecipes document found for the user: $userId");
        }
      }
    } catch (e) {
      print('An error occurred while removing the recipe: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cooking App"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const EditProfileScreen()));
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 0),
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildCategoryButton("All"),
                const SizedBox(width: 8),
                _buildCategoryButton("Breakfast"),
                const SizedBox(width: 8),
                _buildCategoryButton("Dinner"),
                const SizedBox(width: 8),
                _buildCategoryButton("Dessert"),
                const SizedBox(width: 8),
                _buildCategoryButton("Lunch"),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Favorite recipes",
              style: TextStyle(
                fontSize: 20,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _allResults.length,
              itemBuilder: (context, index) {
                var recipe = _allResults[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      color: Colors.black,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ListTile(
                    leading: recipe['image_url'] != null
                        ? Image.network(
                      recipe['image_url'],
                      width: 75,
                      height: 50,
                      fit: BoxFit.cover,
                    )
                        : const SizedBox(width: 50, height: 50),
                    title: Text(
                      recipe['name'] ?? 'Recipe Name',
                    ),
                    subtitle: Text(
                      recipe['description'] ?? 'Description',
                    ),
                    trailing: SingleChildScrollView(
                      child: Column(
                        children: [
                          Text(
                            recipe['preparation_time'] ?? 'Prep Time',
                          ),
                          IconButton(
                            icon: const Icon(Icons.favorite, color: Colors.red),
                            onPressed: () {
                              String? recipeId = recipe['id']; // Use the recipe ID directly
                              if (recipeId != null) {
                                _removeRecipeFromUser(recipeId);
                              }
                            },
                          ),
                        ],
                      ),
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
          Navigator.push<void>(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) => const PhotoScreen(),
            ),
          );
        },
        backgroundColor: Colors.white,
        elevation: 5.0,
        child: const Icon(Icons.camera_alt),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const BottomAppBar(
        color: Colors.amber,
        shape: CircularNotchedRectangle(),
        notchMargin: 2.0,
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cooking_app/main_user/edit_profile_screen.dart';
import 'package:cooking_app/recipe_handler/photo_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../auth/login_screen.dart';

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
            _selectedCategory == label ? Colors.grey : Color(0xAAD9D9D9)),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.5),
            side: BorderSide.none,
          ),
        ),
        padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(vertical: 10, horizontal: 20)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.black, // Change this color to your desired text color
        ),
      ),
    );
  }

  Future<void> _removeRecipeFromUser(String? recipeId) async {
    try {
      String? userId = _auth.currentUser?.uid;

      if (userId != null && recipeId != null) {
        String fullPath =
            recipeId.contains('/') ? recipeId : 'Recipes/$recipeId';
        print("Full path to remove: $fullPath"); // Debug

        var userRecipeQuery = await FirebaseFirestore.instance
            .collection('UserRecipes')
            .where('user_id',
                isEqualTo: FirebaseFirestore.instance.doc('Users/$userId'))
            .get();

        if (userRecipeQuery.docs.isNotEmpty) {
          DocumentReference userRecipesRef =
              userRecipeQuery.docs.first.reference;

          await userRecipesRef.update({
            'recipe_id': FieldValue.arrayRemove(
                [FirebaseFirestore.instance.doc(fullPath)])
          });

          print(
              "Recipe with path $fullPath should be removed from user $userId");

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
        title: Text(
          "Food\nCam",
          style: GoogleFonts.lexendMega(
              fontWeight: FontWeight.bold,
              fontSize: 22.0,
              height: 0.8,
              color: Color(0xFF545454)),
        ),
        leading: Padding(
            padding: EdgeInsets.only(left: 15.0),
            child: Image.asset(
              'assets/logoFoodCam.png',
              width: 50,
              height: 50,
            )),
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
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 5),
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
            padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 5),
            child: Text(
              "Favorite recipes",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: _allResults.length,
                itemBuilder: (context, index) {
                  var recipe = _allResults[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        side: BorderSide.none,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20.0),
                                      topRight: Radius.circular(20.0)),
                                  child: Container(
                                    height: 150,
                                    child: recipe['image_url'] != null
                                        ? Image.network(
                                            recipe['image_url'],
                                            fit: BoxFit.cover,
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                ),
                                ListTile(
                                  title: Text(
                                    recipe['name'] ?? 'Recipe Name',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    recipe['description'] ?? 'Description',
                                  ),
                                  trailing: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        recipe['preparation_time'] ?? 'Prep Time',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Positioned(
                              bottom: 0.0,
                              right: 18.0,
                              child: IconButton(
                                icon:
                                    const Icon(Icons.favorite, color: Colors.brown),
                                onPressed: () {
                                  String? recipeId =
                                      recipe['id'];
                                  if (recipeId != null) {
                                    _removeRecipeFromUser(recipeId);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        height: 70.0,
        width: 70.0,
        child: FittedBox(
          child: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const PhotoScreen()));
            },
            backgroundColor: Color(0xFFC3C1C1),
            elevation: 8.0,
            shape: const CircleBorder(
              side: BorderSide.none,
            ),
            child: Image.asset(
              'assets/camIcon.png',
              width: 35,
              height: 35,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const BottomAppBar(
        color: Color(0xFFD9D9D9),
        height: 60.0,
        shape: null,
      ),
    );
  }
}

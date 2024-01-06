import 'package:cooking_app/recipe_handler/recipe_displayer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final FirebaseAuth _auth = FirebaseAuth.instance;
Set<String> _favoritedRecipes = <String>{};


class IngredientSearchScreen extends StatefulWidget {
  final List<String> ingredientNames;

  const IngredientSearchScreen({super.key, required this.ingredientNames});

  @override
  _IngredientSearchScreenState createState() => _IngredientSearchScreenState();
}

class _IngredientSearchScreenState extends State<IngredientSearchScreen> with WidgetsBindingObserver{
  late List<Map<String, dynamic>> _recipes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _favoritedRecipes.clear();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _fetchInitialData() {
    _fetchUserFavorites();
    _searchRecipes();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchInitialData();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchInitialData();
  }

  Future<void> _fetchUserFavorites() async {
    String? userId = _auth.currentUser?.uid;

    if (userId != null) {
      QuerySnapshot userDocSnapshot = await _firestore
          .collection('UserRecipes')
          .where('user_id', isEqualTo: _firestore.doc('Users/$userId'))
          .get();

      if (userDocSnapshot.docs.isNotEmpty) {
        var userRecipes = userDocSnapshot.docs.first.data() as Map<String, dynamic>?;
        var recipeRefs = userRecipes?['recipe_id'] as List<dynamic>;

        for (var ref in recipeRefs) {
          if (ref is DocumentReference) {
            setState(() {
              _favoritedRecipes.add(ref.id);
            });
          }
        }
      }
    }
  }

  Future<void> _searchRecipes() async {
    try {
      Set<String> ingredientIds = await _getIngredientIds(widget.ingredientNames);

      List<Map<String, dynamic>> matchingRecipes = await _findMatchingRecipes(ingredientIds);

      setState(() {
        _recipes = matchingRecipes;
        _isLoading = false;
      });
    } catch (e) {
      print("An error occurred: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Set<String>> _getIngredientIds(List<String> ingredientNames) async {
    Set<String> ids = {};

    for (String name in ingredientNames) {
      var querySnapshot = await _firestore.collection('Ingredients').where('name', isEqualTo: name).get();
      for (var doc in querySnapshot.docs) {
        ids.add(doc.reference.id);
      }
    }

    return ids;
  }

  Future<List<Map<String, dynamic>>> _findMatchingRecipes(Set<String> ingredientIds) async {
    List<Map<String, dynamic>> matchingRecipes = [];

    var querySnapshot = await _firestore.collection('Recipes').get();

    for (var recipeDoc in querySnapshot.docs) {
      var recipeData = recipeDoc.data();
      var recipeIngredientRefs = recipeData['ingredients'] as List<dynamic>;
      int matchCount = 0;

      for (var refPath in recipeIngredientRefs) {
        if (refPath is String) {
          String? id = refPath.split('/').last;
          if (id != null && ingredientIds.contains(id)) {
            matchCount++;
          }
        } else if (refPath is DocumentReference) {
          if (ingredientIds.contains(refPath.id)) {
            matchCount++;
          }
        }
      }

      if (matchCount >= 2) {
        Map<String, dynamic> recipeDetails = recipeDoc.data()!;
        recipeDetails['id'] = recipeDoc.id;
        matchingRecipes.add(recipeDetails);
      }
    }

    return matchingRecipes;
  }

  Future<void> _toggleFavorite(String recipeId) async {
    try {
      String? userId = _auth.currentUser?.uid;
      DocumentReference recipeRef = FirebaseFirestore.instance.doc('Recipes/$recipeId');

      if (userId != null && recipeId.isNotEmpty) {
        QuerySnapshot userDocSnapshot = await FirebaseFirestore.instance
            .collection('UserRecipes')
            .where('user_id', isEqualTo: FirebaseFirestore.instance.doc('Users/$userId'))
            .get();

        if (userDocSnapshot.docs.isNotEmpty) {
          DocumentReference userDocRef = userDocSnapshot.docs.first.reference;
          if (_favoritedRecipes.contains(recipeId)) {
            await userDocRef.update({
              'recipe_id': FieldValue.arrayRemove([recipeRef]),
            });

            setState(() {
              _favoritedRecipes.remove(recipeId);
            });
          } else {
            await userDocRef.update({
              'recipe_id': FieldValue.arrayUnion([recipeRef]),
            });

            setState(() {
              _favoritedRecipes.add(recipeId);
            });
          }

          print("Toggled favorite status for recipe with ID $recipeId for user $userId.");
        } else {
          DocumentReference newUserDocRef = FirebaseFirestore.instance.collection('UserRecipes').doc();
          await newUserDocRef.set({
            'user_id': FirebaseFirestore.instance.doc('Users/$userId'),
            'recipe_id': [_favoritedRecipes.contains(recipeId) ? FieldValue.arrayRemove([recipeRef]) : FieldValue.arrayUnion([recipeRef])],
          });

          setState(() {
            if (_favoritedRecipes.contains(recipeId)) {
              _favoritedRecipes.remove(recipeId);
            } else {
              _favoritedRecipes.add(recipeId);
            }
          });

          print("Created UserRecipes document and toggled favorite status for recipe with ID $recipeId for user $userId.");
        }
      }
    } catch (e) {
      print('An error occurred while toggling recipe favorite status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Recipes with Your Ingredients'),
        ),
        body: Expanded(
          child: ListView.builder(
            itemCount: _recipes.length,
            itemBuilder: (context, index) {
              var recipe = _recipes[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecipeDisplayer(recipeId: recipe['id']),
                    ),
                  );
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    side: BorderSide.none,
                    borderRadius: BorderRadius.circular(25.5),
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
                                  topLeft: Radius.circular(25.5),
                                  topRight: Radius.circular(25.5)),
                              child: Container(
                                height: 100,
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
                                "${recipe['description'] ?? 'Description'}\nPrep time: ${recipe['preparation_time'] ?? 'N/A'}\nRating: ${recipe['rating'] ?? 'N/A'}",
                              ),
                              isThreeLine: true,
                            ),
                          ],
                        ),
                        Positioned(
                          bottom: 0.0,
                          right: 18.0,
                          child: IconButton(
                            icon: Icon(
                              _favoritedRecipes.contains(recipe['id']) ? Icons.favorite : Icons.favorite_border_outlined,
                              color: _favoritedRecipes.contains(recipe['id']) ? Colors.brown : null,
                            ),
                            onPressed: () {
                              _toggleFavorite(recipe['id']);
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
      );
    }
  }
}
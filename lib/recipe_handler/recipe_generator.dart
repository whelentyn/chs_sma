import 'package:cooking_app/recipe_handler/recipe_displayer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

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
          title: Text(
            "Food\nCam",
            style: GoogleFonts.lexendMega(
                fontWeight: FontWeight.bold,
                fontSize: 22.0,
                height: 0.8,
                color: Color(0xFF545454)),
          ),
          leading: Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Image.asset(
                'assets/logoFoodCam.png',
                width: 50,
                height: 50,
              )),
        ),
        body: Column(
          children: [
            SizedBox(height: 8.0),
            Container(
              padding: const EdgeInsets.only(left: 8.0),
              alignment: Alignment.topLeft,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Recipes with your ingredients",
                  style: TextStyle(color: Color(0xFF545454),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
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
                                      "${recipe['description'] ?? 'Description'}\nRating: ${recipe['rating'] ?? 'N/A'}",
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
            ),
          ],
        ),
      );
    }
  }
}
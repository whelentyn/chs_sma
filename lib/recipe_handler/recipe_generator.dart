import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class IngredientSearchScreen extends StatefulWidget {
  final List<String> ingredientNames;

  const IngredientSearchScreen({super.key, required this.ingredientNames});

  @override
  _IngredientSearchScreenState createState() => _IngredientSearchScreenState();
}

class _IngredientSearchScreenState extends State<IngredientSearchScreen> {
  late List<Map<String, dynamic>> _recipes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchRecipes();
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
      var recipeIngredientRefs = recipeData['ingredients'] as List<dynamic>; // Assuming this is the correct field name
      int matchCount = 0;

      // Check if the references are stored as strings (paths) and not as DocumentReference objects
      for (var refPath in recipeIngredientRefs) {
        if (refPath is String) {
          String? id = refPath.split('/').last;
          if (id != null && ingredientIds.contains(id)) {
            matchCount++;
          }
        } else if (refPath is DocumentReference) {
          // If it's a DocumentReference, you can directly access the ID
          if (ingredientIds.contains(refPath.id)) {
            matchCount++;
          }
        }
      }

      if (matchCount >= 2) {
        Map<String, dynamic> recipeDetails = recipeDoc.data()!;
        recipeDetails['id'] = recipeDoc.id; // Include the recipeId
        matchingRecipes.add(recipeDetails);
      }
    }

    return matchingRecipes;
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
        body: ListView.builder(
          itemCount: _recipes.length,
          itemBuilder: (context, index) {
            var recipe = _recipes[index];
            return ListTile(
              title: Text(recipe['name'] ?? 'Unnamed Recipe'),
            );
          },
        ),
      );
    }
  }
}
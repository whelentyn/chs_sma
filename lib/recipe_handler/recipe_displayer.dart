import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeDisplayer extends StatefulWidget {
  final String recipeId;

  const RecipeDisplayer({Key? key, required this.recipeId}) : super(key: key);

  @override
  _RecipeDisplayerState createState() => _RecipeDisplayerState();
}

class _RecipeDisplayerState extends State<RecipeDisplayer> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _recipeData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecipeData();
  }

  Future<void> _fetchRecipeData() async {
    try {
      DocumentSnapshot recipeSnapshot = await _firestore.collection('Recipes').doc(widget.recipeId).get();
      Map<String, dynamic>? recipeData = recipeSnapshot.data() as Map<String, dynamic>?;

      if (recipeData != null) {
        List<dynamic> ingredientRefs = recipeData['ingredients'] ?? [];
        List<String> ingredientNames = [];

        for (var ref in ingredientRefs) {
          if (ref is DocumentReference) {
            DocumentSnapshot ingredientSnapshot = await ref.get();
            Map<String, dynamic>? ingredientData = ingredientSnapshot.data() as Map<String, dynamic>?;
            if (ingredientData != null && ingredientData.containsKey('name')) {
              ingredientNames.add(ingredientData['name']);
            }
          }
        }

        setState(() {
          _recipeData = recipeData;
          _recipeData?['ingredients'] = ingredientNames;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("An error occurred while fetching recipe data: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_recipeData == null) {
      return Scaffold(
        body: Center(child: Text("Recipe not found")),
      );
    }

    List<dynamic> steps = _recipeData?['steps'] ?? [];
    return Scaffold(
      appBar: AppBar(
        title: Text(_recipeData?['name'] ?? 'Recipe'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _recipeData?['image_url'] != null
                ? Image.network(_recipeData!['image_url'])
                : const SizedBox(height: 200, child: Center(child: Text('No image available'))),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Category: ${_recipeData?['category'] ?? 'N/A'}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text("Description: ${_recipeData?['description'] ?? 'N/A'}"),
                  Text("Preparation Time: ${_recipeData?['preparation_time'] ?? 'N/A'}"),
                  Text("Rating: ${_recipeData?['rating'] ?? 'N/A'}"),
                  const Text("Ingredients:", style: TextStyle(fontWeight: FontWeight.bold)),
                  ...(_recipeData?['ingredients'] ?? []).map<Widget>((ingredient) => Text("• $ingredient")).toList(),
                  SizedBox(height: 10),
                  const Text("Steps:", style: TextStyle(fontWeight: FontWeight.bold)),
                  ...steps.map<Widget>((step) => Text("• $step")).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
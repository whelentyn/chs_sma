import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main_user/main_page.dart';

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
      DocumentSnapshot recipeSnapshot =
          await _firestore.collection('Recipes').doc(widget.recipeId).get();
      Map<String, dynamic>? recipeData =
          recipeSnapshot.data() as Map<String, dynamic>?;

      if (recipeData != null) {
        List<dynamic> ingredientRefs = recipeData['ingredients'] ?? [];
        List<String> ingredientNames = [];

        for (var ref in ingredientRefs) {
          if (ref is DocumentReference) {
            DocumentSnapshot ingredientSnapshot = await ref.get();
            Map<String, dynamic>? ingredientData =
                ingredientSnapshot.data() as Map<String, dynamic>?;
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_recipeData == null) {
      return const Scaffold(
        body: Center(child: Text("Recipe not found")),
      );
    }

    List<dynamic> steps = _recipeData?['steps'] ?? [];
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MainPage()),
            );
          },
          child: Text(
            "Food\nCam",
            style: GoogleFonts.lexendMega(
                fontWeight: FontWeight.bold,
                fontSize: 22.0,
                height: 0.8,
                color: Color(0xFF545454)),
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 15.0),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MainPage()),
              );
            },
            child: Image.asset(
              'assets/logoFoodCam.png',
              width: 50,
              height: 50,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Container(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                alignment: Alignment.center,
                child: _recipeData?['image_url'] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Container(
                          height: 200,
                          width: MediaQuery.of(context).size.width,
                          child: Image.network(
                            _recipeData!['image_url'],
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : const SizedBox(
                        height: 200,
                        child: Center(child: Text('No image available')),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${_recipeData?['name'] ?? 'N/A'}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 30)),
                  Text("${_recipeData?['category'] ?? 'N/A'}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                  Text("${_recipeData?['description'] ?? 'N/A'}",
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text("Preparation Time: ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      Text("${_recipeData?['preparation_time'] ?? 'N/A'}",
                          style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text("Rating: ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      Text("${_recipeData?['rating'] ?? 'N/A'}",
                          style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text("Ingredients:",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ...(_recipeData?['ingredients'] ?? [])
                      .map<Widget>((ingredient) => Text("• $ingredient"))
                      .toList(),
                  const SizedBox(height: 10),
                  const Text("Steps:",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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

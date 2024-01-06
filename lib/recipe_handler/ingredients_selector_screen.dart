import 'package:cooking_app/recipe_handler/recipe_generator.dart'; // Ensure this path is correct
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IngredientsPage extends StatefulWidget {
  @override
  _IngredientsPageState createState() => _IngredientsPageState();
}

class _IngredientsPageState extends State<IngredientsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _ingredients = [];
  Set<int> _selectedIndices = Set();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _fetchIngredients();
  }

  Future<void> _fetchIngredients() async {
    try {
      var ingredientsCollection = await _firestore.collection('Ingredients').get();
      var ingredients = ingredientsCollection.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      setState(() {
        _ingredients = ingredients;
      });
    } catch (e) {
      print("An error occurred while retrieving ingredients: $e");
    }
  }

  void _handleIngredientTap(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  List<Map<String, dynamic>> _getFilteredIngredients() {
    var filteredIngredients = _ingredients.where((ingredient) {
      return ingredient['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    List<int> sortedIndices = List.generate(filteredIngredients.length, (index) => index);
    sortedIndices.sort((a, b) {
      bool aSelected = _selectedIndices.contains(_ingredients.indexOf(filteredIngredients[a]));
      bool bSelected = _selectedIndices.contains(_ingredients.indexOf(filteredIngredients[b]));
      if (aSelected && !bSelected) return -1;
      if (!aSelected && bSelected) return 1;
      return a.compareTo(b);
    });

    return sortedIndices.map((index) => filteredIngredients[index]).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> displayIngredients = _getFilteredIngredients();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: "Search Ingredients",
            hintStyle: TextStyle(color: Colors.black),
          ),
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 3 / 4,
        ),
        itemCount: displayIngredients.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> ingredient = displayIngredients[index];
          bool isSelected = _selectedIndices.contains(_ingredients.indexOf(ingredient));
          return Card(
            shape: RoundedRectangleBorder(
              side: BorderSide.none,
              borderRadius: BorderRadius.circular(15),
            ),
            color: isSelected ? Colors.grey : Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    child: Container(
                      child: ingredient['image_url'] != null
                          ? Image.network(
                        ingredient['image_url'],
                        fit: BoxFit.cover,
                      )
                          : const SizedBox.shrink(),
                    ),
                  ),
                ),
                ListTile(
                  title: Text(
                    ingredient['name'] ?? 'Unnamed Ingredient',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => _handleIngredientTap(_ingredients.indexOf(ingredient)),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Container(
        height: 70.0,
        width: 70.0,
        child: FittedBox(
          child: FloatingActionButton(
            onPressed: () {
              List<String> selectedIngredientNames = _selectedIndices.map((index) => _ingredients[index]['name'] as String).toList();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => IngredientSearchScreen(ingredientNames: selectedIngredientNames),
                  maintainState: false,
                ),
              );
            },
            backgroundColor: Color(0xFFC3C1C1),
            elevation: 8.0,
            shape: const CircleBorder(
              side: BorderSide.none,
            ),
            child: const Icon(Icons.auto_awesome_mosaic,
              size: 35,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const BottomAppBar(
        color: Color(0xFFD9D9D9),
        height: 60.0,
        shape: CircularNotchedRectangle(),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
      ),
    );
  }
}
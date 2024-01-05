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

    // Sort the filtered list to bring selected items to the top
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
          crossAxisCount: 3, // Three items per row
          childAspectRatio: 3 / 4, // Adjust the ratio based on your item's content
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
            color: isSelected ? Colors.lightBlueAccent : Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
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
    );
  }
}
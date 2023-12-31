import 'package:cooking_app/recipe_handler/recipe_generator.dart'; // Ensure this path is correct
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class IngredientsPage extends StatefulWidget {
  final List<String> preselectedIngredients;

  IngredientsPage({super.key, required this.preselectedIngredients});
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
      var ingredientsCollection =
          await _firestore.collection('Ingredients').get();
      var ingredients = ingredientsCollection.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      setState(() {
        _ingredients = ingredients;

        if (widget.preselectedIngredients.isNotEmpty) {
          Set<String> lowercasePreselected = widget.preselectedIngredients.map((e) => e.toLowerCase()).toSet();
          for (int i = 0; i < _ingredients.length; i++) {
            String ingredientName = _ingredients[i]['name'].toString().toLowerCase();
            if (lowercasePreselected.contains(ingredientName)) {
              _selectedIndices.add(i);
            }
          }
        }
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
      return ingredient['name']
          .toString()
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
    }).toList();

    List<int> sortedIndices =
        List.generate(filteredIngredients.length, (index) => index);
    sortedIndices.sort((a, b) {
      bool aSelected = _selectedIndices
          .contains(_ingredients.indexOf(filteredIngredients[a]));
      bool bSelected = _selectedIndices
          .contains(_ingredients.indexOf(filteredIngredients[b]));
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintStyle: const TextStyle(color: Color(0XAA7A7A7A)),
                hintText: " Search ingredients",
                border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(30),),
                filled: true,
                fillColor: Color(0xAAD9D9D9),
              ),
              style: TextStyle(color: Colors.black),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 3 / 4,
                ),
                itemCount: displayIngredients.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> ingredient = displayIngredients[index];
                  bool isSelected =
                      _selectedIndices.contains(_ingredients.indexOf(ingredient));
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
                          onTap: () => _handleIngredientTap(
                              _ingredients.indexOf(ingredient)),
                        ),
                      ],
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
              List<String> selectedIngredientNames = _selectedIndices
                  .map((index) => _ingredients[index]['name'] as String)
                  .toList();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => IngredientSearchScreen(
                      ingredientNames: selectedIngredientNames),
                  maintainState: false,
                ),
              );
            },
            backgroundColor: Color(0xFFC3C1C1),
            elevation: 8.0,
            shape: const CircleBorder(
              side: BorderSide.none,
            ),
            child: const Icon(
              Icons.navigate_next,
              size: 45,
              color: Color(0xFF545454),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const BottomAppBar(
        color: Color(0xFFD9D9D9),
        height: 60.0,
        shape: null,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
      ),
    );
  }
}

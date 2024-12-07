import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:meals/provider/favorite_provider.dart';
import 'package:meals/provider/filter_provider.dart';
import 'package:meals/provider/meals_provider.dart';
import 'package:meals/screens/categories.dart';
import 'package:meals/screens/filters.dart';
import 'package:meals/screens/meals.dart';
import 'package:meals/widgets/main_drawer.dart';

const kInitialFilters = {
  Filter.glutenFree: false,
  Filter.lactoseFree: false,
  Filter.vegetarian: false,
  Filter.vegan: false,
};

class TabsScreen extends ConsumerStatefulWidget {
  const TabsScreen({
    super.key,
  });

  @override
  ConsumerState<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends ConsumerState<TabsScreen> {
  var _selectedIndex = 0;

  void _selectedPage(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _setScreen(String identifier) async {
    Navigator.pop(context);
    if (identifier == 'filters') {
      await Navigator.push<Map<Filter, bool>>(
        context,
        MaterialPageRoute(
          builder: (ctx) => const FiltersScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final meals = ref.watch(mealsProvider);
    final activedFilters = ref.watch(filtersProvider);
    final availableMeals = meals.where((meal) {
      if (activedFilters[Filter.glutenFree]! && !meal.isGlutenFree) {
        return false;
      }
      if (activedFilters[Filter.lactoseFree]! && !meal.isLactoseFree) {
        return false;
      }
      if (activedFilters[Filter.vegetarian]! && !meal.isVegetarian) {
        return false;
      }
      if (activedFilters[Filter.vegan]! && !meal.isVegan) {
        return false;
      }
      return true;
    }).toList();

    final favoriteMeals = ref.watch(favoriteMealsProvider);
    final List<Widget> screens = [
      CategoriesScreen(
        availableMeals: availableMeals,
      ),
      MealsScreen(
        meals: favoriteMeals,
      ),
    ];
    var title = const Text('Categories');
    if (_selectedIndex == 1) {
      title = const Text('Your favorite');
    }
    return Scaffold(
      appBar: AppBar(
        title: title,
      ),
      drawer: MainDrawer(
        onSelectScreen: _setScreen,
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectedPage,
        currentIndex: _selectedIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.set_meal),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Favorite',
          ),
        ],
      ),
    );
  }
}

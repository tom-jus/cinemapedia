import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  const CustomBottomNavigation({super.key, required this.currentIndex});

  void onItemTapped(BuildContext context, int currentIndex) {
    switch (currentIndex) {
      case 0:
        context.go('/home/$currentIndex');
        break;
      case 1:
        context.go('/home/$currentIndex');
        break;
      case 2:
        context.go('/home/$currentIndex');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return BottomNavigationBar(
        // el valor de value es el indice de cada boton, en este caso son 0, 1 y 2
        currentIndex: currentIndex,
        onTap: (value) => onItemTapped(context, value),
        selectedItemColor: colors.primary,
        items: const [
          // Debe tener si o si 2 items con sus label
          BottomNavigationBarItem(icon: Icon(Icons.home_max), label: 'Inicio'),
          BottomNavigationBarItem(
              icon: Icon(Icons.thumbs_up_down_outlined), label: 'Populares'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outline), label: 'Favoritos'),
        ]);
  }
}

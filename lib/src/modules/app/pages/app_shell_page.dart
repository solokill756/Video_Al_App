import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../../../common/components/app_bottom_navigation_bar.dart';

@RoutePage()
class AppShellPage extends StatefulWidget {
  const AppShellPage({super.key});

  @override
  State<AppShellPage> createState() => _AppShellPageState();
}

class _AppShellPageState extends State<AppShellPage> {
  BottomNavItem _selectedItem = BottomNavItem.home;

  void _onItemSelected(BottomNavItem item) {
    setState(() {
      _selectedItem = item;
    });

    switch (item) {
      case BottomNavItem.home:
        context.router.replaceNamed('');
        break;
      case BottomNavItem.explore:
        // TODO: Implement explore page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Explore page coming soon')),
        );
        break;
      case BottomNavItem.upload:
        context.router.replaceNamed('upload');
        break;
      case BottomNavItem.settings:
        context.router.replaceNamed('settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AutoRouter(),
      bottomNavigationBar: AppBottomNavigationBar(
        currentItem: _selectedItem,
        onItemSelected: _onItemSelected,
      ),
    );
  }
}

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateSelectedItem();
  }

  void _updateSelectedItem() {
    final routeName = context.router.current.name;
    BottomNavItem newItem;

    if (routeName.isEmpty || routeName == 'VideoSearchHomeRoute') {
      newItem = BottomNavItem.home;
    } else if (routeName == 'AITutorChatRoute') {
      newItem = BottomNavItem.aiTutor;
    } else if (routeName == 'UploadVideoRoute') {
      newItem = BottomNavItem.upload;
    } else if (routeName == 'SettingsRoute') {
      newItem = BottomNavItem.settings;
    } else {
      newItem = _selectedItem; // Keep current if unknown route
    }

    if (newItem != _selectedItem) {
      setState(() {
        _selectedItem = newItem;
      });
    }
  }

  void _onItemSelected(BottomNavItem item) {
    setState(() {
      _selectedItem = item;
    });

    switch (item) {
      case BottomNavItem.home:
        context.router.replaceNamed('');
        break;
      case BottomNavItem.aiTutor:
        context.router.replaceNamed('ai-tutor-chat');
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

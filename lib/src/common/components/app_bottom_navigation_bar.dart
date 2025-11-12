import 'package:flutter/material.dart';

enum BottomNavItem {
  home,
  explore,
  upload,
  settings,
}

class AppBottomNavigationBar extends StatefulWidget {
  final BottomNavItem currentItem;
  final ValueChanged<BottomNavItem> onItemSelected;

  const AppBottomNavigationBar({
    super.key,
    required this.currentItem,
    required this.onItemSelected,
  });

  @override
  State<AppBottomNavigationBar> createState() => _AppBottomNavigationBarState();
}

class _AppBottomNavigationBarState extends State<AppBottomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                item: BottomNavItem.home,
              ),
              _buildNavItem(
                icon: Icons.explore_rounded,
                label: 'Explore',
                item: BottomNavItem.explore,
              ),
              _buildNavItem(
                icon: Icons.add_circle_outline_rounded,
                label: 'Upload',
                item: BottomNavItem.upload,
                isCenter: true,
              ),
              _buildNavItem(
                icon: Icons.settings,
                label: 'Settings',
                item: BottomNavItem.settings,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required BottomNavItem item,
    bool isCenter = false,
  }) {
    final isSelected = widget.currentItem == item;

    if (isCenter) {
      return GestureDetector(
        onTap: () => widget.onItemSelected(item),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isSelected ? 60 : 56,
          height: isSelected ? 60 : 56,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0D9488) : Colors.grey[200],
            shape: BoxShape.circle,
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: const Color(0xFF0D9488).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Icon(
            Icons.add_rounded,
            color: isSelected ? Colors.white : Colors.grey[600],
            size: 28,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => widget.onItemSelected(item),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0D9488).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF0D9488) : Colors.grey[500],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? const Color(0xFF0D9488) : Colors.grey[500],
              ),
            ),
            if (isSelected)
              Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

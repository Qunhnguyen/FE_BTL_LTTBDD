import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final bool isStudent;

  const MainShell({
    super.key,
    required this.navigationShell,
    required this.isStudent,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: isStudent ? _buildStudentNav(context) : _buildTeacherNav(context),
      floatingActionButton: !isStudent ? _buildTeacherFAB(context) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildStudentNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: navigationShell.currentIndex,
      onTap: (index) => navigationShell.goBranch(index),
      type: BottomNavigationBarType.fixed,
      selectedFontSize: 10,
      unselectedFontSize: 10,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Trang chủ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'Lịch sử',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.emoji_events_outlined),
          activeIcon: Icon(Icons.emoji_events),
          label: 'Xếp hạng',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Cá nhân',
        ),
      ],
    );
  }

  Widget _buildTeacherNav(BuildContext context) {
    return BottomAppBar(
      notchMargin: 8,
      shape: const CircularNotchedRectangle(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavIcon(
            icon: Icons.home,
            label: 'Tổng quan',
            isSelected: navigationShell.currentIndex == 0,
            onTap: () => navigationShell.goBranch(0),
          ),
          _NavIcon(
            icon: Icons.menu_book,
            label: 'Môn học',
            isSelected: navigationShell.currentIndex == 1,
            onTap: () => navigationShell.goBranch(1),
          ),
          const SizedBox(width: 48), // Space for FAB
          _NavIcon(
            icon: Icons.help_outline,
            label: 'Câu hỏi',
            isSelected: navigationShell.currentIndex == 2,
            onTap: () => navigationShell.goBranch(2),
          ),
          _NavIcon(
            icon: Icons.settings,
            label: 'Cài đặt',
            isSelected: navigationShell.currentIndex == 3,
            onTap: () => navigationShell.goBranch(3),
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherFAB(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {},
      backgroundColor: Theme.of(context).colorScheme.primary,
      shape: const CircleBorder(),
      child: const Icon(Icons.add, color: Colors.white, size: 32),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavIcon({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? Theme.of(context).colorScheme.primary : Colors.grey;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

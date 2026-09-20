import 'package:flutter/material.dart';
import 'package:tvp_player/platforms/mobile/mobile_home_page.dart';
import 'package:tvp_player/platforms/pages/more_page.dart';
import 'package:tvp_player/platforms/pages/vf_search_page.dart';

class DesktopHomeScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<DesktopHomeScreen> createState() => _DesktopHomeScreenState();
}

class _DesktopHomeScreenState extends State<DesktopHomeScreen> {
  int index = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: index,
            onDestinationSelected: (value) {
              setState(() {
                index = value;
              });
            },
            destinations: [
              .new(icon: Icon(Icons.home_outlined), label: Text('Home')),
              .new(icon: Icon(Icons.search_outlined), label: Text('Search')),
              .new(icon: Icon(Icons.grid_view_outlined), label: Text('More')),
            ],
          ),
          VerticalDivider(),
          Expanded(
            child: IndexedStack(
              index: index,
              children: [MobileHomePage(), VfSearchPage(), MorePage()],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  BottomNavBar({GlobalKey key, this.selectedIndex, this.onItemTapped})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => new BottomNavBarState();
}

class BottomNavBarState extends State<BottomNavBar> {
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  final Color backgroundColor = HexColor("#2d4052");
  final Color selectedItemColor = HexColor("#ffb84d");

  void _onItemTapped(int index) {
    if (index == 2) return;

    widget.onItemTapped(index);
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: backgroundColor,
      currentIndex: widget.selectedIndex,
      selectedItemColor: selectedItemColor,
      unselectedItemColor: Colors.white,
      onTap: _onItemTapped,
      items: [
        new BottomNavigationBarItem(
          icon: Icon(Icons.home),
          title: Text('3Bot'),
        ),
        new BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet),
          title: Text('Pay'),
        ),
        new BottomNavigationBarItem(
            backgroundColor: Colors.grey,
            icon: Icon(
              Icons.supervised_user_circle,
              color: Colors.grey,
            ),
            title: new RichText(
              text: new TextSpan(
                children: <TextSpan>[
                  new TextSpan(
                    text: "Circles",
                    style: new TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )),
        new BottomNavigationBarItem(
            icon: Icon(Icons.people), title: Text('Social')),
        new BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz), title: Text('More'))
      ],
    );
  }
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

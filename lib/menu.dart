import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tfg_app/globals.dart';

class Menu extends StatelessWidget {
  final Widget body;
  final String title;

  const Menu({Key? key, required this.body, required this.title}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
              decoration: BoxDecoration(
                color: Colors.deepPurple,
              ),
            ),
            ListTile(
              title: const Text('Device'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
            ListTile(
              title: const Text('Disconnect'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/login');
                isLoggedin = false;
              },
            ),
          ],
        ),
      ),
      body: body,
    );
  }
}


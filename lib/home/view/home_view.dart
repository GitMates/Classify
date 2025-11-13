import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/home_controller.dart'; 
// You might need to import your AuthView for the logout button
// import 'package:YOUR_PROJECT_NAME/auth/view/auth_view.dart';
// You might also need to get your AuthController for logout logic

class HomeView extends StatelessWidget {
  HomeView({Key? key}) : super(key: key);

  // This list holds the main content for each tab
  final List<Widget> _widgetOptions = <Widget>[
    // Home Content
    const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home, size: 100, color: Colors.blueAccent),
          Text('Home', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
          Text('Welcome to your application!', style: TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    ),
    // Search Content
    const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 100, color: Colors.orangeAccent),
          Text('Search', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
        ],
      ),
    ),
    // Profile Content
    const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, size: 100, color: Colors.greenAccent),
          Text('Profile', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
        ],
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // We wrap the view in a ChangeNotifierProvider to create
    // and provide the HomeController to the widget tree.
    return ChangeNotifierProvider(
      create: (_) => HomeController(),
      child: Consumer<HomeController>(
        builder: (context, controller, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Home Page'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_none),
                  onPressed: () {
                    // Add notification logic
                  },
                ),
              ],
            ),
            // Side menu (Drawer)
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  const UserAccountsDrawerHeader(
                    accountName: Text("User Name"), // TODO: Get user data
                    accountEmail: Text("user.email@example.com"), // TODO: Get user data
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Text(
                        "U",
                        style: TextStyle(fontSize: 40.0),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Settings'),
                    onTap: () {
                      Navigator.pop(context); // Closes the drawer
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Logout'),
                    onTap: () {
                      // TODO: Implement logout
                      // 1. You'll need to call a signOut method on your AuthController
                      // 2. Then navigate back to the AuthView
                      // Example (after adding a signOut method to AuthController):
                      // await authController.signOut();
                      // Navigator.of(context).pushAndRemoveUntil(
                      //   MaterialPageRoute(builder: (context) => const AuthView()),
                      //   (Route<dynamic> route) => false,
                      // );
                    },
                  ),
                ],
              ),
            ),
            // Main content
            body: _widgetOptions.elementAt(controller.selectedIndex),
            // Bottom navigation bar
            bottomNavigationBar: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
              currentIndex: controller.selectedIndex,
              selectedItemColor: Colors.blueAccent,
              onTap: controller.onItemTapped,
            ),
          );
        },
      ),
    );
  }
}
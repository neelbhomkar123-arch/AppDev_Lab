import 'package:flutter/material.dart';


void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navigation Demo',
      .
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MainNavigator(),
    );
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _selectedIndex = 0;

  
  static const List<Widget> _pages = <Widget>[
    HomePage(),
    FeedPage(),
    ProfilePage(),
  ];

  
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
      appBar: AppBar(
        title: const Text('Flutter Navigation'),
        elevation: 4.0, 
      ),
      
      
      drawer: Drawer(
        child: ListView(
          /.
          padding: EdgeInsets.zero,
          children: [
            
            const UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Colors.indigo,
              ),
              accountName: Text(
                "Neel",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              accountEmail: Text(
                "neel@gmail.com",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: FlutterLogo(size: 42.0),
              ),
            ),
            
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              
              selected: _selectedIndex == 0,
              onTap: () {
                
                _onItemTapped(0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.rss_feed),
              title: const Text('Feed'),
              selected: _selectedIndex == 1,
              onTap: () {
                
                _onItemTapped(1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              selected: _selectedIndex == 2,
              onTap: () {
                
                _onItemTapped(2);
              },
            ),
            const Divider(), 
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      
      
      body: Center(
        child: _pages.elementAt(_selectedIndex),
      ),
      
      
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rss_feed),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
       
        currentIndex: _selectedIndex,
       
        selectedItemColor: Colors.indigo,
       
        onTap: (index) {
         
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home, size: 80, color: Colors.indigo),
          SizedBox(height: 20),
          Text('Home Page', style: TextStyle(fontSize: 24)),
          Text('Swipe from the left edge to open the drawer.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}


class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.rss_feed, size: 80, color: Colors.indigo),
          SizedBox(height: 20),
          Text('Feed Page', style: TextStyle(fontSize: 24)),
        ],
      ),
    );
  }
}


class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, size: 80, color: Colors.indigo),
          SizedBox(height: 20),
          Text('Profile Page', style: TextStyle(fontSize: 24)),
        ],
      ),
    );
  }
}
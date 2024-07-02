import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(SimpleCalculatorApp());
}

class SimpleCalculatorApp extends StatefulWidget {
  @override
  _SimpleCalculatorAppState createState() => _SimpleCalculatorAppState();
}

class _SimpleCalculatorAppState extends State<SimpleCalculatorApp> {
  ThemeMode _themeMode = ThemeMode.light;
  static const MethodChannel _batteryChannel = MethodChannel('com.example.flutter/battery');

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
    _initConnectivity();
    _initBatteryChannel();
  }

  void _loadThemeMode() async {
    var themePreference = await ThemePreferences().getThemeMode();
    setState(() {
      _themeMode = _getThemeMode(themePreference);
    });
  }

  void _initConnectivity() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      bool isConnected = result != ConnectivityResult.none;
      _showConnectivityToast(isConnected);
    });
  }

  void _initBatteryChannel() {
    _batteryChannel.setMethodCallHandler((call) async {
      if (call.method == "batteryLevel") {
        String message = call.arguments;
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[800],
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    });
  }

  void _showConnectivityToast(bool isConnected) {
    String message = isConnected ? 'Connected to Internet' : 'No Internet Connection';
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey[800],
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  ThemeMode _getThemeMode(ThemeModePreference themePreference) {
    switch (themePreference) {
      case ThemeModePreference.Light:
        return ThemeMode.light;
      case ThemeModePreference.Dark:
        return ThemeMode.dark;
      default:
        return ThemeMode.light;
    }
  }

  void updateTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      home: TabNavigation(),
    );
  }
}

class TabNavigation extends StatefulWidget {
  @override
  _TabNavigationState createState() => _TabNavigationState();
}

class _TabNavigationState extends State<TabNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    SignInScreen(),
    SignUpScreen(),
    Calculation(),
    SettingsScreen(),
    HelpScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[800],
        title: Text(
          "Simple Calculator",
          style: TextStyle(color: Colors.teal[600], fontWeight: FontWeight.bold),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.teal),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(
                'User Name',
                style: TextStyle(color: Colors.teal[600]),
              ),
              accountEmail: Text(
                'user@example.com',
                style: TextStyle(color: Colors.teal[600]),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  'U',
                  style: TextStyle(fontSize: 40.0, color: Colors.teal[600]),
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.grey[800],
              ),
            ),
            ListTile(
              leading: Icon(Icons.login, color: Colors.orange[900]),
              title: Text('Sign In'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex = 0;
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.app_registration, color: Colors.blue[900]),
              title: Text('Sign Up'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex = 1;
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.calculate, color: Colors.green),
              title: Text('Calculator'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex = 2;
                });
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex = 3;
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.help, color: Colors.blue),
              title: Text('Help'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex = 4;
                });
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.login, color: Colors.orange),
            label: 'Sign In',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.app_registration, color: Colors.blue),
            label: 'Sign Up',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate, color: Colors.green),
            label: 'Calculator',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help, color: Colors.blue),
            label: 'Help',
          ),
        ],
      ),
    );
  }
}

class SignInScreen extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign In", style: TextStyle(color: Colors.teal[900])),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle sign in logic here
                String username = _usernameController.text;
                String password = _passwordController.text;
                print('Username: $username, Password: $password');
              },
              child: Text('Sign In', style: TextStyle(color: Colors.teal[900])),
            ),
          ],
        ),
      ),
    );
  }
}

class SignUpScreen extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign Up", style: TextStyle(color: Colors.teal[900])),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle sign up logic here
                String username = _usernameController.text;
                String email = _emailController.text;
                String password = _passwordController.text;
                print('Username: $username, Email: $email, Password: $password');
              },
              child: Text('Sign Up', style: TextStyle(color: Colors.teal[900])),
            ),
          ],
        ),
      ),
    );
  }
}

class Calculation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculator'),
      ),
      body: Center(
        child: Text('Calculator Screen'),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                ThemePreferences().setThemeMode(ThemeModePreference.Light).then((_) {
                  final state = context.findAncestorStateOfType<_SimpleCalculatorAppState>();
                  state?.updateTheme(ThemeMode.light);
                });
              },
              child: Text('Switch to Light Mode'),
            ),
            ElevatedButton(
              onPressed: () {
                ThemePreferences().setThemeMode(ThemeModePreference.Dark).then((_) {
                  final state = context.findAncestorStateOfType<_SimpleCalculatorAppState>();
                  state?.updateTheme(ThemeMode.dark);
                });
              },
              child: Text('Switch to Dark Mode'),
            ),
          ],
        ),
      ),
    );
  }
}

class HelpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help'),
      ),
      body: Center(
        child: Text('Help Screen'),
      ),
    );
  }
}

enum ThemeModePreference { Light, Dark }

class ThemePreferences {
  static const _themeModeKey = 'theme_mode';

  Future<void> setThemeMode(ThemeModePreference themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, themeMode.toString());
  }

  Future<ThemeModePreference> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeString = prefs.getString(_themeModeKey) ?? 'ThemeModePreference.Light';
    return _getThemeModePreference(themeModeString);
  }

  ThemeModePreference _getThemeModePreference(String themeModeString) {
    switch (themeModeString) {
      case 'ThemeModePreference.Light':
        return ThemeModePreference.Light;
      case 'ThemeModePreference.Dark':
        return ThemeModePreference.Dark;
      default:
        return ThemeModePreference.Light;
    }
  }
}
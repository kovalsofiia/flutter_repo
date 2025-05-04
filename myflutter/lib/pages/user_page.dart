import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myflutter/services/auth_service.dart';
import 'package:myflutter/api/db_op.dart';
import 'package:myflutter/models/peak.dart';
import 'package:myflutter/pages/view_page.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final dbOperations = DbOperations.fromSettings();
  final AuthService _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoginMode = true;
  String? _errorMessage;
  bool? _isAdmin;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _checkAdminStatus() async {
    final user = _authService.currentUser;
    if (user != null) {
      final isAdmin = await _authService.isAdmin(user.uid);
      setState(() {
        _isAdmin = isAdmin;
      });
    } else {
      setState(() {
        _isAdmin = false;
      });
    }
  }

  Future<void> _submit() async {
    setState(() {
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter email and password';
      });
      return;
    }
    if (!_isLoginMode && name.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your name';
      });
      return;
    }

    User? user;
    if (_isLoginMode) {
      user = await _authService.signInWithEmail(email, password);
    } else {
      user = await _authService.signUpWithEmail(
        email,
        password,
        displayName: name,
      );
    }

    if (user == null) {
      setState(() {
        _errorMessage =
            _isLoginMode
                ? 'Login failed. Check your credentials.'
                : 'Registration failed. Try again.';
      });
    } else {
      await _checkAdminStatus();
      // Після успішної авторизації можна скинути режим входу
      if (_isLoginMode) {
        setState(() {
          _isLoginMode =
              false; // Або будь-яке інше значення, яке вказує на авторизований стан
        });
      }
      Navigator.pop(context);
    }
  }

  void navigateToDetailPage(Peak peak) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => DetailPage(
              peak: peak,
              onLoginNeeded: () {
                Navigator.pushNamed(context, '/user_page');
              },
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<User?>(
          stream: _authService.authStateChanges,
          builder: (context, snapshot) {
            final User? user = snapshot.data;
            if (user != null) {
              return const Text('User Profile'); // Текст після авторизації
            } else {
              return Text(
                _isLoginMode ? 'Sign In' : 'Sign Up',
              ); // Текст до авторизації
            }
          },
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<User?>(
        stream: _authService.authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final User? user = snapshot.data;

          if (user == null) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),
                    if (!_isLoginMode)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          _isLoginMode ? 'Sign In' : 'Sign Up',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLoginMode = !_isLoginMode;
                          _errorMessage = null;
                          _emailController.clear();
                          _passwordController.clear();
                          _nameController.clear();
                        });
                      },
                      child: Text(
                        _isLoginMode
                            ? 'Need an account? Sign Up'
                            : 'Already have an account? Sign In',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[300],
                  child: Text(
                    user.displayName?.substring(0, 1).toUpperCase() ??
                        user.email?.substring(0, 1).toUpperCase() ??
                        '',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  user.displayName ?? user.email ?? 'User',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                Text(
                  user.email ?? 'No Email',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                if (_isAdmin == true)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/admin'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Open Admin Panel',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                if (_isAdmin == true) const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      await _authService.signOut();
                      setState(() {
                        _isAdmin = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Signed out')),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Sign Out',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Text(
                  'Favourite Peaks',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: dbOperations.favouritePeaksStream(user.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Failed to load favourites',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      );
                    }
                    final favouriteData = snapshot.data ?? [];
                    final favouritePeaks =
                        favouriteData.map((map) => Peak.fromMap(map)).toList();
                    if (favouritePeaks.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'No favourite peaks yet',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      );
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: favouritePeaks.length,
                      itemBuilder: (context, index) {
                        final peak = favouritePeaks[index];
                        return AnimatedOpacity(
                          opacity: 1.0,
                          duration: Duration(milliseconds: 200 + (index * 100)),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              peak.name,
                              style: const TextStyle(fontSize: 16),
                            ),
                            trailing: const Icon(
                              Icons.chevron_right,
                              color: Colors.grey,
                              size: 20,
                            ),
                            onTap: () => navigateToDetailPage(peak),
                          ),
                        );
                      },
                      separatorBuilder:
                          (context, index) =>
                              Divider(color: Colors.grey[300], height: 1),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

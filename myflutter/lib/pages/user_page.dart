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
      appBar: AppBar(title: const Text('User Profile')),
      body: StreamBuilder<User?>(
        stream: _authService.authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final User? user = snapshot.data;

          if (user == null) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isLoginMode ? 'Sign In' : 'Sign Up',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (!_isLoginMode)
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            hintText: 'Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      if (!_isLoginMode) const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          hintText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          hintText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 12),
                      if (_errorMessage != null)
                        AnimatedOpacity(
                          opacity: _errorMessage != null ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(_isLoginMode ? 'Sign In' : 'Sign Up'),
                        ),
                      ),
                      const SizedBox(height: 8),
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
              ),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    user.displayName ?? user.email ?? 'User',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email ?? 'No Email',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  if (_isAdmin == true)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/admin'),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Open Admin Panel'),
                      ),
                    ),
                  if (_isAdmin == true) const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await _authService.signOut();
                        setState(() {
                          _isAdmin = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Signed out')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Sign Out'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Favourite Peaks',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: dbOperations.favouritePeaksStream(user.uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Failed to load favourites',
                            style: TextStyle(fontSize: 14, color: Colors.red),
                          ),
                        );
                      }
                      final favouriteData = snapshot.data ?? [];
                      final favouritePeaks =
                          favouriteData
                              .map((map) => Peak.fromMap(map))
                              .toList();
                      if (favouritePeaks.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'No favourite peaks yet',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
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
                            duration: Duration(
                              milliseconds: 200 + (index * 100),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 0,
                              ),
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
            ),
          );
        },
      ),
    );
  }
}

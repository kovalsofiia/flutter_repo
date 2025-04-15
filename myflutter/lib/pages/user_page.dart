import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myflutter/services/auth_service.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
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
    // Перевіряємо статус адміна після логіну
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
      await _checkAdminStatus(); // Оновлюємо статус адміна після логіну
    }
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
            // Незалогінений користувач
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isLoginMode ? 'Sign In' : 'Sign Up',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!_isLoginMode)
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  if (!_isLoginMode) const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _submit,
                    child: Text(_isLoginMode ? 'Sign In' : 'Sign Up'),
                  ),
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
                    ),
                  ),
                ],
              ),
            );
          }

          // Залогінений користувач
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  user.displayName ?? user.email ?? 'User',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user.email ?? 'No Email',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                if (_isAdmin == true)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/admin');
                    },
                    child: const Text('Open Admin Panel'),
                  ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    await _authService.signOut();
                    setState(() {
                      _isAdmin = false; // Скидаємо статус адміна
                    });
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('Signed out')));
                  },
                  child: const Text('Sign Out'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

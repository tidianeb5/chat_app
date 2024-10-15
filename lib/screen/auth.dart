import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  var _isLogin = true;
  var _isLoading = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _showSnackbar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      duration: const Duration(seconds: 5),
    ));
  }

  void _login({required String email, required String password}) async {
    try {
      setState(() {
        _isLoading = true;
      });
      final credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      _showSnackbar("Logged in");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _showSnackbar('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        _showSnackbar('Wrong password provided for that user.');
      } else {
        print(e);
        _showSnackbar(e.toString());
      }
    } catch (e) {
      _showSnackbar(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _signup({required String email, required String password}) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      print(credential);
      _showSnackbar('Your account has been created.');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        _showSnackbar('The password provided is too weak. ');
      } else if (e.code == 'email-already-in-use') {
        _showSnackbar('The account already exists for that email.');
      } else {
        _showSnackbar(e.toString());
      }
    } catch (e) {
      _showSnackbar(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _submit() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showSnackbar("email or password is empty");
      return;
    }

    if (_isLogin) {
      _login(email: email, password: password);
      return;
    }

    _signup(email: email, password: password);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // _auth.signOut();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                width: 200,
                child: Image.asset('assets/images/chat.png'),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                                labelText: 'Email Address'),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                          ),
                          TextFormField(
                            controller: _passwordController,
                            decoration:
                                const InputDecoration(labelText: 'Password'),
                            obscureText: true,
                          ),
                          const SizedBox(height: 12),
                          _isLoading
                              ? const CircularProgressIndicator()
                              : ElevatedButton(
                                  onPressed: _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                  ),
                                  child: Text(_isLogin ? 'Login' : 'Signup'),
                                ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = !_isLogin;
                              });
                            },
                            child: Text(_isLogin
                                ? 'Create an account'
                                : 'I already have an account'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

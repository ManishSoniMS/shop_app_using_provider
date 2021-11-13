import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/models/http_exception.dart';
import '/providers/providers.dart';
import '/screen/screen.dart';

enum AuthMode { signup, login }

class AuthCard extends StatefulWidget {
  const AuthCard({Key? key}) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  AnimationController? _controller;
  Animation<Size>? _heightAnimation;
  Animation<double>? _opacityAnimation;
  Animation<Offset>? _slideAnimation;

  AuthMode _authMode = AuthMode.login;
  Map<String, dynamic> _authData = {
    "email": "",
    "password": "",
  };
  bool _isLoading = false;
  final _passwordController = TextEditingController();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      //Invalid
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.login) {
        //Log user in
        await Provider.of<Auth>(context, listen: false).logIn(
          _authData["email"],
          _authData["password"],
        );
      } else {
        //sign user up
        await Provider.of<Auth>(context, listen: false).signUp(
          _authData["email"],
          _authData["password"],
        );
      }
      Navigator.of(context)
          .pushReplacementNamed(ProductsOverviewScreen.routeName);
    } on HttpException catch (error) {
      var errorMessage = "Authentication failed!";
      if (error.toString().contains("EMAIL_EXISTS")) {
        errorMessage = "This email address is already used.";
      } else if (error.toString().contains("EMAIL_NOT_FOUND")) {
        errorMessage = "Could not find the user with that email.";
      } else if (error.toString().contains("INVALID_PASSWORD")) {
        errorMessage = "Invalid Password.";
      } else if (error.toString().contains("TOO_MANY_ATTEMPTS_TRY_LATER")) {
        errorMessage =
        "Your account has been temporary blocked. Please try again later.";
      }
      _showErrorDialog(errorMessage);
    } catch (error) {
      const errorMessage =
          "Could not authenticate you. Please try again later.";
      _showErrorDialog(errorMessage);
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("An error occurred!"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Okay"),
          ),
        ],
      ),
    );
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.login) {
      setState(() {
        _authMode = AuthMode.signup;
      });
      _controller!.forward();
    } else {
      setState(() {
        _authMode = AuthMode.login;
      });
      _controller!.reverse();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _heightAnimation = Tween<Size>(
      begin: Size(double.infinity, MediaQuery.of(context).size.height * 0.31),
      end: Size(double.infinity, MediaQuery.of(context).size.height * 0.38),
    ).animate(
      CurvedAnimation(
        parent: _controller as AnimationController,
        curve: Curves.ease,
      ),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller as AnimationController,
        curve: Curves.easeIn,
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller as AnimationController,
        curve: Curves.ease,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _passwordController.dispose();
    _controller!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 8,
      child: AnimatedBuilder(
        animation: _heightAnimation as Animation,
        builder: (context, child) => Container(
          width: deviceWidth * 0.75,
          height: _heightAnimation!.value.height,
          constraints:
          BoxConstraints(minHeight: _heightAnimation!.value.height),
          padding: EdgeInsets.symmetric(horizontal: deviceWidth * 0.05),
          child: child,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: "Email"),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty || !value.contains("@")) {
                      return "Invalid Email!";
                    }
                  },
                  onSaved: (value) {
                    _authData["email"] = value!;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: "Password"),
                  controller: _passwordController,
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty || value.length < 5) {
                      return "Password is too short!";
                    }
                  },
                  onSaved: (value) {
                    _authData["password"] = value!;
                  },
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  constraints: BoxConstraints(
                      maxHeight: _authMode == AuthMode.signup
                          ? deviceHeight * 0.075
                          : 0,
                      minHeight: _authMode == AuthMode.signup
                          ? deviceHeight * 0.05
                          : 0),
                  curve: Curves.easeInOut,
                  child: FadeTransition(
                    opacity: _opacityAnimation as Animation<double>,
                    child: SlideTransition(
                      position: _slideAnimation as Animation<Offset>,
                      child: TextFormField(
                        decoration: const InputDecoration(
                            labelText: "Confirm Password"),
                        obscureText: true,
                        validator: _authMode == AuthMode.signup
                            ? (value) {
                          if (value != _passwordController.text) {
                            return "Password is not match!";
                          }
                        }
                            : null,
                        onSaved: (value) {
                          _authData["password"] = value!;
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: deviceHeight * 0.04),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  GestureDetector(
                    onTap: _submit,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: deviceWidth * 0.1,
                          vertical: deviceHeight * 0.02),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        _authMode == AuthMode.login ? "LOGIN" : "SIGN UP",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: deviceHeight * 0.005),
                  child: TextButton(
                    onPressed: _switchAuthMode,
                    child: Text(
                      "${_authMode == AuthMode.login ? "SIGNUP" : "LOGIN"} INSTEAD",
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_model.dart';

class LoginPageProvider extends StatefulWidget {
  const LoginPageProvider({super.key});

  @override
  State<LoginPageProvider> createState() => _LoginPageProviderState();
}

class _LoginPageProviderState extends State<LoginPageProvider> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  String? _emailError;
  String? _passwordError;
  bool _autoLoginFinished = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_autoLoginFinished) {
      _autoLoginFinished = true;
      _handleAutoLogin();
    }
  }

  void _handleAutoLogin() {
    try {
      // Get the model synchronously
      final model = Provider.of<LoginModel>(context, listen: false);
      model.tryAutoLogin().then((success) {
        if (success && mounted) {
          Navigator.of(context).pushReplacementNamed('/list');
        }
      });
    } catch (e) {
      // handle errors
    }
  }

  void _onEmailChanged(String value) {
    setState(() {
      _emailError = null;
    });
  }

  void _onPasswordChanged(String value) {
    setState(() {
      _passwordError = null;
    });
  }

  Future<void> _onLoginPressed(LoginModel model) async {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    bool valid = true;
    if (!RegExp(r"^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}").hasMatch(email)) {
      setState(() {
        _emailError = 'Érvénytelen email cím!';
      });
      valid = false;
    }
    if (password.length < 6) {
      setState(() {
        _passwordError = 'A jelszónak legalább 6 karakter hosszúnak kell lennie!';
      });
      valid = false;
    }
    if (!valid) return;
    try {
      await model.login(email, password, _rememberMe);
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/list');
      }
    } on LoginException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginModel>(
      builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Bejelentkezés')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _emailController,
                  enabled: !model.isLoading,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    errorText: _emailError,
                  ),
                  onChanged: _onEmailChanged,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  enabled: !model.isLoading,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Jelszó',
                    errorText: _passwordError,
                  ),
                  onChanged: _onPasswordChanged,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: model.isLoading
                          ? null
                          : (v) {
                              setState(() {
                                _rememberMe = v ?? false;
                              });
                            },
                    ),
                    const Text('Jegyezz meg'),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: model.isLoading ? null : () => _onLoginPressed(model),
                      child: const Text('Bejelentkezés'),
                    ),
                    if (model.isLoading)
                      Container(
                        width: 0,
                        height: 0,
                        margin: EdgeInsets.zero,
                        child: const SizedBox.shrink(),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

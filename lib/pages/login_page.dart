import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart';
import '../api.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false;
  String? error;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email')),
              const SizedBox(height: 8),
              TextField(
                  controller: passCtrl,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true),
              const SizedBox(height: 16),
              if (error != null)
                Text(error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: loading
                    ? null
                    : () async {
                        setState(() {
                          loading = true;
                          error = null;
                        });
                        try {
                          await auth.login(
                              emailCtrl.text.trim(), passCtrl.text);
                          if (context.mounted)
                            Navigator.of(context)
                                .pushReplacementNamed('/products');
                        } catch (e) {
                          setState(() {
                            error = e.toString();
                          });
                        } finally {
                          if (mounted)
                            setState(() {
                              loading = false;
                            });
                        }
                      },
                child: Text(loading ? 'Ingresando...' : 'Ingresar'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () async {
                  setState(() {
                    loading = true;
                    error = null;
                  });
                  try {
                    await Api.register(emailCtrl.text.trim(), passCtrl.text);
                    if (context.mounted)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Registrado como Cliente. Ahora haz login.')),
                      );
                  } catch (e) {
                    setState(() {
                      error = e.toString();
                    });
                  } finally {
                    if (mounted)
                      setState(() {
                        loading = false;
                      });
                  }
                },
                child: const Text('Crear cuenta Cliente'),
              )
            ]),
          ),
        ),
      ),
    );
  }
}

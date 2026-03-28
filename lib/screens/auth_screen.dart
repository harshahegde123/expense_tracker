import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;

  final email = TextEditingController();
  final password = TextEditingController();

  Future<void> submit() async {
    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.text.trim(),
          password: password.text.trim(),
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.text.trim(),
          password: password.text.trim(),
        );
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const Icon(Icons.wallet, size: 80, color: Colors.tealAccent),

              const SizedBox(height: 20),

              TextField(
                controller: email,
                decoration: const InputDecoration(hintText: "Email"),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: password,
                obscureText: true,
                decoration: const InputDecoration(hintText: "Password"),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: submit,
                  child: Text(isLogin ? "LOGIN" : "REGISTER"),
                ),
              ),

              TextButton(
                onPressed: () {
                  setState(() => isLogin = !isLogin);
                },
                child: Text(isLogin
                    ? "Create account"
                    : "Already have account?"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(
                          height: 120,
                          child: Center(
                            child: Text(
                              'Login UI',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        const TextField(
                          decoration: InputDecoration(
                            hintText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 12),

                        const TextField(
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              // Login logic will be added later.
                            },
                            child: const Text('Log In'),
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (
                                  context,
                                  animation,
                                  secondaryAnimation,
                                ) => const RegisterScreen(),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                          },
                          child: const Text('Create an account'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

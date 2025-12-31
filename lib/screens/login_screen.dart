import 'package:flutter/material.dart';
import '../api/real/auth_api.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final _authApi = AuthApi(); // ✅ backend API

  bool _loading = false;
  String? _error;

  // 🔑 REAL LOGIN (backend connect)
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _authApi.login(
        _phoneController.text.trim(),
        _passwordController.text.trim(),
      );

      final role = AuthApi.user?["role"];
      debugPrint("LOGIN ROLE => $role");

      if (!mounted) return;

      switch (role) {
        case "DISTRIBUTOR":
          Navigator.pushReplacementNamed(context, "/distributor-home");
          break;
        case "MANAGER":
          Navigator.pushReplacementNamed(context, "/manager-home");
          break;
        case "DRIVER":
          Navigator.pushReplacementNamed(context, "/driver");
          break;
        case "MASTER":
          Navigator.pushReplacementNamed(context, "/master");
          break;
        case "SALES OFFICER":
          Navigator.pushReplacementNamed(context, "/sales");
          break;
        default:
          setState(() => _error = "Invalid role");
      }
    } catch (e) {
      debugPrint("LOGIN ERROR => $e");
      setState(() => _error = "Invalid phone or password");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: Stack(
        children: [
          // 🔹 BACKGROUND IMAGE
          Align(
            alignment: Alignment.topCenter,
            child: Opacity(
              opacity: 0.9,
              child: Image.asset(
                "assets/images/truck.png",
                height: 260,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // 🔹 CONTENT
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 220, 24, 24),
              child: Column(
                children: [
                  const Text(
                    "Slot Booking System",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E2A44),
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    "SalesOfficer • Distributor • Manager • Driver • Master",
                    style: TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 24),

                  Card(
                    elevation: 6,
                    shadowColor: Colors.black12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: "Phone Number",
                                prefixIcon: const Icon(Icons.phone),
                                filled: true,
                                fillColor: const Color(0xFFF7F9FC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? "Enter phone number"
                                  : null,
                            ),

                            const SizedBox(height: 14),

                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: "Password",
                                prefixIcon: const Icon(Icons.lock_outline),
                                filled: true,
                                fillColor: const Color(0xFFF7F9FC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? "Enter password"
                                  : null,
                            ),

                            const SizedBox(height: 18),

                            if (_error != null)
                              Text(
                                _error!,
                                style: const TextStyle(color: Colors.red),
                              ),

                            const SizedBox(height: 10),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _loading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  backgroundColor: const Color(0xFF2F80ED),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _loading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      )
                                    : const Text(
                                        "LOGIN",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                              ),
                            ),

                            TextButton(
                              onPressed: () {},
                              child: const Text("Forgot Password?"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    "© Super Stockist Management",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

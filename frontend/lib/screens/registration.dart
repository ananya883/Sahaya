import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

const Color _primaryColor = Color(0xFF1E88E5);
const double _headerHeight = 220.0;

class CustomHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 50);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  // User details
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _houseNoController = TextEditingController();

  // Guardian details
  final TextEditingController _guardianNameController = TextEditingController();
  final TextEditingController _guardianRelationController = TextEditingController();
  final TextEditingController _guardianMobileController = TextEditingController();
  final TextEditingController _guardianEmailController = TextEditingController();
  final TextEditingController _guardianAddressController = TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _dobController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    _houseNoController.dispose();
    _guardianNameController.dispose();
    _guardianRelationController.dispose();
    _guardianMobileController.dispose();
    _guardianEmailController.dispose();
    _guardianAddressController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: _primaryColor),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final response = await ApiService.registerUser(
        Name: _nameController.text.trim(),
        gender: "Other", // can add a dropdown later
        dob: _dobController.text.trim(),
        mobile: _mobileController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        address: _addressController.text.trim(),
        houseNo: _houseNoController.text.trim(),
        guardianName: _guardianNameController.text.trim(),
        guardianRelation: _guardianRelationController.text.trim(),
        guardianMobile: _guardianMobileController.text.trim(),
        guardianEmail: _guardianEmailController.text.trim(),
        guardianAddress: _guardianAddressController.text.trim(),
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackBar("Registered successfully! Proceeding to login.", Colors.green);
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        final responseBody = jsonDecode(response.body);
        _showError(responseBody['error'] ?? "Registration failed!");
      }
    } catch (e) {
      _showError("An error occurred. Please check your connection.");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String message) => _showSnackBar(message, Colors.red);

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  InputDecoration _buildInputDecoration({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: _primaryColor),
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300, width: 1)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _primaryColor, width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red, width: 1)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red, width: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _buildHeader(),
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: _headerHeight - 40, left: 24, right: 24, bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text("Create Account", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  const Text("Register now to get started!", style: TextStyle(fontSize: 16, color: Colors.grey), textAlign: TextAlign.center),
                  const SizedBox(height: 20),

                  // User info
                  TextFormField(
                    controller: _nameController,
                    validator: (v) => v!.isEmpty ? 'Enter name' : null,
                    decoration: _buildInputDecoration(hint: "Full Name", icon: Icons.person_outline),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v!.isEmpty) return 'Enter email';
                      bool valid = RegExp(r"^[a-zA-Z0-9.+_-]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(v);
                      if (!valid) return 'Invalid email';
                      return null;
                    },
                    decoration: _buildInputDecoration(hint: "Email", icon: Icons.mail_outline),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    validator: (v) => v!.isEmpty ? 'Enter password' : null,
                    decoration: _buildInputDecoration(hint: "Password", icon: Icons.lock_outline).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: _primaryColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    validator: (v) {
                      if (v!.isEmpty) return 'Confirm password';
                      if (v != _passwordController.text) return 'Passwords do not match';
                      return null;
                    },
                    decoration: _buildInputDecoration(hint: "Confirm Password", icon: Icons.lock_outline).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                          color: _primaryColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _dobController,
                    readOnly: true,
                    onTap: _selectDate,
                    validator: (v) => v!.isEmpty ? 'Select DOB' : null,
                    decoration: _buildInputDecoration(hint: "Date of Birth", icon: Icons.calendar_today),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    validator: (v) => v!.isEmpty ? 'Enter mobile' : null,
                    decoration: _buildInputDecoration(hint: "Mobile Number", icon: Icons.phone),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    validator: (v) => v!.isEmpty ? 'Enter address' : null,
                    decoration: _buildInputDecoration(hint: "Address", icon: Icons.home),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _houseNoController,
                    validator: (v) => v!.isEmpty ? 'Enter house no' : null,
                    decoration: _buildInputDecoration(hint: "House No", icon: Icons.location_city),
                  ),
                  const SizedBox(height: 24),

                  // Guardian info
                  const Text("Guardian Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _guardianNameController,
                    validator: (v) => v!.isEmpty ? 'Enter guardian name' : null,
                    decoration: _buildInputDecoration(hint: "Guardian Name", icon: Icons.person),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _guardianRelationController,
                    validator: (v) => v!.isEmpty ? 'Enter relation' : null,
                    decoration: _buildInputDecoration(hint: "Relation", icon: Icons.group),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _guardianMobileController,
                    keyboardType: TextInputType.phone,
                    validator: (v) => v!.isEmpty ? 'Enter mobile' : null,
                    decoration: _buildInputDecoration(hint: "Guardian Mobile", icon: Icons.phone),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _guardianEmailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v!.isEmpty ? 'Enter email' : null,
                    decoration: _buildInputDecoration(hint: "Guardian Email", icon: Icons.mail_outline),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _guardianAddressController,
                    validator: (v) => v!.isEmpty ? 'Enter address' : null,
                    decoration: _buildInputDecoration(hint: "Guardian Address", icon: Icons.home),
                  ),

                  const SizedBox(height: 30),
                  _loading
                      ? const Center(child: CircularProgressIndicator(color: _primaryColor))
                      : ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: const Text("Register", style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Already have an account? Login", style: TextStyle(color: Colors.grey, fontSize: 16))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return ClipPath(
      clipper: CustomHeaderClipper(),
      child: Container(
        height: _headerHeight,
        color: _primaryColor,
        alignment: Alignment.center,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 30),
            Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 64),
          ],
        ),
      ),
    );
  }
}

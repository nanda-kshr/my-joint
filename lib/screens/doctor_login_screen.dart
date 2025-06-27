import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

class DoctorLoginScreen extends StatefulWidget {
  final bool isRegister;
  
  const DoctorLoginScreen({
    super.key,
    this.isRegister = false,
  });

  @override
  State<DoctorLoginScreen> createState() => _DoctorLoginScreenState();
}

class _DoctorLoginScreenState extends State<DoctorLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _specializationController = TextEditingController();
  final _licenseController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _specializationController.dispose();
    _licenseController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      developer.log('Form validation failed');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      developer.log('Starting ${widget.isRegister ? 'registration' : 'login'} process');
      final prefs = await SharedPreferences.getInstance();
      final apiService = ApiService(prefs);
      
      if (widget.isRegister) {
        final registrationData = {
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
          'name': _nameController.text.trim(),
          'specialization': _specializationController.text.trim(),
          'licenseNumber': _licenseController.text.trim(),
          'phoneNumber': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
        };
        
        developer.log('Registration data prepared: $registrationData');
        await apiService.doctorRegister(registrationData);
        
        if (mounted) {
          developer.log('Registration successful, showing success message');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful!')),
          );
          Navigator.pushReplacementNamed(context, '/doctor-dashboard');
        }
      } else {
        developer.log('Attempting login with email: ${_emailController.text.trim()}');
        await apiService.doctorLogin(
          _emailController.text.trim(),
          _passwordController.text,
        );
        
        if (mounted) {
          developer.log('Login successful, navigating to dashboard');
          Navigator.pushReplacementNamed(context, '/doctor-dashboard');
        }
      }
    } catch (e, stackTrace) {
      developer.log('Error during ${widget.isRegister ? 'registration' : 'login'}: $e',
          error: e, stackTrace: stackTrace);
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isRegister ? 'Doctor Registration' : 'Doctor Login'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.isRegister) ...[
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _specializationController,
                  decoration: const InputDecoration(
                    labelText: 'Specialization',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your specialization';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _licenseController,
                  decoration: const InputDecoration(
                    labelText: 'License Number',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your license number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(widget.isRegister ? 'Register' : 'Login'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(
                    context,
                    widget.isRegister ? '/doctor-login' : '/doctor-register',
                  );
                },
                child: Text(
                  widget.isRegister
                      ? 'Already have an account? Login'
                      : 'Don\'t have an account? Register',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 
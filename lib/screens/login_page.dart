import 'package:flutter/material.dart';
import 'dart:async';
import '../utils/constants.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _studentIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Logo ve form animasyonları için controller
    _animationController = AnimationController(
      vsync: this,
      duration: AppDurations.longAnimation,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _studentIdController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Giriş işlemi
  void _login() {
    // Form validasyonu
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // 2 saniye sonra login işlemini tamamla (gerçek uygulamada API isteği olacak)
      Timer(AppDurations.longAnimation, () {
        setState(() {
          _isLoading = false;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    _buildLogo(),
                    const SizedBox(height: 24.0),

                    // Başlık
                    const Text(
                      AppTexts.loginTitle,
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8.0),

                    // Alt başlık
                    const Text(
                      AppTexts.loginSubtitle,
                      style: TextStyle(
                        fontSize: 16.0,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 36.0),

                    // Öğrenci No
                    _buildStudentIdField(),
                    const SizedBox(height: 16.0),

                    // Şifre
                    _buildPasswordField(),
                    const SizedBox(height: 24.0),

                    // Giriş butonu
                    _buildLoginButton(),
                    const SizedBox(height: 16.0),

                    // Şifremi unuttum
                    _buildForgotPasswordButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Logo widget'ı
  Widget _buildLogo() {
    return Container(
      width: 80,
      height: 80,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(
          Icons.home_outlined,
          color: Colors.white,
          size: 36,
        ),
      ),
    );
  }

  // Öğrenci No alanı
  Widget _buildStudentIdField() {
    return TextFormField(
      controller: _studentIdController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        filled: true,
        fillColor: AppColors.inputBackground,
        hintText: AppTexts.studentIdHint,
        prefixIcon: Icon(Icons.person_outline),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Lütfen öğrenci numaranızı girin';
        } else if (value.length < 6) {
          return 'Öğrenci numarası en az 6 karakter olmalıdır';
        }
        return null;
      },
    );
  }

  // Şifre alanı
  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.inputBackground,
        hintText: AppTexts.passwordHint,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Lütfen şifrenizi girin';
        } else if (value.length < 4) {
          return 'Şifre en az 4 karakter olmalıdır';
        }
        return null;
      },
    );
  }

  // Giriş butonu
  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        child: _isLoading
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : const Text(AppTexts.loginButton),
      ),
    );
  }

  // Şifremi unuttum butonu
  Widget _buildForgotPasswordButton() {
    return TextButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Şifremi unuttum fonksiyonu'),
          ),
        );
      },
      child: const Text(AppTexts.forgotPassword),
    );
  }
}
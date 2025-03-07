import 'package:flutter/material.dart';
import 'dart:async';
import '../services/admin_service.dart';
import '../services/user_service.dart';
import '../utils/constants.dart';
import 'home_page.dart';
import 'admin/admin_home_page.dart';

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
  bool _isAdminLogin = false; // Öğrenci veya admin girişi seçimi
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Servisler
  final UserService _userService = UserService();
  final AdminService _adminService = AdminService();

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

      // Admin girişi
      if (_isAdminLogin) {
        _loginAsAdmin();
      }
      // Öğrenci girişi
      else {
        _loginAsStudent();
      }
    }
  }

  // Admin olarak giriş
  void _loginAsAdmin() {
    try {
      // Admin servisi üzerinden giriş dene
      _adminService.setCurrentAdmin(
          _studentIdController.text,
          _passwordController.text
      );

      // Başarılı ise admin ana sayfasına yönlendir
      Timer(AppDurations.longAnimation, () {
        setState(() {
          _isLoading = false;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminHomePage()),
        );
      });
    } catch (e) {
      // Hata durumunda kullanıcıya göster
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // Öğrenci olarak giriş
  void _loginAsStudent() {
    try {
      // Kullanıcı servisi üzerinden giriş dene
      final user = _userService.login(
          _studentIdController.text,
          _passwordController.text
      );

      if (user != null) {
        // Başarılı ise öğrenci ana sayfasına yönlendir
        Timer(AppDurations.longAnimation, () {
          setState(() {
            _isLoading = false;
          });
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        });
      } else {
        throw Exception('Geçersiz kullanıcı adı veya şifre');
      }
    } catch (e) {
      // Hata durumunda kullanıcıya göster
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
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

                    // Kullanıcı tipi seçimi (Admin/Öğrenci)
                    _buildUserTypeSelection(),
                    const SizedBox(height: 24.0),

                    // Kullanıcı adı / Öğrenci No
                    _buildUserIdField(),
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

  // Kullanıcı tipi seçim widget'ı
  Widget _buildUserTypeSelection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          // Öğrenci seçeneği
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _isAdminLogin = false;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                decoration: BoxDecoration(
                  color: !_isAdminLogin ? AppColors.primary : Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    bottomLeft: Radius.circular(8.0),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Öğrenci Girişi',
                    style: TextStyle(
                      color: !_isAdminLogin ? Colors.white : AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Admin seçeneği
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _isAdminLogin = true;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                decoration: BoxDecoration(
                  color: _isAdminLogin ? AppColors.primary : Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(8.0),
                    bottomRight: Radius.circular(8.0),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Personel Girişi',
                    style: TextStyle(
                      color: _isAdminLogin ? Colors.white : AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Öğrenci No / Kullanıcı adı alanı
  Widget _buildUserIdField() {
    final String labelText = _isAdminLogin ? 'Kullanıcı Adı' : 'Öğrenci No';
    final IconData iconData = _isAdminLogin ? Icons.person : Icons.badge_outlined;

    return TextFormField(
      controller: _studentIdController,
      keyboardType: _isAdminLogin ? TextInputType.text : TextInputType.number,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.inputBackground,
        hintText: labelText,
        prefixIcon: Icon(iconData),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Lütfen $labelText girin';
        } else if (!_isAdminLogin && value.length < 6) {
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
    final String buttonText = _isAdminLogin ? 'Personel Girişi' : 'Öğrenci Girişi';

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
            : Text(buttonText),
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
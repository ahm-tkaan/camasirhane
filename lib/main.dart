import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/login_page.dart';
import 'utils/theme.dart';

void main() {
  runApp(const KykCamasirhaneApp());
}

class KykCamasirhaneApp extends StatelessWidget {
  const KykCamasirhaneApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Durum çubuğunu şeffaf yapma
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return MaterialApp(
      title: 'KYK Çamaşırhane',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginPage(),
    );
  }
}
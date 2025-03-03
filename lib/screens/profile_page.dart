import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Mock kullanıcı verileri
  final Map<String, dynamic> _userData = {
    'fullName': 'Ahmet Kaan Çelenk',
    'studentId': '123456789',
    'email': 'akaanclnk@gmail.com',
    'phoneNumber': '0544 516 40 39',
    'dormitory': 'Büyük Selçuklu Erkek Öğrenci Yurdu',
    'roomNumber': 'C - 203',
    'totalUsage': 23,
    'memberSince': DateTime(2025, 03, 03),
    'notifications': true,
  };

  bool _isNotificationEnabled = true;

  @override
  void initState() {
    super.initState();
    _isNotificationEnabled = _userData['notifications'] as bool;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profil başlığı
          _buildProfileHeader(),
          const SizedBox(height: 24.0),

          // Profil bilgileri
          _buildProfileInfoCard(),
          const SizedBox(height: 16.0),

          // Ayarlar
          _buildSettingsCard(),
          const SizedBox(height: 16.0),

          // Hesap bilgileri
          _buildAccountInfoCard(),
          const SizedBox(height: 24.0),

          // Çıkış yap butonu
          _buildLogoutButton(),
        ],
      ),
    );
  }

  // Profil başlığı widget'ı
  Widget _buildProfileHeader() {
    final initials = _getInitials(_userData['fullName']);

    return Row(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 4.0,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _userData['fullName'],
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                _userData['studentId'],
                style: const TextStyle(
                  fontSize: 14.0,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                '${_userData["totalUsage"]} kez çamaşır yıkadınız',
                style: const TextStyle(
                  fontSize: 12.0,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Profil bilgileri kartı widget'ı
  Widget _buildProfileInfoCard() {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'İletişim Bilgileri',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16.0),
            _buildInfoRow(Icons.email, 'E-posta', _userData['email']),
            const SizedBox(height: 12.0),
            _buildInfoRow(Icons.phone, 'Telefon', _userData['phoneNumber']),
          ],
        ),
      ),
    );
  }

  // Ayarlar kartı widget'ı
  Widget _buildSettingsCard() {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ayarlar',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Bildirimler',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: AppColors.textPrimary,
                  ),
                ),
                Switch(
                  value: _isNotificationEnabled,
                  onChanged: (value) {
                    setState(() {
                      _isNotificationEnabled = value;
                    });
                  },
                  activeColor: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dil',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Türkçe',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Bilgi satırı widget'ı
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18.0,
          color: AppColors.primary,
        ),
        const SizedBox(width: 12.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12.0,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14.0,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Tarih biçimlendirme
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  // İsim baş harflerini alma
  String _getInitials(String fullName) {
    if (fullName.isEmpty) return '';

    List<String> nameParts = fullName.split(' ');
    if (nameParts.length > 1) {
      return nameParts[0][0].toUpperCase() + nameParts[1][0].toUpperCase();
    } else {
      return nameParts[0][0].toUpperCase();
    }
  }

  // Çıkış butonu
  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // Çıkış işlemi ve login sayfasına yönlendirme
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
          );
        },
        icon: const Icon(Icons.logout),
        label: const Text('Çıkış Yap'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12.0),
        ),
      ),
    );
  }

  // Hesap bilgileri kartı widget'ı
  Widget _buildAccountInfoCard() {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Yurt Bilgileri',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16.0),
            _buildInfoRow(Icons.home, 'Yurt', _userData['dormitory']),
            const SizedBox(height: 12.0),
            _buildInfoRow(Icons.hotel, 'Oda Numarası', _userData['roomNumber']),
            const SizedBox(height: 12.0),
            _buildInfoRow(
              Icons.calendar_today,
              'Üyelik Başlangıcı',
              _formatDate(_userData['memberSince']),
            ),
          ],
        ),
      ),
    );
  }
}
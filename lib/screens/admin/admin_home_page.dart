import 'package:flutter/material.dart';
import '../../models/admin.dart';
import '../../models/machine.dart';
import '../../services/admin_service.dart';
import '../../services/machine_service.dart';
import '../../services/notification_service.dart';
import '../../utils/constants.dart';
import '../login_page.dart';
import 'machine_management_page.dart';
import 'user_management_page.dart';
import 'technician_panel.dart';
import 'staff_panel.dart';
import 'maintenance_schedule_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final AdminService _adminService = AdminService();
  final MachineService _machineService = MachineService();
  final NotificationService _notificationService = NotificationService();

  Admin? _currentAdmin;
  bool _isLoading = true;
  Map<String, dynamic> _dashboardStats = {};
  List<Machine> _outOfOrderMachines = [];

  // Form controllers
  final _machineNameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _userNameController = TextEditingController();
  final _announcementTitleController = TextEditingController();
  final _announcementBodyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _machineNameController.dispose();
    _studentIdController.dispose();
    _userNameController.dispose();
    _announcementTitleController.dispose();
    _announcementBodyController.dispose();
    super.dispose();
  }

  // Verileri yükle
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Mevcut admin kullanıcısını al
      _currentAdmin = _adminService.getCurrentAdmin();
      if (_currentAdmin == null) {
        // Eğer admin girişi yapılmamışsa login sayfasına yönlendir
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage())
          );
        });
        return;
      }

      // İstatistikleri al
      _dashboardStats = _adminService.getDashboardStats();

      // Arızalı makineleri al
      _outOfOrderMachines = _adminService.getOutOfOrderMachines();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Çıkış yap
  void _logout() {
    _adminService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  // Bildirimleri göster
  void _showNotifications() {
    // Admin rolü ve ID'sine göre bildirimler alınacak
    if (_currentAdmin == null) return;

    final notifications = _notificationService.getAdminNotifications(
        _currentAdmin!.id,
        _currentAdmin!.role
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bildirimler',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),

            Expanded(
              child: notifications.isEmpty
                  ? const Center(
                child: Text('Bildirim bulunmamaktadır'),
              )
                  : ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: ListTile(
                      leading: Icon(
                        _getNotificationIcon(notification.type),
                        color: _getNotificationColor(notification.type),
                      ),
                      title: Text(notification.title),
                      subtitle: Text(notification.body),
                      trailing: notification.isRead
                          ? null
                          : Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      onTap: () {
                        // Bildirimi okundu olarak işaretle
                        _notificationService.markNotificationAsRead(notification.id);
                        Navigator.pop(context);

                        // Eğer ilgili makine varsa ve teknisyense, teknisyen paneline yönlendir
                        if (notification.relatedMachineId != null &&
                            _currentAdmin!.role == AdminRole.technician) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const TechnicianPanel()),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Yeni makine ekleme dialogu
  void _showAddMachineDialog() {
    MachineType selectedType = MachineType.washer; // Varsayılan tip

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Yeni Makine Ekle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Makine adı
              TextField(
                controller: _machineNameController,
                decoration: const InputDecoration(
                  labelText: 'Makine Adı',
                  hintText: 'Örn: Çamaşır Makinesi 5',
                ),
              ),
              const SizedBox(height: 16.0),

              // Makine tipi seçimi
              DropdownButtonFormField<MachineType>(
                value: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Makine Tipi',
                ),
                items: const [
                  DropdownMenuItem(
                    value: MachineType.washer,
                    child: Text('Çamaşır Makinesi'),
                  ),
                  DropdownMenuItem(
                    value: MachineType.dryer,
                    child: Text('Kurutma Makinesi'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedType = value;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_machineNameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lütfen makine adı girin'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                // Makineyi ekle
                try {
                  _adminService.addMachine(
                    _machineNameController.text,
                    selectedType,
                  );

                  _machineNameController.clear();
                  Navigator.pop(context);

                  // Verileri yenile
                  _loadData();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Makine başarıyla eklendi'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Hata: ${e.toString()}'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              child: const Text('Ekle'),
            ),
          ],
        ),
      ),
    );
  }

  // Yeni kullanıcı ekleme dialogu
  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Kullanıcı Ekle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Öğrenci numarası
            TextField(
              controller: _studentIdController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Öğrenci Numarası',
                hintText: 'Örn: 123456789',
              ),
            ),
            const SizedBox(height: 16.0),

            // Kullanıcı adı soyadı
            TextField(
              controller: _userNameController,
              decoration: const InputDecoration(
                labelText: 'Ad Soyad',
                hintText: 'Örn: Ahmet Yılmaz',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_studentIdController.text.isEmpty || _userNameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lütfen tüm alanları doldurun'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              // Kullanıcıyı ekle
              try {
                _adminService.createUser(
                  _studentIdController.text,
                  _userNameController.text,
                  null, // Telefon numarası
                  null, // Yurt ID
                  null, // Oda numarası
                );

                _studentIdController.clear();
                _userNameController.clear();
                Navigator.pop(context);

                // Verileri yenile
                _loadData();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Kullanıcı başarıyla eklendi'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Hata: ${e.toString()}'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  // Duyuru gönderme dialogu
  void _showSendAnnouncementDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Duyuru Gönder'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Duyuru başlığı
            TextField(
              controller: _announcementTitleController,
              decoration: const InputDecoration(
                labelText: 'Başlık',
                hintText: 'Örn: Bakım Bildirimi',
              ),
            ),
            const SizedBox(height: 16.0),

            // Duyuru içeriği
            TextField(
              controller: _announcementBodyController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Mesaj',
                hintText: 'Örn: Yarın saat 10:00-12:00 arası bakım yapılacaktır.',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_announcementTitleController.text.isEmpty ||
                  _announcementBodyController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lütfen tüm alanları doldurun'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              // Duyuruyu gönder
              try {
                _adminService.sendAnnouncementToAllUsers(
                  _announcementTitleController.text,
                  _announcementBodyController.text,
                );

                _announcementTitleController.clear();
                _announcementBodyController.clear();
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Duyuru başarıyla gönderildi'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Hata: ${e.toString()}'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Gönder'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentAdmin == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Admin rolüne göre uygun paneli göster
    return Scaffold(
      appBar: AppBar(
        title: const Text('KYK Çamaşırhane Yönetimi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: _showNotifications,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      drawer: _buildAdminDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadData,
        child: _buildDashboard(),
      ),
    );
  }

  // Admin menüsü
  Widget _buildAdminDrawer() {
    final adminName = _currentAdmin?.fullName ?? 'Admin';
    final adminRole = _getAdminRoleName(_currentAdmin?.role);
    final initials = _currentAdmin?.profileInitials ?? 'A';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Admin bilgileri
          UserAccountsDrawerHeader(
            accountName: Text(adminName),
            accountEmail: Text(adminRole),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 24.0,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
          ),

          // Navigasyon öğeleri
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Kontrol Paneli'),
            onTap: () {
              Navigator.pop(context); // Drawer'ı kapat
              // Zaten kontrol panelindeyiz
            },
          ),

          // Makine Yönetimi
          if (_currentAdmin!.hasPermission(AdminPermission.manageMachines))
            ListTile(
              leading: const Icon(Icons.local_laundry_service, color: Colors.white)
              ,
              title: const Text('Makine Yönetimi'),
              onTap: () {
                Navigator.pop(context); // Drawer'ı kapat
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MachineManagementPage()),
                );
              },
            ),

          // Kullanıcı Yönetimi
          if (_currentAdmin!.hasPermission(AdminPermission.manageUsers))
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Kullanıcı Yönetimi'),
              onTap: () {
                Navigator.pop(context); // Drawer'ı kapat
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserManagementPage()),
                );
              },
            ),

          // Bakım Planı
          if (_currentAdmin!.hasPermission(AdminPermission.technicalOperations) ||
              _currentAdmin!.hasPermission(AdminPermission.assignTechnicians))
            ListTile(
              leading: const Icon(Icons.engineering),
              title: const Text('Bakım Planları'),
              onTap: () {
                Navigator.pop(context); // Drawer'ı kapat
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MaintenanceSchedulePage()),
                );
              },
            ),

          // Teknisyen Paneli
          if (_currentAdmin!.role == AdminRole.technician)
            ListTile(
              leading: const Icon(Icons.build),
              title: const Text('Teknisyen Paneli'),
              onTap: () {
                Navigator.pop(context); // Drawer'ı kapat
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TechnicianPanel()),
                );
              },
            ),

          // Personel Paneli
          if (_currentAdmin!.role == AdminRole.staff)
            ListTile(
              leading: const Icon(Icons.support_agent),
              title: const Text('Personel Paneli'),
              onTap: () {
                Navigator.pop(context); // Drawer'ı kapat
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StaffPanel()),
                );
              },
            ),

          const Divider(),

          // Duyuru Gönder
          if (_currentAdmin!.hasPermission(AdminPermission.sendNotifications))
            ListTile(
              leading: const Icon(Icons.campaign),
              title: const Text('Duyuru Gönder'),
              onTap: () {
                Navigator.pop(context); // Drawer'ı kapat
                _showSendAnnouncementDialog();
              },
            ),

          // Çıkış Yap
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Çıkış Yap'),
            onTap: () {
              Navigator.pop(context); // Drawer'ı kapat
              _logout();
            },
          ),
        ],
      ),
    );
  }

  // Kontrol paneli içeriği
  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Karşılama mesajı
          Text(
            'Hoş Geldiniz, ${_currentAdmin!.fullName}',
            style: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8.0),

          Text(
            'Rol: ${_getAdminRoleName(_currentAdmin!.role)}',
            style: const TextStyle(
              fontSize: 14.0,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24.0),

          // İstatistik kartları
          _buildStatsCards(),
          const SizedBox(height: 24.0),

          // Hızlı erişim butonları
          _buildQuickActionButtons(),
          const SizedBox(height: 24.0),

          // Arızalı makineler listesi
          _buildOutOfOrderMachines(),
        ],
      ),
    );
  }

  // İstatistik kartları
  Widget _buildStatsCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sistem Durumu',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16.0),

        // İlk sıra - Makine ve kullanıcı sayıları
        Row(
          children: [
            // Toplam Makine Sayısı
            Expanded(
              child: _buildStatCard(
                title: 'Toplam Makine',
                value: '${_dashboardStats['totalMachines'] ?? 0}',
                icon: Icons.local_laundry_service,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 16.0),

            // Toplam Kullanıcı Sayısı
            Expanded(
              child: _buildStatCard(
                title: 'Toplam Kullanıcı',
                value: '${_dashboardStats['totalUsers'] ?? 0}',
                icon: Icons.people,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),

        // İkinci sıra - Kullanımda ve arızalı makine sayıları
        Row(
          children: [
            // Kullanımdaki Makineler
            Expanded(
              child: _buildStatCard(
                title: 'Kullanımda',
                value: '${_dashboardStats['inUseMachines'] ?? 0}',
                icon: Icons.hourglass_bottom,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 16.0),

            // Arızalı Makineler
            Expanded(
              child: _buildStatCard(
                title: 'Arızalı',
                value: '${_dashboardStats['outOfOrderMachines'] ?? 0}',
                icon: Icons.error_outline,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),

        // Üçüncü sıra - Kullanım istatistikleri
        if (_dashboardStats.containsKey('usageLastMonth'))
          Row(
            children: [
              // Son Aydaki Kullanım
              Expanded(
                child: _buildStatCard(
                  title: 'Son Ay Kullanım',
                  value: '${_dashboardStats['usageLastMonth'] ?? 0}',
                  icon: Icons.insights,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(width: 16.0),

              // Ortalama Günlük Kullanım
              Expanded(
                child: _buildStatCard(
                  title: 'Kullanım Oranı',
                  value: '%${(_dashboardStats['utilization'] ?? 0).toStringAsFixed(1)}',
                  icon: Icons.show_chart,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
      ],
    );
  }

  // İstatistik kartı widget'ı
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14.0,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Hızlı erişim butonları
  Widget _buildQuickActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hızlı İşlemler',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16.0),

        Wrap(
          spacing: 12.0,
          runSpacing: 12.0,
          children: [
            // Makine ekle butonu
            if (_currentAdmin!.hasPermission(AdminPermission.manageMachines))
              _buildActionButton(
                title: 'Makine Ekle',
                icon: Icons.add_circle,
                color: AppColors.primary,
                onTap: () {
                  // Makine ekleme dialogu göster
                  _showAddMachineDialog();
                },
              ),

            // Kullanıcı ekle butonu
            if (_currentAdmin!.hasPermission(AdminPermission.manageUsers))
              _buildActionButton(
                title: 'Kullanıcı Ekle',
                icon: Icons.person_add,
                color: Colors.green,
                onTap: () {
                  // Kullanıcı ekleme dialogu göster
                  _showAddUserDialog();
                },
              ),

            // Bakım planla butonu
            if (_currentAdmin!.hasPermission(AdminPermission.assignTechnicians))
              _buildActionButton(
                title: 'Bakım Planla',
                icon: Icons.calendar_today,
                color: Colors.orange,
                onTap: () {
                  // Bakım planlama sayfasına git
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MaintenanceSchedulePage()),
                  );
                },
              ),

            // Duyuru gönder butonu
            if (_currentAdmin!.hasPermission(AdminPermission.sendNotifications))
              _buildActionButton(
                title: 'Duyuru Gönder',
                icon: Icons.campaign,
                color: Colors.blue,
                onTap: () {
                  // Duyuru gönderme dialogu göster
                  _showSendAnnouncementDialog();
                },
              ),

            // Bakımı yapıldı olarak işaretle (teknisyenler için)
            if (_currentAdmin!.role == AdminRole.technician)
              _buildActionButton(
                title: 'Bakım Yap',
                icon: Icons.build,
                color: Colors.purple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TechnicianPanel()),
                  );
                },
              ),
          ],
        ),
      ],
    );
  }

  // Aksiyon butonu widget'ı
  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        width: 120,
        height: 100,
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8.0),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Arızalı makineler widget'ı
  Widget _buildOutOfOrderMachines() {
    if (_outOfOrderMachines.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Arızalı Makineler',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16.0),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _outOfOrderMachines.length,
          itemBuilder: (context, index) {
            final machine = _outOfOrderMachines[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 8.0),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.red.shade100,
                  child: Icon(
                    machine.type == MachineType.washer
                        ? Icons.local_laundry_service
                        : Icons.dry,
                    color: Colors.red,
                  ),
                ),
                title: Text(machine.name),
                subtitle: Text(
                    'Son bakım: ${machine.lastMaintenanceDate != null
                        ? '${machine.lastMaintenanceDate!.day}.${machine.lastMaintenanceDate!.month}.${machine.lastMaintenanceDate!.year}'
                        : 'Bilgi yok'}'
                ),
                trailing: _currentAdmin!.role == AdminRole.technician
                    ? ElevatedButton(
                  onPressed: () => _showServiceMachineDialog(machine),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Bakım Yap'),
                )
                    : const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showMachineDetails(machine),
              ),
            );
          },
        ),
      ],
    );
  }

  // Makine bakımı yapma dialogu
  void _showServiceMachineDialog(Machine machine) {
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${machine.name} Bakımı'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bakım notları:'),
            const SizedBox(height: 8.0),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Yapılan işlemleri ve değiştirilen parçaları giriniz...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (notesController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lütfen bakım notlarını giriniz'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              try {
                // Bakım işlemini kaydet
                _adminService.serviceMachine(
                    machine.id,
                    notesController.text
                );

                Navigator.pop(context);

                // Verileri yenile
                _loadData();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${machine.name} bakımı tamamlandı'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Hata: ${e.toString()}'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Bakımı Tamamla'),
          ),
        ],
      ),
    );
  }

  // Makine detaylarını göster
  void _showMachineDetails(Machine machine) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              machine.type == MachineType.washer
                  ? Icons.local_laundry_service
                  : Icons.dry,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8.0),
            Text(machine.name),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              _buildDetailItem('Durum', _getMachineStatusText(machine.status)),
              _buildDetailItem('Tip', machine.type == MachineType.washer
                  ? 'Çamaşır Makinesi'
                  : 'Kurutma Makinesi'),
              _buildDetailItem('Son Bakım', machine.lastMaintenanceDate != null
                  ? '${machine.lastMaintenanceDate!.day}.${machine.lastMaintenanceDate!.month}.${machine.lastMaintenanceDate!.year}'
                  : 'Bilgi yok'),
              _buildDetailItem('Yapan Teknisyen', machine.lastMaintenanceBy ?? 'Bilgi yok'),
              _buildDetailItem('Bakım Notları', machine.maintenanceNotes ?? 'Not girilmemiş'),
              _buildDetailItem('Toplam Kullanım', '${machine.usageCount ?? 0} kez'),
              _buildDetailItem('Sağlık Puanı', '${machine.calculateHealthScore()} / 100'),

              if (machine.errorCount != null && machine.errorCount! > 0)
                _buildDetailItem('Toplam Arıza', '${machine.errorCount} kez'),

              if (machine.serialNumber != null)
                _buildDetailItem('Seri No', machine.serialNumber!),

              if (machine.model != null)
                _buildDetailItem('Model', machine.model!),

              if (machine.manufacturer != null)
                _buildDetailItem('Üretici', machine.manufacturer!),

              if (machine.installationDate != null)
                _buildDetailItem('Kurulum Tarihi', '${machine.installationDate!.day}.${machine.installationDate!.month}.${machine.installationDate!.year}'),

              if (machine.purchaseDate != null)
                _buildDetailItem('Satın Alma Tarihi', '${machine.purchaseDate!.day}.${machine.purchaseDate!.month}.${machine.purchaseDate!.year}'),

              if (machine.warrantyEndDate != null)
                _buildDetailItem('Garanti Bitiş', '${machine.warrantyEndDate!.day}.${machine.warrantyEndDate!.month}.${machine.warrantyEndDate!.year}'),

              if (machine.location != null)
                _buildDetailItem('Konum', machine.location!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
          if (_currentAdmin!.role == AdminRole.technician)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showServiceMachineDialog(machine);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Bakım Yap'),
            ),
        ],
      ),
    );
  }

  // Makine detay öğesi
  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Admin rolünü metin olarak döndür
  String _getAdminRoleName(AdminRole? role) {
    if (role == null) return '';

    switch (role) {
      case AdminRole.superAdmin:
        return 'Sistem Yöneticisi';
      case AdminRole.manager:
        return 'Yurt Müdürü';
      case AdminRole.staff:
        return 'Yurt Personeli';
      case AdminRole.technician:
        return 'Teknisyen';
      default:
        return '';
    }
  }

  // Makine durumunu metin olarak döndür
  String _getMachineStatusText(MachineStatus status) {
    switch (status) {
      case MachineStatus.available:
        return 'Kullanılabilir';
      case MachineStatus.inUse:
        return 'Kullanımda';
      case MachineStatus.outOfOrder:
        return 'Arızalı';
      default:
        return '';
    }
  }

  // Bildirim ikonunu döndür
  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.maintenance:
        return Icons.engineering;
      case NotificationType.maintenanceAssignment:
        return Icons.build;
      case NotificationType.announcement:
        return Icons.campaign;
      case NotificationType.emergency:
        return Icons.warning;
      case NotificationType.systemUpdate:
        return Icons.system_update;
      default:
        return Icons.notifications;
    }
  }

  // Bildirim rengini döndür
  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.maintenance:
        return Colors.orange;
      case NotificationType.maintenanceAssignment:
        return Colors.blue;
      case NotificationType.announcement:
        return AppColors.primary;
      case NotificationType.emergency:
        return Colors.red;
      case NotificationType.systemUpdate:
        return Colors.purple;
      default:
        return AppColors.textSecondary;
    }
  }
}
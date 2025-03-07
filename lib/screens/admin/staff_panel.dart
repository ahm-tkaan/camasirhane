import 'package:flutter/material.dart';
import '../../models/admin.dart';
import '../../models/machine.dart';
import '../../models/user.dart';
import '../../services/admin_service.dart';
import '../../services/notification_service.dart';
import '../../services/user_service.dart';
import '../../utils/constants.dart';

class StaffPanel extends StatefulWidget {
  const StaffPanel({Key? key}) : super(key: key);

  @override
  _StaffPanelState createState() => _StaffPanelState();
}

class _StaffPanelState extends State<StaffPanel> with SingleTickerProviderStateMixin {
  final AdminService _adminService = AdminService();
  final UserService _userService = UserService();
  final NotificationService _notificationService = NotificationService();

  late TabController _tabController;
  bool _isLoading = true;
  Admin? _currentStaff;
  List<User> _activeUsers = [];
  List<Machine> _machines = [];
  Map<String, dynamic> _dashboardStats = {};
  List<String> _dormitories = [];
  String? _selectedDormitory;

  // İstatistikler
  int _totalUsers = 0;
  int _totalMachines = 0;
  int _availableMachines = 0;
  int _inUseMachines = 0;
  int _outOfOrderMachines = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Verileri yükle
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Mevcut personeli al
      _currentStaff = _adminService.getCurrentAdmin();
      if (_currentStaff == null || _currentStaff!.role != AdminRole.staff) {
        // Eğer personel değilse, uygun bir hata göster
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bu sayfaya erişim yetkiniz yok'),
            backgroundColor: AppColors.error,
          ),
        );
        Navigator.pop(context);
        return;
      }

      // İstatistikleri al
      _dashboardStats = _adminService.getDashboardStats();

      // Kullanıcıları al
      _activeUsers = _userService.getAllUsers()
          .where((user) => user.isActive)
          .toList();

      // Makineleri al
      _machines = _adminService.getAllMachines();

      // Yurt listesini oluştur
      _dormitories = _activeUsers
          .where((user) => user.dormitoryId != null)
          .map((user) => user.dormitoryId!)
          .toSet()
          .toList();

      // İstatistikleri hesapla
      _totalUsers = _activeUsers.length;
      _totalMachines = _machines.length;
      _availableMachines = _machines.where((m) => m.status == MachineStatus.available).length;
      _inUseMachines = _machines.where((m) => m.status == MachineStatus.inUse).length;
      _outOfOrderMachines = _machines.where((m) => m.status == MachineStatus.outOfOrder).length;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personel Paneli'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Genel Durum'),
            Tab(text: 'Kullanıcılar'),
          ],
        ),
        actions: [
          // Duyuru gönderme butonu
          IconButton(
            icon: const Icon(Icons.campaign),
            tooltip: 'Duyuru Gönder',
            onPressed: _showSendAnnouncementDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          // Genel Durum Tab
          _buildDashboardTab(),

          // Kullanıcılar Tab
          _buildUsersTab(),
        ],
      ),
    );
  }

  // Genel durum tab'i
  Widget _buildDashboardTab() {
    return RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    // İstatistik kartları
    Text(
    'Hoş Geldiniz, ${_currentStaff!.fullName}',
    style: const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    ),
    ),
    const SizedBox(height: 4),
    Text(
    DateTime.now().toString().substring(0, 10),
    style: const TextStyle(
    color: AppColors.textSecondary,
    ),
    ),
    const SizedBox(height: 16),

    // Kullanıcı sayıları
    _buildStatsCard(
    title: 'Kullanıcılar',
    value: _totalUsers.toString(),
    icon: Icons.people,
    color: Colors.blue,
    subtitle: 'Aktif öğrenci sayısı',
    ),
    const SizedBox(height: 16),

    // Makine sayıları
    const Text(
    'Makine Durumu',
    style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    ),
    ),
    const SizedBox(height: 8),
    Row(
    children: [
    Expanded(
    child: _buildStatsCard(
    title: 'Toplam',
    value: _totalMachines.toString(),
    icon: Icons.local_laundry_service,
    color: Colors.grey,
    subtitle: 'Makine',
    ),
    ),
    const SizedBox(width: 16),
    Expanded(
    child: _buildStatsCard(
    title: 'Müsait',
    value: _availableMachines.toString(),
    icon: Icons.check_circle,
    color: Colors.green,
    subtitle: 'Makine',
    ),
    ),
    ],
    ),
    const SizedBox(height: 16),
    Row(
    children: [
    Expanded(
    child: _buildStatsCard(
    title: 'Kullanımda',
    value: _inUseMachines.toString(),
    icon: Icons.access_time,
    color: Colors.orange,
    subtitle: 'Makine',
    ),
    ),
    const SizedBox(width: 16),
      Expanded(
        child: _buildStatsCard(
          title: 'Arızalı',
          value: _outOfOrderMachines.toString(),
          icon: Icons.error_outline,
          color: Colors.red,
          subtitle: 'Makine',
        ),
      ),
    ],
    ),
      const SizedBox(height: 24),

      // Hızlı işlemler
      const Text(
        'Hızlı İşlemler',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: _buildActionButton(
              title: 'Duyuru Gönder',
              icon: Icons.campaign,
              color: AppColors.primary,
              onTap: _showSendAnnouncementDialog,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildActionButton(
              title: 'Bakım Talebi',
              icon: Icons.build,
              color: Colors.orange,
              onTap: _showMaintenanceRequestDialog,
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: _buildActionButton(
              title: 'Acil Duyuru',
              icon: Icons.warning,
              color: Colors.red,
              onTap: () => _showSendAnnouncementDialog(isEmergency: true),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildActionButton(
              title: 'Rapor Oluştur',
              icon: Icons.assessment,
              color: Colors.purple,
              onTap: _showReportDialog,
            ),
          ),
        ],
      ),
      const SizedBox(height: 24),

      // Doluluk grafiği
      const Text(
        'Günlük Çamaşırhane Doluluk Tahmini',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 16),
      Container(
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.border,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'Bu kısımda çamaşırhane doluluk grafiği gösterilecek',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
        ),
      ),
    ],
    ),
        ),
    );
  }

  // Kullanıcılar tab'i
  Widget _buildUsersTab() {
    // Yurda göre filtrelenmiş kullanıcı listesi
    List<User> filteredUsers = _selectedDormitory != null
        ? _activeUsers.where((user) => user.dormitoryId == _selectedDormitory).toList()
        : _activeUsers;

    return Column(
      children: [
        // Yurt seçimi
        if (_dormitories.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String?>(
              decoration: const InputDecoration(
                labelText: 'Yurt Seçimi',
                border: OutlineInputBorder(),
              ),
              value: _selectedDormitory,
              hint: const Text('Tüm Yurtlar'),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Tüm Yurtlar'),
                ),
                ..._dormitories.map((dormitory) => DropdownMenuItem<String?>(
                  value: dormitory,
                  child: Text(dormitory),
                )).toList(),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedDormitory = value;
                });
              },
            ),
          ),

        // Kullanıcı sayısı
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Toplam ${filteredUsers.length} kullanıcı',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: _showSendMessageDialog,
                icon: const Icon(Icons.message, size: 18),
                label: const Text('Mesaj Gönder'),
              ),
            ],
          ),
        ),

        // Kullanıcı listesi
        Expanded(
          child: filteredUsers.isEmpty
              ? const Center(
            child: Text('Kullanıcı bulunamadı'),
          )
              : RefreshIndicator(
            onRefresh: _loadData,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                final user = filteredUsers[index];
                return _buildUserCard(user);
              },
            ),
          ),
        ),
      ],
    );
  }

  // İstatistik kartı
  Widget _buildStatsCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // İşlem butonu
  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 80,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Kullanıcı kartı
  Widget _buildUserCard(User user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Text(
            user.profileInitials ?? 'A',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(user.fullName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Öğrenci No: ${user.studentId}'),
            if (user.roomNumber != null)
              Text('Oda: ${user.roomNumber}'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.message),
          onPressed: () => _showSendMessageToUserDialog(user),
          tooltip: 'Mesaj Gönder',
        ),
        onTap: () => _showUserDetails(user),
      ),
    );
  }

  // Kullanıcı detayları
  void _showUserDetails(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Text(
                user.profileInitials ?? 'A',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                user.fullName,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              _buildDetailItem('Öğrenci No', user.studentId),
              if (user.phoneNumber != null)
                _buildDetailItem('Telefon', user.phoneNumber!),
              if (user.dormitoryId != null)
                _buildDetailItem('Yurt', user.dormitoryId!),
              if (user.roomNumber != null)
                _buildDetailItem('Oda No', user.roomNumber!),
              _buildDetailItem('Toplam Kullanım', '${user.usageCount ?? 0} kez'),

              if (user.lastUsageDate != null)
                _buildDetailItem('Son Kullanım', '${_formatDate(user.lastUsageDate!)}'),

              // Kullanım istatistikleri
              if (user.usageStats != null && user.usageStats!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Kullanım İstatistikleri',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                ...user.usageStats!.entries.map((entry) =>
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Text(
                            entry.key == 'washer' ? 'Çamaşır Makinesi:' : 'Kurutma Makinesi:',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('${entry.value} kez'),
                        ],
                      ),
                    ),
                ).toList(),
              ],

              // İşlemler
              const SizedBox(height: 16),
              const Text(
                'İşlemler',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ActionChip(
                    label: const Text('Mesaj Gönder'),
                    avatar: const Icon(Icons.message, size: 16),
                    onPressed: () {
                      Navigator.pop(context);
                      _showSendMessageToUserDialog(user);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  // Duyuru gönderme dialogu
  void _showSendAnnouncementDialog({bool isEmergency = false}) {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    String? selectedDormitory = _selectedDormitory;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEmergency ? 'Acil Duyuru Gönder' : 'Duyuru Gönder'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Başlık',
                    hintText: 'Örn: ${isEmergency ? "ACİL - Su Kesintisi" : "Bakım Bildirimi"}',
                  ),
                ),
                const SizedBox(height: 16),

                // Mesaj
                TextField(
                  controller: messageController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Mesaj',
                    hintText: 'Örn: ${isEmergency ? "Acil su kesintisi nedeniyle çamaşırhane geçici olarak kapatılmıştır." : "Yarın saat 10:00-12:00 arası çamaşırhane bakım nedeniyle kapalı olacaktır."}',
                  ),
                ),
                const SizedBox(height: 16),

                // Yurt seçimi
                if (_dormitories.isNotEmpty && !isEmergency) ...[
                  const Text('Yurt Seçimi:'),
                  const SizedBox(height: 8),
                  DropdownButton<String?>(
                    isExpanded: true,
                    value: selectedDormitory,
                    hint: const Text('Tüm Yurtlar'),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Tüm Yurtlar'),
                      ),
                      ..._dormitories.map((dormitory) => DropdownMenuItem<String?>(
                        value: dormitory,
                        child: Text(dormitory),
                      )).toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedDormitory = value;
                      });
                    },
                  ),
                ],

                if (isEmergency)
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Bu duyuru TÜM öğrencilere acil durum bildirimi olarak gönderilecektir!',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              style: isEmergency
                  ? ElevatedButton.styleFrom(backgroundColor: Colors.red)
                  : null,
              onPressed: () {
                if (titleController.text.isEmpty || messageController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lütfen başlık ve mesaj alanlarını doldurun'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                try {
                  if (isEmergency) {
                    // Acil duyuru gönder
                    _notificationService.sendEmergencyBroadcast(
                      titleController.text,
                      messageController.text,
                    );
                  } else if (selectedDormitory != null) {
                    // Belirli bir yurda duyuru gönder
                    _notificationService.sendNotificationToDormitory(
                      selectedDormitory ?? '',
                      titleController.text,
                      messageController.text,
                    );
                  } else {
                    // Tüm öğrencilere duyuru gönder
                    _adminService.sendAnnouncementToAllUsers(
                      titleController.text,
                      messageController.text,
                    );
                  }

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isEmergency
                          ? 'Acil duyuru tüm öğrencilere gönderildi'
                          : selectedDormitory != null
                          ? 'Duyuru $selectedDormitory yurdundaki öğrencilere gönderildi'
                          : 'Duyuru tüm öğrencilere gönderildi'),
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
              child: Text(isEmergency ? 'Acil Duyuru Gönder' : 'Duyuru Gönder'),
            ),
          ],
        ),
      ),
    );
  }

  // Bakım talebi oluşturma dialogu
  void _showMaintenanceRequestDialog() {
    final machineController = TextEditingController();
    final notesController = TextEditingController();
    Machine? selectedMachine;

    // Arızalı olmayan makineler
    final availableMachines = _machines.where((m) => m.status != MachineStatus.outOfOrder).toList();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Bakım Talebi Oluştur'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Makine seçimi
                const Text('Makine:'),
                const SizedBox(height: 8),
                DropdownButton<Machine>(
                  isExpanded: true,
                  value: selectedMachine,
                  hint: const Text('Makine Seçin'),
                  items: availableMachines.map((machine) => DropdownMenuItem<Machine>(
                    value: machine,
                    child: Text(machine.name),
                  )).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedMachine = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Arıza notu
                const Text('Arıza Açıklaması:'),
                const SizedBox(height: 8),
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Arızayı detaylı olarak açıklayın...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedMachine == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lütfen bir makine seçin'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                if (notesController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lütfen arıza açıklaması girin'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                try {
                  // Makineyi arızalı olarak işaretle
                  selectedMachine!.reportOutOfOrder();

                  // Bakım bildirimi gönder
                  _notificationService.sendMaintenanceAlert(selectedMachine!);

                  Navigator.pop(context);

                  // Verileri yenile
                  _loadData();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${selectedMachine!.name} için bakım talebi oluşturuldu'),
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
              child: const Text('Talebi Oluştur'),
            ),
          ],
        ),
      ),
    );
  }

  // Rapor oluşturma dialogu
  void _showReportDialog() {
    String selectedReport = 'daily';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Rapor Oluştur'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Rapor Türü:'),
              const SizedBox(height: 8),
              RadioListTile<String>(
                title: const Text('Günlük Rapor'),
                value: 'daily',
                groupValue: selectedReport,
                onChanged: (value) {
                  setState(() {
                    selectedReport = value!;
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text('Haftalık Rapor'),
                value: 'weekly',
                groupValue: selectedReport,
                onChanged: (value) {
                  setState(() {
                    selectedReport = value!;
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text('Aylık Rapor'),
                value: 'monthly',
                groupValue: selectedReport,
                onChanged: (value) {
                  setState(() {
                    selectedReport = value!;
                  });
                },
              ),
              const SizedBox(height: 8),
              const Text(
                'Not: Bu rapor, çamaşırhane kullanımı, makine durumları ve bakım geçmişini içerecektir.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
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
                Navigator.pop(context);

                // Raporun oluşturulduğu bilgisini göster
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Rapor oluşturuldu ve e-posta adresinize gönderildi'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              child: const Text('Rapor Oluştur'),
            ),
          ],
        ),
      ),
    );
  }

  // Tüm kullanıcılara mesaj gönderme dialogu
  void _showSendMessageDialog() {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    String? selectedDormitory = _selectedDormitory;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Kullanıcılara Mesaj Gönder'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Başlık',
                    hintText: 'Örn: Bilgilendirme',
                  ),
                ),
                const SizedBox(height: 16),

                // Mesaj
                TextField(
                  controller: messageController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Mesaj',
                    hintText: 'Mesajınızı buraya yazın...',
                  ),
                ),
                const SizedBox(height: 16),

                // Yurt seçimi
                if (_dormitories.isNotEmpty) ...[
                  const Text('Yurt Seçimi:'),
                  const SizedBox(height: 8),
                  DropdownButton<String?>(
                    isExpanded: true,
                    value: selectedDormitory,
                    hint: const Text('Tüm Yurtlar'),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Tüm Yurtlar'),
                      ),
                      ..._dormitories.map((dormitory) => DropdownMenuItem<String?>(
                        value: dormitory,
                        child: Text(dormitory),
                      )).toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedDormitory = value;
                      });
                    },
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isEmpty || messageController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lütfen başlık ve mesaj alanlarını doldurun'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                try {
                  if (selectedDormitory != null) {
                    // Belirli bir yurttaki kullanıcılara mesaj gönder
                    _notificationService.sendNotificationToDormitory(
                      selectedDormitory ?? '',
                      titleController.text,
                      messageController.text,
                    );
                  } else {
                    // Tüm kullanıcılara mesaj gönder
                    _adminService.sendAnnouncementToAllUsers(
                      titleController.text,
                      messageController.text,
                    );
                  }

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(selectedDormitory != null
                          ? 'Mesaj $selectedDormitory yurdundaki öğrencilere gönderildi'
                          : 'Mesaj tüm öğrencilere gönderildi'),
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
      ),
    );
  }

  // Belirli bir kullanıcıya mesaj gönderme dialogu
  void _showSendMessageToUserDialog(User user) {
    final titleController = TextEditingController();
    final messageController = TextEditingController();

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
        title: Text('${user.fullName} kullanıcısına mesaj gönder'),
    content: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
    TextField(
    controller: titleController,
    decoration: const InputDecoration(
    labelText: 'Başlık',
    hintText: 'Örn: Bilgilendirme',
    ),
    ),
    const SizedBox(height: 16),
    TextField(
    controller: messageController,
    maxLines: 3,
      decoration: const InputDecoration(
        labelText: 'Mesaj',
        hintText: 'Mesajınızı buraya yazın...',
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
                if (titleController.text.isEmpty || messageController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lütfen başlık ve mesaj alanlarını doldurun'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                try {
                  // Kullanıcıya mesaj gönder
                  _notificationService.sendEmergencyNotification(
                    user.id,
                    titleController.text,
                    messageController.text,
                  );

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Mesaj ${user.fullName} kullanıcısına gönderildi'),
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

  // Detay öğesi widget'ı
  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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

  // Tarih formatla
  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
}
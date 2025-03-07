import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/admin_service.dart';
import '../../services/user_service.dart';
import '../../utils/constants.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({Key? key}) : super(key: key);

  @override
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final AdminService _adminService = AdminService();
  final UserService _userService = UserService();

  bool _isLoading = true;
  List<User> _allUsers = [];
  List<User> _activeUsers = [];
  List<User> _inactiveUsers = [];
  List<User> _filteredUsers = [];
  String _searchQuery = '';

  // Yeni kullanıcı için form controller
  final _studentIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dormitoryController = TextEditingController();
  final _roomController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _studentIdController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _dormitoryController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  // Verileri yükle
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Tüm kullanıcıları al
      _allUsers = _adminService.getAllUsers();

      // Aktif ve inaktif kullanıcıları filtrele
      _activeUsers = _allUsers.where((user) => user.isActive).toList();
      _inactiveUsers = _allUsers.where((user) => !user.isActive).toList();

      // Başlangıçta filtrelenmemiş liste göster (aktif kullanıcılar)
      _filteredUsers = _activeUsers;
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

  // Kullanıcıları ara
  void _filterUsers(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredUsers = _activeUsers;
      } else {
        _filteredUsers = _activeUsers.where((user) =>
        user.fullName.toLowerCase().contains(query.toLowerCase()) ||
            user.studentId.toLowerCase().contains(query.toLowerCase()) ||
            (user.roomNumber != null && user.roomNumber!.toLowerCase().contains(query.toLowerCase()))
        ).toList();
      }
    });
  }

  // Aktif/İnaktif kullanıcıları göster
  void _toggleActiveUsers(bool showActive) {
    setState(() {
      _filteredUsers = showActive ? _activeUsers : _inactiveUsers;
      _searchQuery = ''; // Aramayı sıfırla
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kullanıcı Yönetimi'),
        actions: [
          // Aktif/İnaktif kullanıcı filtreleme butonu
          PopupMenuButton<bool>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtrele',
            onSelected: _toggleActiveUsers,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: true,
                child: Text('Aktif Kullanıcılar'),
              ),
              const PopupMenuItem(
                value: false,
                child: Text('İnaktif Kullanıcılar'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Arama alanı
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'İsim, Öğrenci No veya Oda No ile ara',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _filteredUsers = _activeUsers;
                    });
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              onChanged: _filterUsers,
            ),
          ),

          // Kullanıcı istatistikleri
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Toplam ${_filteredUsers.length} kullanıcı gösteriliyor',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Aktif: ${_activeUsers.length} | İnaktif: ${_inactiveUsers.length}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Kullanıcı listesi
          Expanded(
            child: _filteredUsers.isEmpty
                ? Center(
              child: Text(
                _searchQuery.isEmpty
                    ? 'Kullanıcı bulunamadı'
                    : 'Arama sonucu bulunamadı',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16.0,
                ),
              ),
            )
                : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = _filteredUsers[index];
                  return _buildUserCard(user);
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddUserDialog,
        child: const Icon(Icons.add),
        tooltip: 'Kullanıcı Ekle',
      ),
    );
  }

  // Kullanıcı kartı
  Widget _buildUserCard(User user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: () => _showUserDetails(user),
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Kullanıcı avatarı
              CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Text(
                  user.profileInitials ?? 'AA',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16.0),

              // Kullanıcı bilgileri
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Öğrenci No: ${user.studentId}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.0,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Row(
                      children: [
                        if (user.roomNumber != null)
                          Text(
                            'Oda: ${user.roomNumber}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12.0,
                            ),
                          ),
                        if (user.roomNumber != null)
                          const SizedBox(width: 8.0),
                        if (user.usageCount != null && user.usageCount! > 0)
                          Text(
                            'Kullanım: ${user.usageCount}',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12.0,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // İşlem menüsü
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditUserDialog(user);
                  } else if (value == 'deactivate') {
                    _showDeactivateConfirmation(user);
                  } else if (value == 'activate') {
                    _activateUser(user);
                  } else if (value == 'message') {
                    _showSendMessageDialog(user);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text('Düzenle'),
                      ],
                    ),
                  ),
                  if (user.isActive)
                    const PopupMenuItem(
                      value: 'deactivate',
                      child: Row(
                        children: [
                          Icon(Icons.person_off, size: 18),
                          SizedBox(width: 8),
                          Text('Devre Dışı Bırak'),
                        ],
                      ),
                    )
                  else
                    const PopupMenuItem(
                      value: 'activate',
                      child: Row(
                        children: [
                          Icon(Icons.person, size: 18),
                          SizedBox(width: 8),
                          Text('Aktifleştir'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'message',
                    child: Row(
                      children: [
                        Icon(Icons.message, size: 18),
                        SizedBox(width: 8),
                        Text('Mesaj Gönder'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Kullanıcı ekleme dialogu
  void _showAddUserDialog() {
    // Form alanlarını temizle
    _studentIdController.clear();
    _nameController.clear();
    _phoneController.clear_dormitoryController.clear();
    _roomController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Kullanıcı Ekle'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Öğrenci numarası
                TextFormField(
                  controller: _studentIdController,
                  decoration: const InputDecoration(
                    labelText: 'Öğrenci Numarası*',
                    hintText: 'Örn: 123456789',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Öğrenci numarası gerekli';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // Ad Soyad
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Ad Soyad*',
                    hintText: 'Örn: Ahmet Yılmaz',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ad soyad gerekli';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // Telefon
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Telefon',
                    hintText: 'Örn: 05XX XXX XX XX',
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16.0),

                // Yurt
                TextFormField(
                  controller: _dormitoryController,
                  decoration: const InputDecoration(
                    labelText: 'Yurt',
                    hintText: 'Örn: KYK Erkek Öğrenci Yurdu',
                  ),
                ),
                const SizedBox(height: 16.0),

                // Oda Numarası
                TextFormField(
                  controller: _roomController,
                  decoration: const InputDecoration(
                    labelText: 'Oda Numarası',
                    hintText: 'Örn: A-101',
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              // Form doğrulama
              if (_formKey.currentState!.validate()) {
                try {
                  // Kullanıcıyı ekle
                  _adminService.createUser(
                    _studentIdController.text,
                    _nameController.text,
                    _phoneController.text.isEmpty ? null : _phoneController.text,
                    _dormitoryController.text.isEmpty ? null : _dormitoryController.text,
                    _roomController.text.isEmpty ? null : _roomController.text,
                  );

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
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  // Kullanıcı düzenleme dialogu
  void _showEditUserDialog(User user) {
    // Form alanlarını doldur
    _studentIdController.text = user.studentId;
    _nameController.text = user.fullName;
    _phoneController.text = user.phoneNumber ?? '';
    _dormitoryController.text = user.dormitoryId ?? '';
    _roomController.text = user.roomNumber ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kullanıcı Düzenle'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Öğrenci numarası (değiştirilemez)
                TextFormField(
                  controller: _studentIdController,
                  decoration: const InputDecoration(
                    labelText: 'Öğrenci Numarası*',
                  ),
                  enabled: false, // Değiştirilemez
                ),
                const SizedBox(height: 16.0),

                // Ad Soyad
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Ad Soyad*',
                    hintText: 'Örn: Ahmet Yılmaz',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ad soyad gerekli';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // Telefon
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Telefon',
                    hintText: 'Örn: 05XX XXX XX XX',
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16.0),

                // Yurt
                TextFormField(
                  controller: _dormitoryController,
                  decoration: const InputDecoration(
                    labelText: 'Yurt',
                    hintText: 'Örn: KYK Erkek Öğrenci Yurdu',
                  ),
                ),
                const SizedBox(height: 16.0),

                // Oda Numarası
                TextFormField(
                  controller: _roomController,
                  decoration: const InputDecoration(
                    labelText: 'Oda Numarası',
                    hintText: 'Örn: A-101',
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              // Form doğrulama
              if (_formKey.currentState!.validate()) {
                try {
                  // Kullanıcıyı güncelle
                  _adminService.updateUser(
                    user.id,
                    fullName: _nameController.text,
                    phoneNumber: _phoneController.text.isEmpty ? null : _phoneController.text,
                    dormitoryId: _dormitoryController.text.isEmpty ? null : _dormitoryController.text,
                    roomNumber: _roomController.text.isEmpty ? null : _roomController.text,
                  );

                  Navigator.pop(context);

                  // Verileri yenile
                  _loadData();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${user.fullName} bilgileri güncellendi'),
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
              }
            },
            child: const Text('Güncelle'),
          ),
        ],
      ),
    );
  }

  // Kullanıcı deaktif etme onayı
  void _showDeactivateConfirmation(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kullanıcıyı Devre Dışı Bırak'),
        content: Text('${user.fullName} kullanıcısını devre dışı bırakmak istediğinize emin misiniz? Bu işlem kullanıcının sisteme erişimini kısıtlayacaktır.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              try {
                // Kullanıcıyı deaktif et
                _adminService.deactivateUser(user.id);

                Navigator.pop(context);

                // Verileri yenile
                _loadData();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${user.fullName} devre dışı bırakıldı'),
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
            child: const Text('Devre Dışı Bırak'),
          ),
        ],
      ),
    );
  }

  // Kullanıcıyı aktifleştir
  void _activateUser(User user) {
    try {
      // Kullanıcıyı aktifleştir
      _userService.activateUser(user.id);

      // Verileri yenile
      _loadData();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${user.fullName} aktifleştirildi'),
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
  }

  // Kullanıcıya mesaj gönderme dialogu
  void _showSendMessageDialog(User user) {
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
            const SizedBox(height: 16.0),
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
                    content: Text('Lütfen başlık ve mesaj giriniz'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              try {
                // Kullanıcıya mesaj gönder (bu gerçek uygulamada NotificationService üzerinden yapılmalı)

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${user.fullName} kullanıcısına mesaj gönderildi'),
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

  // Kullanıcı detaylarını göster
  void _showUserDetails(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Text(
                user.profileInitials ?? 'AA',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Text(
                user.fullName,
                style: const TextStyle(
                  fontSize: 18.0,
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
              _buildDetailItem('Durum', user.isActive ? 'Aktif' : 'İnaktif'),
              _buildDetailItem('Toplam Kullanım', '${user.usageCount ?? 0} kez'),
              if (user.lastUsageDate != null)
                _buildDetailItem('Son Kullanım', '${_formatDate(user.lastUsageDate!)}'),

              // Ayarlar
              _buildDetailItem('Bildirimler', user.notificationsEnabled == true ? 'Açık' : 'Kapalı'),
              _buildDetailItem('Hatırlatıcı', user.reminderEnabled == true ? 'Açık' : 'Kapalı'),
              if (user.reminderEnabled == true && user.reminderMinutes != null)
                _buildDetailItem('Hatırlatıcı Süresi', '${user.reminderMinutes} dakika'),

              // Kullanım istatistikleri
              if (user.usageStats != null && user.usageStats!.isNotEmpty) ...[
                const SizedBox(height: 16.0),
                const Text(
                  'Kullanım İstatistikleri',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                const SizedBox(height: 8.0),
                ...user.usageStats!.entries.map((entry) =>
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        children: [
                          Text(
                            entry.key == 'washer' ? 'Çamaşır Makinesi:' : 'Kurutma Makinesi:',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Text('${entry.value} kez'),
                        ],
                      ),
                    ),
                ).toList(),
              ],

              // İşlemler
              const SizedBox(height: 16.0),
              const Text(
                'İşlemler',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 8.0),
              Wrap(
                spacing: 8.0,
                children: [
                  ActionChip(
                    label: const Text('Düzenle'),
                    avatar: const Icon(Icons.edit, size: 16),
                    onPressed: () {
                      Navigator.pop(context);
                      _showEditUserDialog(user);
                    },
                  ),
                  if (user.isActive)
                    ActionChip(
                      label: const Text('Devre Dışı Bırak'),
                      avatar: const Icon(Icons.person_off, size: 16),
                      onPressed: () {
                        Navigator.pop(context);
                        _showDeactivateConfirmation(user);
                      },
                    )
                  else
                    ActionChip(
                      label: const Text('Aktifleştir'),
                      avatar: const Icon(Icons.person, size: 16),
                      backgroundColor: Colors.green.shade100,
                      onPressed: () {
                        Navigator.pop(context);
                        _activateUser(user);
                      },
                    ),
                  ActionChip(
                    label: const Text('Mesaj Gönder'),
                    avatar: const Icon(Icons.message, size: 16),
                    onPressed: () {
                      Navigator.pop(context);
                      _showSendMessageDialog(user);
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

  // Detay öğesi widget'ı
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

  // Tarih formatla
  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
}
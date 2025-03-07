import '../models/admin.dart';
import '../models/machine.dart';
import '../models/user.dart';
import 'machine_service.dart';
import 'user_service.dart';
import 'notification_service.dart';

/// Admin servisi - Admin kullanıcılarını ve işlemlerini yönetir
class AdminService {
  static final AdminService _instance = AdminService._internal();

  factory AdminService() {
    return _instance;
  }

  AdminService._internal();

  // Servisler
  final MachineService _machineService = MachineService();
  final UserService _userService = UserService();
  final NotificationService _notificationService = NotificationService();

  // Mock admin kullanıcıları listesi
  static final List<Admin> _admins = [
    Admin(
      id: 'admin1',
      username: 'super_admin',
      fullName: 'Sistem Yöneticisi',
      role: AdminRole.superAdmin,
      permissions: AdminPermission.values.toList(), // Tüm yetkiler
      email: 'admin@kyk.gov.tr',
      phoneNumber: '0555 123 45 67',
      createdAt: DateTime(2024, 1, 1),
      isActive: true,
    ),
    Admin(
      id: 'admin2',
      username: 'yurt_muduru',
      fullName: 'Ahmet Müdür',
      role: AdminRole.manager,
      permissions: Admin.getDefaultPermissions(AdminRole.manager),
      email: 'mudur@kyk.gov.tr',
      phoneNumber: '0555 234 56 78',
      createdAt: DateTime(2024, 1, 15),
      createdBy: 'admin1',
      isActive: true,
    ),
    Admin(
      id: 'admin3',
      username: 'personel1',
      fullName: 'Ayşe Personel',
      role: AdminRole.staff,
      permissions: Admin.getDefaultPermissions(AdminRole.staff),
      email: 'personel@kyk.gov.tr',
      phoneNumber: '0555 345 67 89',
      createdAt: DateTime(2024, 2, 1),
      createdBy: 'admin2',
      isActive: true,
    ),
    Admin(
      id: 'admin4',
      username: 'tekniker1',
      fullName: 'Mehmet Tekniker',
      role: AdminRole.technician,
      permissions: Admin.getDefaultPermissions(AdminRole.technician),
      email: 'tekniker@kyk.gov.tr',
      phoneNumber: '0555 456 78 90',
      createdAt: DateTime(2024, 2, 15),
      createdBy: 'admin2',
      isActive: true,
    ),
  ];

  // Mevcut admin kullanıcısı
  Admin? _currentAdmin;

  // Mevcut admin kullanıcısını ayarla (giriş yapıldığında)
  void setCurrentAdmin(String username, String password) {
    // Gerçek uygulamada, veritabanı sorgusu ve şifre doğrulaması yapılmalı
    try {
      _currentAdmin = _admins.firstWhere((admin) =>
      admin.username == username && admin.isActive);

      // Son giriş tarihini güncelle
      final index = _admins.indexWhere((admin) => admin.id == _currentAdmin!.id);
      if (index != -1) {
        _admins[index] = _currentAdmin!.copyWith(
          lastLogin: DateTime.now(),
        );
        _currentAdmin = _admins[index];
      }
    } catch (e) {
      _currentAdmin = null;
      throw Exception('Geçersiz kullanıcı adı veya şifre');
    }
  }

  // Mevcut admin kullanıcısını getir
  Admin? getCurrentAdmin() {
    return _currentAdmin;
  }

  // Oturumu kapat
  void logout() {
    _currentAdmin = null;
  }

  // Tüm admin kullanıcılarını getir
  List<Admin> getAllAdmins() {
    // Sadece süper adminler ve yurt müdürleri tüm adminleri görebilir
    if (_currentAdmin == null ||
        !(_currentAdmin!.role == AdminRole.superAdmin ||
            _currentAdmin!.role == AdminRole.manager)) {
      throw Exception('Bu işlem için yetkiniz bulunmamaktadır');
    }

    return List.from(_admins);
  }

  // ID'ye göre admin getir
  Admin? getAdminById(String id) {
    try {
      return _admins.firstWhere((admin) => admin.id == id);
    } catch (e) {
      return null;
    }
  }

  // Role göre adminleri getir
  List<Admin> getAdminsByRole(AdminRole role) {
    return _admins.where((admin) => admin.role == role).toList();
  }

  // Yeni admin kullanıcısı oluştur
  Admin createAdmin(
      String username,
      String fullName,
      AdminRole role,
      List<AdminPermission>? permissions,
      String? email,
      String? phoneNumber,
      ) {
    // Yetki kontrolü
    if (_currentAdmin == null ||
        !_currentAdmin!.hasPermission(AdminPermission.createAdmin)) {
      throw Exception('Bu işlem için yetkiniz bulunmamaktadır');
    }

    // Kullanıcı adının benzersiz olduğunu kontrol et
    if (_admins.any((admin) => admin.username == username)) {
      throw Exception('Bu kullanıcı adı zaten kullanılıyor');
    }

    // Yeni admin oluştur
    final newAdmin = Admin(
      id: 'admin${_admins.length + 1}', // Gerçek uygulamada UUID kullanılmalı
      username: username,
      fullName: fullName,
      role: role,
      permissions: permissions ?? Admin.getDefaultPermissions(role),
      email: email,
      phoneNumber: phoneNumber,
      createdAt: DateTime.now(),
      createdBy: _currentAdmin!.id,
      isActive: true,
    );

    // Listeye ekle
    _admins.add(newAdmin);

    return newAdmin;
  }

  // Admin bilgilerini güncelle
  Admin updateAdmin(
      String adminId,
      {String? fullName,
        AdminRole? role,
        List<AdminPermission>? permissions,
        String? email,
        String? phoneNumber,
        bool? isActive}
      ) {
    // Yetki kontrolü
    if (_currentAdmin == null ||
        !_currentAdmin!.hasPermission(AdminPermission.createAdmin)) {
      throw Exception('Bu işlem için yetkiniz bulunmamaktadır');
    }

    // Super admin başka bir super admin tarafından güncellenemez
    final adminToUpdate = getAdminById(adminId);
    if (adminToUpdate == null) {
      throw Exception('Admin bulunamadı');
    }

    if (adminToUpdate.role == AdminRole.superAdmin &&
        _currentAdmin!.role != AdminRole.superAdmin) {
      throw Exception('Süper adminler sadece diğer süper adminler tarafından güncellenebilir');
    }

    // Güncelleme yap
    final index = _admins.indexWhere((admin) => admin.id == adminId);
    if (index != -1) {
      _admins[index] = adminToUpdate.copyWith(
        fullName: fullName,
        role: role,
        permissions: permissions,
        email: email,
        phoneNumber: phoneNumber,
        isActive: isActive,
      );

      return _admins[index];
    } else {
      throw Exception('Admin bulunamadı');
    }
  }

  // Admin sil
  void deleteAdmin(String adminId) {
    // Yetki kontrolü
    if (_currentAdmin == null ||
        !_currentAdmin!.hasPermission(AdminPermission.deleteAdmin)) {
      throw Exception('Bu işlem için yetkiniz bulunmamaktadır');
    }

    // Super admin başka bir super admin tarafından silinemez
    final adminToDelete = getAdminById(adminId);
    if (adminToDelete == null) {
      throw Exception('Admin bulunamadı');
    }

    if (adminToDelete.role == AdminRole.superAdmin &&
        _currentAdmin!.role != AdminRole.superAdmin) {
      throw Exception('Süper adminler sadece diğer süper adminler tarafından silinebilir');
    }

    // Kendini silemez
    if (adminToDelete.id == _currentAdmin!.id) {
      throw Exception('Kendinizi silemezsiniz');
    }

    // Silme işlemi (gerçekte silmek yerine deaktif etme)
    final index = _admins.indexWhere((admin) => admin.id == adminId);
    if (index != -1) {
      _admins[index] = _admins[index].copyWith(isActive: false);
    } else {
      throw Exception('Admin bulunamadı');
    }
  }

  // Yeni kullanıcı oluşturma
  User createUser(
      String studentId,
      String fullName,
      String? phoneNumber,
      String? dormitoryId,
      String? roomNumber,
      ) {
    // Yetki kontrolü
    if (_currentAdmin == null ||
        !_currentAdmin!.hasPermission(AdminPermission.manageUsers)) {
      throw Exception('Bu işlem için yetkiniz bulunmamaktadır');
    }

    // UserService'i kullanarak kullanıcı oluştur
    return _userService.createUser(
      studentId,
      fullName,
      phoneNumber,
      dormitoryId,
      roomNumber,
    );
  }

  // Kullanıcı bilgilerini güncelleme
  User updateUser(
      String userId,
      {String? fullName,
        String? phoneNumber,
        String? dormitoryId,
        String? roomNumber}
      ) {
    // Yetki kontrolü
    if (_currentAdmin == null ||
        !_currentAdmin!.hasPermission(AdminPermission.manageUsers)) {
      throw Exception('Bu işlem için yetkiniz bulunmamaktadır');
    }

    // UserService'i kullanarak kullanıcıyı güncelle
    return _userService.updateUserById(
      userId,
      fullName: fullName,
      phoneNumber: phoneNumber,
      dormitoryId: dormitoryId,
      roomNumber: roomNumber,
    );
  }

  // Kullanıcı silme/deaktif etme
  void deactivateUser(String userId) {
    // Yetki kontrolü
    if (_currentAdmin == null ||
        !_currentAdmin!.hasPermission(AdminPermission.manageUsers)) {
      throw Exception('Bu işlem için yetkiniz bulunmamaktadır');
    }

    // UserService'i kullanarak kullanıcıyı deaktif et
    _userService.deactivateUser(userId);
  }

  // Tüm kullanıcıları getir
  List<User> getAllUsers() {
    // Yetki kontrolü
    if (_currentAdmin == null ||
        !_currentAdmin!.hasPermission(AdminPermission.manageUsers)) {
      throw Exception('Bu işlem için yetkiniz bulunmamaktadır');
    }

    // UserService'i kullanarak tüm kullanıcıları getir
    return _userService.getAllUsers();
  }

  // Makine bakımını kaydet
  Machine serviceMachine(int machineId, String notes) {
    // Yetki kontrolü
    if (_currentAdmin == null ||
        !(_currentAdmin!.hasPermission(AdminPermission.technicalOperations) ||
            _currentAdmin!.hasPermission(AdminPermission.manageMachines))) {
      throw Exception('Bu işlem için yetkiniz bulunmamaktadır');
    }

    // MachineService'i kullanarak makineyi bakımdan çıkar
    return _machineService.serviceMachine(machineId, _currentAdmin!.fullName, notes);
  }

  // Yeni makine ekle
  Machine addMachine(String name, MachineType type) {
    // Yetki kontrolü
    if (_currentAdmin == null ||
        !_currentAdmin!.hasPermission(AdminPermission.manageMachines)) {
      throw Exception('Bu işlem için yetkiniz bulunmamaktadır');
    }

    // MachineService'i kullanarak yeni makine ekle
    return _machineService.addMachine(name, type);
  }

  // Makine sil/deaktif et
  void removeMachine(int machineId) {
    // Yetki kontrolü
    if (_currentAdmin == null ||
        !_currentAdmin!.hasPermission(AdminPermission.manageMachines)) {
      throw Exception('Bu işlem için yetkiniz bulunmamaktadır');
    }

    // MachineService'i kullanarak makineyi deaktif et
    _machineService.removeMachine(machineId);
  }

  // Tüm makineleri getir
  List<Machine> getAllMachines() {
    // MachineService'i kullanarak tüm makineleri getir
    return _machineService.getAllMachines();
  }

  // Arızalı makineleri getir
  List<Machine> getOutOfOrderMachines() {
    return _machineService.getMachinesByStatus(MachineStatus.outOfOrder);
  }

  // İstatistikleri getir
  Map<String, dynamic> getDashboardStats() {
    // Yetki kontrolü
    if (_currentAdmin == null ||
        !_currentAdmin!.hasPermission(AdminPermission.viewDashboard)) {
      throw Exception('Bu işlem için yetkiniz bulunmamaktadır');
    }

    final totalUsers = _userService.getAllUsers().length;
    final activeUsers = _userService.getAllUsers().where((user) => user.lastUsageDate != null).length;

    final allMachines = _machineService.getAllMachines();
    final totalMachines = allMachines.length;
    final availableMachines = allMachines.where((m) => m.status == MachineStatus.available).length;
    final inUseMachines = allMachines.where((m) => m.status == MachineStatus.inUse).length;
    final outOfOrderMachines = allMachines.where((m) => m.status == MachineStatus.outOfOrder).length;

    final totalWashers = allMachines.where((m) => m.type == MachineType.washer).length;
    final totalDryers = allMachines.where((m) => m.type == MachineType.dryer).length;

    // Son bir aydaki toplam kullanımlar (gerçek uygulamada veritabanı sorgusu)
    final usageLastMonth = 345;

    return {
      'totalUsers': totalUsers,
      'activeUsers': activeUsers,
      'totalMachines': totalMachines,
      'availableMachines': availableMachines,
      'inUseMachines': inUseMachines,
      'outOfOrderMachines': outOfOrderMachines,
      'totalWashers': totalWashers,
      'totalDryers': totalDryers,
      'usageLastMonth': usageLastMonth,
      'utilization': totalMachines > 0 ? (inUseMachines / totalMachines) * 100 : 0,
      'outOfOrderRate': totalMachines > 0 ? (outOfOrderMachines / totalMachines) * 100 : 0,
    };
  }

  // Tüm öğrencilere bildirim gönder
  void sendAnnouncementToAllUsers(String title, String message) {
    // Yetki kontrolü
    if (_currentAdmin == null ||
        !_currentAdmin!.hasPermission(AdminPermission.sendNotifications)) {
      throw Exception('Bu işlem için yetkiniz bulunmamaktadır');
    }

    // NotificationService'i kullanarak tüm kullanıcılara bildirim gönder
    _notificationService.sendAnnouncementToAllUsers(title, message);
  }

  // Bakım planı oluştur
  void scheduleMaintenance(int machineId, DateTime date, String technicianId) {
    // Yetki kontrolü
    if (_currentAdmin == null ||
        !(_currentAdmin!.hasPermission(AdminPermission.technicalOperations) ||
            _currentAdmin!.hasPermission(AdminPermission.assignTechnicians))) {
      throw Exception('Bu işlem için yetkiniz bulunmamaktadır');
    }

    // Teknisyenin var olduğunu ve teknisyen olduğunu kontrol et
    final technician = getAdminById(technicianId);
    if (technician == null || technician.role != AdminRole.technician) {
      throw Exception('Geçersiz teknisyen ID\'si');
    }

    // MachineService'i kullanarak bakım planla
    _machineService.scheduleMaintenance(machineId, date, technicianId);

    // Teknisyene bildirim gönder
    _notificationService.sendMaintenanceAssignment(
        technicianId,
        'Bakım Atandı',
        'Makine ID: $machineId için ${date.day}.${date.month}.${date.year} tarihinde bakım planlandı.'
    );
  }
}
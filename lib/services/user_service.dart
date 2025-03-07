import '../models/user.dart';

/// Kullanıcı servisi - Kullanıcı operasyonlarını yönetir
class UserService {
  static final UserService _instance = UserService._internal();

  factory UserService() {
    return _instance;
  }

  UserService._internal();

  // Bu mock servis gerçek bir API servisi ile değiştirilmelidir
  static final User _currentUser = User(
    id: 'current-user-id',
    studentId: '123456789',
    fullName: 'Ahmet Kaan Çelenk',
    phoneNumber: '0544 516 40 39',
    dormitoryId: 'dorm1',
    roomNumber: 'C - 203',
    activeMachineIds: ['3'],
    usageCount: 23,
    reminderEnabled: true,
    reminderMinutes: 10,
    usageStats: {'washer': 18, 'dryer': 5},
    lastUsageDate: DateTime.now().subtract(const Duration(days: 2)),
    isActive: true, // Yeni eklenen alan
  );

  static final Map<String, User> _users = {
    'current-user-id': _currentUser,
    'user123': User(
      id: 'user123',
      studentId: '987654321',
      fullName: 'Mehmet Yılmaz',
      phoneNumber: '0555 123 45 67',
      dormitoryId: 'dorm1',
      roomNumber: 'A - 105',
      activeMachineIds: ['2'],
      usageCount: 15,
      isActive: true, // Yeni eklenen alan
    ),
    'user456': User(
      id: 'user456',
      studentId: '456789123',
      fullName: 'Zeynep Kaya',
      phoneNumber: '0533 333 33 33',
      dormitoryId: 'dorm2',
      roomNumber: 'D - 410',
      activeMachineIds: [],
      usageCount: 8,
      isActive: true, // Yeni eklenen alan
    ),
    'user789': User(
      id: 'user789',
      studentId: '789123456',
      fullName: 'Ali Demir',
      phoneNumber: '0544 444 44 44',
      dormitoryId: 'dorm1',
      roomNumber: 'B - 207',
      activeMachineIds: [],
      usageCount: 30,
      isActive: true, // Yeni eklenen alan
    ),
  };

  // Mevcut kullanıcıyı getir
  User? getCurrentUser() {
    return _currentUser;
  }

  // ID'ye göre kullanıcı getir
  User? getUserById(String id) {
    return _users[id];
  }

  // Aktif makineye göre kullanıcı getir
  User? getUserByActiveMachine(String machineId) {
    try {
      return _users.values.firstWhere(
              (user) => user.activeMachineIds != null &&
              user.activeMachineIds!.contains(machineId)
      );
    } catch (e) {
      return null;
    }
  }

  // Aktif makine ekle
  void addActiveMachine(String machineId) {
    final user = _currentUser;
    final activeMachines = List<String>.from(user.activeMachineIds ?? []);

    if (!activeMachines.contains(machineId)) {
      activeMachines.add(machineId);

      // Kullanım istatistiklerini artır
      final updatedUser = user.copyWith(
        activeMachineIds: activeMachines,
      ).incrementUsageStats('washer'); // Gerçek uygulamada makine tipine göre değişecek

      _users[user.id] = updatedUser;
    }
  }

  // Aktif makineyi kaldır
  void removeActiveMachine(String machineId) {
    final user = _currentUser;
    final activeMachines = List<String>.from(user.activeMachineIds ?? []);

    activeMachines.remove(machineId);

    final updatedUser = user.copyWith(
      activeMachineIds: activeMachines,
    );

    _users[user.id] = updatedUser;
  }

  // Hatırlatıcı ayarlarını güncelle
  void updateReminderSettings(bool enabled, int minutes) {
    final user = _currentUser;
    final updatedUser = user.copyWith(
      reminderEnabled: enabled,
      reminderMinutes: minutes,
    );

    _users[user.id] = updatedUser;
  }

  // Bildirim ayarlarını güncelle
  void updateNotificationSettings(bool enabled) {
    final user = _currentUser;
    final updatedUser = user.copyWith(
      notificationsEnabled: enabled,
    );

    _users[user.id] = updatedUser;
  }

  // Kullanıcı profilini güncelle
  void updateUserProfile(String phoneNumber, String roomNumber) {
    final user = _currentUser;
    final updatedUser = user.copyWith(
      phoneNumber: phoneNumber,
      roomNumber: roomNumber,
    );

    _users[user.id] = updatedUser;
  }

  // ===== YENİ EKLENEN ADMIN METODLARI =====

  // Tüm kullanıcıları getir (Admin için)
  List<User> getAllUsers() {
    return _users.values.toList();
  }

  // Öğrenci numarasına göre kullanıcı getir
  User? getUserByStudentId(String studentId) {
    try {
      return _users.values.firstWhere(
              (user) => user.studentId == studentId && user.isActive == true
      );
    } catch (e) {
      return null;
    }
  }

  // Yurt ID'sine göre kullanıcıları getir
  List<User> getUsersByDormitory(String dormitoryId) {
    return _users.values.where(
            (user) => user.dormitoryId == dormitoryId && user.isActive == true
    ).toList();
  }

  // Yeni kullanıcı oluştur (Admin için)
  User createUser(
      String studentId,
      String fullName,
      String? phoneNumber,
      String? dormitoryId,
      String? roomNumber,
      ) {
    // Öğrenci numarasının benzersiz olduğunu kontrol et
    if (_users.values.any((user) => user.studentId == studentId)) {
      throw Exception('Bu öğrenci numarası zaten kullanılıyor');
    }

    // Yeni kullanıcı oluştur
    final newUser = User(
      id: 'user${_users.length + 1}', // Gerçek uygulamada UUID kullanılmalı
      studentId: studentId,
      fullName: fullName,
      phoneNumber: phoneNumber,
      dormitoryId: dormitoryId,
      roomNumber: roomNumber,
      activeMachineIds: [],
      usageCount: 0,
      reminderEnabled: true,
      reminderMinutes: 10,
      notificationsEnabled: true,
      usageStats: {'washer': 0, 'dryer': 0},
      isActive: true,
    );

    // Listeye ekle
    _users[newUser.id] = newUser;

    return newUser;
  }

  // Kullanıcı bilgilerini ID'ye göre güncelle (Admin için)
  User updateUserById(
      String userId,
      {String? fullName,
        String? phoneNumber,
        String? dormitoryId,
        String? roomNumber}
      ) {
    final user = getUserById(userId);
    if (user == null) {
      throw Exception('Kullanıcı bulunamadı');
    }

    // Kullanıcıyı güncelle
    final updatedUser = user.copyWith(
      fullName: fullName,
      phoneNumber: phoneNumber,
      dormitoryId: dormitoryId,
      roomNumber: roomNumber,
    );

    _users[userId] = updatedUser;

    return updatedUser;
  }

  // Kullanıcıyı deaktif et (Admin için)
  void deactivateUser(String userId) {
    final user = getUserById(userId);
    if (user == null) {
      throw Exception('Kullanıcı bulunamadı');
    }

    // Kullanıcıyı deaktif et
    _users[userId] = user.copyWith(isActive: false);
  }

  // Kullanıcıyı aktif et (Admin için)
  void activateUser(String userId) {
    final user = getUserById(userId);
    if (user == null) {
      throw Exception('Kullanıcı bulunamadı');
    }

    // Kullanıcıyı aktif et
    _users[userId] = user.copyWith(isActive: true);
  }

  // Yurda göre istatistik getir (Admin için)
  Map<String, int> getStatsByDormitory(String dormitoryId) {
    final users = getUsersByDormitory(dormitoryId);

    int totalUsers = users.length;
    int activeUsers = users.where((user) => user.lastUsageDate != null).length;
    int totalUsage = users.fold(0, (sum, user) => sum + (user.usageCount ?? 0));

    return {
      'totalUsers': totalUsers,
      'activeUsers': activeUsers,
      'totalUsage': totalUsage,
    };
  }

  // En aktif kullanıcıları getir (Admin için)
  List<User> getMostActiveUsers({int limit = 10}) {
    final activeUsers = _users.values.where((user) => user.isActive == true).toList();

    // Kullanım sayısına göre sırala
    activeUsers.sort((a, b) =>
        (b.usageCount ?? 0).compareTo(a.usageCount ?? 0)
    );

    // Limit uygula
    return activeUsers.take(limit).toList();
  }

  // Kullanıcı girişi (öğrenci numarası ve şifre ile)
  User? login(String studentId, String password) {
    // Gerçek uygulamada veritabanı sorgusu ve şifre doğrulaması yapılmalı
    try {
      final user = _users.values.firstWhere(
              (user) => user.studentId == studentId && user.isActive == true
      );

      return user;
    } catch (e) {
      return null;
    }
  }

  // Mevcut kullanıcıyı ayarla (giriş yapıldığında)
  void setCurrentUser(User user) {
    _users[user.id] = user;
  }
}
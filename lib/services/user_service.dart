import '../models/user.dart';

/// Kullanıcı servisi - Kullanıcı operasyonlarını yönetir
class UserService {
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
}
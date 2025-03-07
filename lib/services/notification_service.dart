import '../models/machine.dart';
import '../models/user.dart';
import '../models/admin.dart';
import 'user_service.dart';

/// Bildirim servisi - Kullanıcı bildirimlerini yönetir
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  // Gerçek uygulamada Firebase Messaging veya başka bir servis entegre edilecek
  // Mock bildirim listesi (uygulama içi bildirimler için)
  static final List<Notification> _notifications = [];

  // Acil durum bildirimi gönder
  void sendEmergencyNotification(String userId, String title, String body) {
    // Gerçek bildirim gönderme kodu burada olacak
    print('Acil durum bildirimi gönderildi: $userId, $title, $body');

    // Mock bildirim oluştur ve listeye ekle
    final notification = Notification(
      id: 'notification_${_notifications.length + 1}',
      userId: userId,
      title: title,
      body: body,
      type: NotificationType.emergency,
      createdAt: DateTime.now(),
      isRead: false,
    );

    _notifications.add(notification);
  }

  // Makine tamamlandı bildirimi gönder
  void sendCompletionNotification(User user, Machine machine) {
    if (user.notificationsEnabled != true) return;

    final title = 'Çamaşırınız bitti!';
    final body = '${machine.name} şu anda kullanıma hazır. Lütfen eşyalarınızı alın.';

    // Gerçek bildirim gönderme kodu burada olacak
    print('Tamamlanma bildirimi gönderildi: ${user.id}, $title, $body');

    // Mock bildirim oluştur ve listeye ekle
    final notification = Notification(
      id: 'notification_${_notifications.length + 1}',
      userId: user.id,
      title: title,
      body: body,
      type: NotificationType.machineCompleted,
      relatedMachineId: machine.id,
      createdAt: DateTime.now(),
      isRead: false,
    );

    _notifications.add(notification);
  }

  // Hatırlatıcı gönder
  void scheduleReminder(User user, Machine machine, int reminderMinutes) {
    if (user.reminderEnabled != true || machine.remainingMinutes == null) return;

    final remainingMinutes = machine.remainingMinutes!;

    if (remainingMinutes > reminderMinutes) {
      // Kalan süre hatırlatma süresinden büyükse zamanlayıcı oluştur
      final delayInMillis = (remainingMinutes - reminderMinutes) * 60 * 1000;

      Future.delayed(Duration(milliseconds: delayInMillis), () {
        sendReminder(user.id, machine.name, reminderMinutes);
      });
    }
  }

  // Hatırlatıcı bildirimi gönder
  void sendReminder(String userId, String machineName, int minutes) {
    final title = 'Çamaşırınız bitmek üzere';
    final body = '$machineName yaklaşık $minutes dakika içinde bitecek.';

    // Gerçek bildirim gönderme kodu burada olacak
    print('Hatırlatıcı gönderildi: $userId, $title, $body');

    // Mock bildirim oluştur ve listeye ekle
    final notification = Notification(
      id: 'notification_${_notifications.length + 1}',
      userId: userId,
      title: title,
      body: body,
      type: NotificationType.reminder,
      createdAt: DateTime.now(),
      isRead: false,
    );

    _notifications.add(notification);
  }

  // Bakım bildirimi gönder (yöneticiler için)
  void sendMaintenanceAlert(Machine machine) {
    final title = 'Bakım Gerekiyor';
    final body = '${machine.name} arıza bildirimi aldı ve bakım gerektiriyor.';

    // Yöneticilere bildirim gönderme kodu burada olacak
    print('Bakım bildirimi gönderildi: $title, $body');

    // Tüm teknisyenlere ve yöneticilere bildirim gönder
    // Gerçek uygulamada FCM topic subscription kullanılabilir
    _notifications.add(Notification(
      id: 'notification_${_notifications.length + 1}',
      adminType: AdminRole.technician, // Teknisyenlere gönder
      title: title,
      body: body,
      type: NotificationType.maintenance,
      relatedMachineId: machine.id,
      createdAt: DateTime.now(),
      isRead: false,
    ));

    _notifications.add(Notification(
      id: 'notification_${_notifications.length + 1}',
      adminType: AdminRole.manager, // Yöneticilere gönder
      title: title,
      body: body,
      type: NotificationType.maintenance,
      relatedMachineId: machine.id,
      createdAt: DateTime.now(),
      isRead: false,
    ));
  }

  // Yoğunluk bildirimi gönder
  void sendLowOccupancyAlert(List<int> bestHours) {
    final user = UserService().getCurrentUser();
    if (user == null || user.notificationsEnabled != true) return;

    final timeString = bestHours.map((hour) => '$hour:00').join(', ');
    final title = 'Çamaşırhane Müsait';
    final body = 'Çamaşırhanenin en müsait saatleri: $timeString';

    // Gerçek bildirim gönderme kodu burada olacak
    print('Yoğunluk bildirimi gönderildi: ${user.id}, $title, $body');

    // Mock bildirim oluştur ve listeye ekle
    final notification = Notification(
      id: 'notification_${_notifications.length + 1}',
      userId: user.id,
      title: title,
      body: body,
      type: NotificationType.occupancy,
      createdAt: DateTime.now(),
      isRead: false,
    );

    _notifications.add(notification);
  }

  // ===== YENİ EKLENEN ADMIN METODLARI =====

  // Teknisyene bakım ataması bildirimi
  void sendMaintenanceAssignment(String technicianId, String title, String body) {
    // Gerçek bildirim gönderme kodu burada olacak
    print('Bakım atama bildirimi gönderildi: $technicianId, $title, $body');

    // Mock bildirim oluştur ve listeye ekle
    final notification = Notification(
      id: 'notification_${_notifications.length + 1}',
      adminId: technicianId,
      title: title,
      body: body,
      type: NotificationType.maintenanceAssignment,
      createdAt: DateTime.now(),
      isRead: false,
    );

    _notifications.add(notification);
  }

  // Tüm öğrencilere duyuru gönder
  void sendAnnouncementToAllUsers(String title, String message) {
    // Gerçek uygulamada FCM topic yayını kullanılabilir
    print('Tüm kullanıcılara duyuru gönderildi: $title, $message');

    // Kullanıcı servisi üzerinden tüm kullanıcıları al
    final allUsers = UserService().getAllUsers();

    // Her kullanıcı için bildirim oluştur
    for (final user in allUsers) {
      if (user.notificationsEnabled != true) continue;

      final notification = Notification(
        id: 'notification_${_notifications.length + 1}',
        userId: user.id,
        title: title,
        body: message,
        type: NotificationType.announcement,
        createdAt: DateTime.now(),
        isRead: false,
      );

      _notifications.add(notification);
    }
  }

  // Belirli bir yurttaki tüm öğrencilere bildirim gönder
  void sendNotificationToDormitory(String dormitoryId, String title, String message) {
    print('Yurda bildirim gönderildi: $dormitoryId, $title, $message');

    // Kullanıcı servisi üzerinden bu yurttaki tüm kullanıcıları al
    final dormUsers = UserService().getUsersByDormitory(dormitoryId);

    // Her kullanıcı için bildirim oluştur
    for (final user in dormUsers) {
      if (user.notificationsEnabled != true) continue;

      final notification = Notification(
        id: 'notification_${_notifications.length + 1}',
        userId: user.id,
        title: title,
        body: message,
        type: NotificationType.announcement,
        createdAt: DateTime.now(),
        isRead: false,
      );

      _notifications.add(notification);
    }
  }

  // Acil durum uyarısı gönder (tüm öğrencilere ve personele)
  void sendEmergencyBroadcast(String title, String message) {
    print('Acil durum uyarısı gönderildi: $title, $message');

    // Tüm kullanıcılara bildirim gönder
    sendAnnouncementToAllUsers(title, message);

    // Tüm admin kullanıcılara bildirim gönder (gerçek uygulamada admin listesinden)
    _notifications.add(Notification(
      id: 'notification_${_notifications.length + 1}',
      isSystemWide: true, // Tüm admin kullanıcılara
      title: title,
      body: message,
      type: NotificationType.emergency,
      createdAt: DateTime.now(),
      isRead: false,
    ));
  }

  // Kullanıcının bildirimlerini getir
  List<Notification> getUserNotifications(String userId) {
    return _notifications.where((notification) =>
    notification.userId == userId &&
        notification.isArchived != true
    ).toList();
  }

  // Admin kullanıcının bildirimlerini getir
  List<Notification> getAdminNotifications(String adminId, AdminRole adminRole) {
    return _notifications.where((notification) =>
    (notification.adminId == adminId ||
        notification.adminType == adminRole ||
        notification.isSystemWide == true) &&
        notification.isArchived != true
    ).toList();
  }

  // Bildirimi okundu olarak işaretle
  void markNotificationAsRead(String notificationId) {
    final index = _notifications.indexWhere((notification) => notification.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(
        isRead: true,
        readAt: DateTime.now(),
      );
    }
  }

  // Bildirimi arşivle
  void archiveNotification(String notificationId) {
    final index = _notifications.indexWhere((notification) => notification.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(
        isArchived: true,
      );
    }
  }

  // Kullanıcının bildirimlerini temizle
  void clearUserNotifications(String userId) {
    for (int i = 0; i < _notifications.length; i++) {
      if (_notifications[i].userId == userId) {
        _notifications[i] = _notifications[i].copyWith(isArchived: true);
      }
    }
  }
}

/// Bildirim türleri
enum NotificationType {
  reminder,             // Çamaşır bitmeden önce hatırlatma
  machineCompleted,     // Çamaşır tamamlandı
  emergency,            // Acil durum
  maintenance,          // Bakım gerekli
  occupancy,            // Yoğunluk bildirimi
  announcement,         // Duyuru
  maintenanceAssignment, // Bakım ataması
  systemUpdate,         // Sistem güncellemesi
  userRegistration      // Yeni kullanıcı kaydı
}

/// Bildirim modeli
class Notification {
  final String id;
  final String? userId;          // Kullanıcı bildirimi ise user ID
  final String? adminId;         // Belli bir admine ise admin ID
  final AdminRole? adminType;    // Tüm adminler veya belli bir admin türü (teknisyen, yönetici vs)
  final bool isSystemWide;       // Sistem geneli bildirim mi
  final String title;
  final String body;
  final NotificationType type;
  final DateTime createdAt;
  final int? relatedMachineId;
  final String? relatedMaintenanceId;
  final bool isRead;
  final DateTime? readAt;
  final bool? isArchived;
  final Map<String, dynamic>? additionalData;

  Notification({
    required this.id,
    this.userId,
    this.adminId,
    this.adminType,
    this.isSystemWide = false,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.relatedMachineId,
    this.relatedMaintenanceId,
    this.isRead = false,
    this.readAt,
    this.isArchived = false,
    this.additionalData,
  });

  // Güncelleme için yeni nesne oluştur
  Notification copyWith({
    String? id,
    String? userId,
    String? adminId,
    AdminRole? adminType,
    bool? isSystemWide,
    String? title,
    String? body,
    NotificationType? type,
    DateTime? createdAt,
    int? relatedMachineId,
    String? relatedMaintenanceId,
    bool? isRead,
    DateTime? readAt,
    bool? isArchived,
    Map<String, dynamic>? additionalData,
  }) {
    return Notification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      adminId: adminId ?? this.adminId,
      adminType: adminType ?? this.adminType,
      isSystemWide: isSystemWide ?? this.isSystemWide,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      relatedMachineId: relatedMachineId ?? this.relatedMachineId,
      relatedMaintenanceId: relatedMaintenanceId ?? this.relatedMaintenanceId,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      isArchived: isArchived ?? this.isArchived,
      additionalData: additionalData ?? this.additionalData,
    );
  }
}
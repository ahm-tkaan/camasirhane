import '../models/machine.dart';
import '../models/user.dart';
import 'user_service.dart';

/// Bildirim servisi - Kullanıcı bildirimlerini yönetir
class NotificationService {
  // Gerçek uygulamada Firebase Messaging veya başka bir servis entegre edilecek

  // Acil durum bildirimi gönder
  void sendEmergencyNotification(String userId, String title, String body) {
    // Gerçek bildirim gönderme kodu burada olacak
    print('Acil durum bildirimi gönderildi: $userId, $title, $body');
  }

  // Makine tamamlandı bildirimi gönder
  void sendCompletionNotification(User user, Machine machine) {
    if (user.notificationsEnabled != true) return;

    final title = 'Çamaşırınız bitti!';
    final body = '${machine.name} şu anda kullanıma hazır. Lütfen eşyalarınızı alın.';

    // Gerçek bildirim gönderme kodu burada olacak
    print('Tamamlanma bildirimi gönderildi: ${user.id}, $title, $body');
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
  }

  // Bakım bildirimi gönder (yöneticiler için)
  void sendMaintenanceAlert(Machine machine) {
    final title = 'Bakım Gerekiyor';
    final body = '${machine.name} arıza bildirimi aldı ve bakım gerektiriyor.';

    // Yöneticilere bildirim gönderme kodu burada olacak
    print('Bakım bildirimi gönderildi: $title, $body');
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
  }
}
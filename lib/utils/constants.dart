import 'package:flutter/material.dart';

/// Uygulama Renkleri
class AppColors {
  // Ana renkler
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1E40AF);
  static const Color background = Color(0xFFF0F2F5);

  // Metin renkleri
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);

  // Durum renkleri
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Diğer
  static const Color inputBackground = Color(0xFFF3F4F6);
  static const Color border = Color(0xFFE5E7EB);
  static const Color cardBackground = Colors.white;
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color primaryLight = Color(0xFFDBEAFE);
}

/// Uygulama Metinleri
class AppTexts {
  // Giriş Ekranı
  static const String loginTitle = 'Çamaşırhane Mobil Uygulaması';
  static const String loginSubtitle = 'Giriş yaparak devam ediniz';
  static const String studentIdHint = 'Öğrenci No';
  static const String passwordHint = 'Şifre';
  static const String loginButton = 'Giriş Yap';
  static const String forgotPassword = 'Şifremi Unuttum';

  // Ana Sayfa
  static const String availableWasher = 'Boş Çamaşır';
  static const String availableDryer = 'Boş Kurutma';
  static const String activeMachine = 'Aktif Çamaşırınız';
  static const String machines = 'Makineler';
  static const String scanQR = 'QR Tara';
  static const String available = 'Kullanılabilir';
  static const String inUse = 'Kullanımda';
  static const String estimatedEnd = 'Tahmini bitiş';
  static const String inProgress = 'Devam Ediyor';
  static const String use = 'Kullan';

  // QR Tarama
  static const String qrScannerTitle = 'QR Kod Tarama';
  static const String qrScannerInstruction = 'QR kodu çerçeveye yerleştirin';
  static const String qrScannerInfo1 = 'Çamaşır makinesi üzerindeki';
  static const String qrScannerInfo2 = 'QR kodu taratarak kullanım';
  static const String qrScannerInfo3 = 'başlatabilirsiniz';

  // Alt Menü
  static const String homeTab = 'Ana Sayfa';
  static const String historyTab = 'Geçmiş';
  static const String qrScanTab = 'QR Tara';
  static const String profileTab = 'Profil';

  // Uyarılar
  static const String confirmUse = 'Makine Kullanımı';
  static const String confirmUseMessage = 'kullanımı başlatılacak. Onaylıyor musunuz?';
  static const String cancel = 'İptal';
  static const String start = 'Başlat';
  static const String usageStarted = 'kullanımı başlatıldı!';

  // Yeni Eklemeler
  static const String viewUserInfo = 'Kullanıcı Bilgisi';
  static const String programSelection = 'Program Seçin';
  static const String quickWash = 'Hızlı Yıkama (30 dk)';
  static const String normalWash = 'Normal Yıkama (45 dk)';
  static const String heavyWash = 'Yoğun Yıkama (65 dk)';
  static const String ecoWash = 'Ekonomik Yıkama (55 dk)';
  static const String quickDry = 'Hızlı Kurutma (25 dk)';
  static const String normalDry = 'Normal Kurutma (40 dk)';
  static const String intenseDry = 'Yoğun Kurutma (60 dk)';
  static const String reminderEnabled = 'Çamaşır bitmeden önce hatırlat';
  static const String reminderDescription = 'Çamaşırınız bitmeden {0} dakika önce bildirim alacaksınız';
  static const String outOfOrder = 'Arızalı';
  static const String reportIssue = 'Arıza Bildir';
  static const String reportIssueConfirm = 'Bu makineyi arızalı olarak işaretlemek istediğinize emin misiniz?';
  static const String issueReported = 'Arıza bildirimi alındı. Yetkililer bilgilendirildi.';
  static const String notifyWhenDone = 'Bitince Bildir';
  static const String reminderScheduled = 'Hatırlatıcı zaten planlandı. Ayarlardan değiştirebilirsiniz.';
  static const String notificationSent = 'Bildirim gönderildi';
  static const String emergencyNotification = 'Çamaşırınızla ilgili bir mesaj var';
  static const String emergencyNotificationBody = 'Çamaşırhanenin diğer kullanıcılarından biri sizinle iletişime geçmek istiyor.';
  static const String userNotFound = 'Kullanıcı bilgisi bulunamadı';

  // Yoğunluk Grafiği
  static const String occupancyTitle = 'Günlük Yoğunluk Tahmini';
  static const String occupancyDescription = 'Aşağıdaki grafik, çamaşırhanenin saat bazlı tahmini doluluk oranını göstermektedir.';
  static const String bestHours = 'Önerilen en uygun saatler:';
  static const String notifyWhenAvailable = 'Müsait Olduğunda Bildir';
  static const String notifyWhenAvailableSuccess = 'Çamaşırhane müsait olduğunda size bildirim gönderilecek.';
  static const String busy = 'Dolu';
  static const String availableLabel = 'Müsait';
  static const String lowOccupancy = 'Az Yoğun';
  static const String mediumOccupancy = 'Orta Yoğun';
  static const String highOccupancy = 'Çok Yoğun';
}

/// Uygulama animasyonları için süreler
class AppDurations {
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
}

/// Uygulama veri kaynakları (Mock veriler için)
class AppDataSources {
  static const bool useMockData = true;
}
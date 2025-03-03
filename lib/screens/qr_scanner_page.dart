import 'package:flutter/material.dart';
import '../models/machine.dart';
import '../models/user.dart';
import '../services/machine_service.dart';
import '../services/user_service.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({Key? key}) : super(key: key);

  @override
  _QRScannerPageState createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> with SingleTickerProviderStateMixin {
  bool _isFlashOn = false;
  bool _isScanning = true;

  // Servisler (gerçek uygulamada uygun şekilde başlatılmalıdır)
  final MachineService _machineService = MachineService();
  final UserService _userService = UserService();
  final NotificationService _notificationService = NotificationService();

  late AnimationController _animationController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();

    // Tarama çizgisi animasyonu için controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: -100, end: 100).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // QR Kodu işleme fonksiyonu - Ana algoritma burada
  void _handleQRScan(String qrCode) {
    setState(() {
      _isScanning = false;
    });

    // QR kodundan makine ID'sini çıkar
    final machineId = _extractMachineIdFromQR(qrCode);

    // Makineyi bul
    final machine = _machineService.getMachineById(int.parse(machineId));

    if (machine != null) {
      if (machine.status == MachineStatus.inUse) {
        // Makine kullanımdaysa, kullanıcı bilgilerini getir
        final user = _userService.getUserByActiveMachine(machineId);
        if (user != null) {
          // Kullanıcı bilgilerini göster
          _showUserInfoDialog(machine, user);
        } else {
          _showErrorMessage("Kullanıcı bilgisi bulunamadı");
        }
      } else if (machine.status == MachineStatus.available) {
        // Makine boşsa, kullanmak istiyor musunuz diye sor
        _showUseMachineConfirmation(machine);
      } else {
        // Makine arızalıysa bilgi ver
        _showErrorMessage("Bu makine şu anda arızalı durumda");
      }
    } else {
      _showErrorMessage("Geçersiz QR kod");
    }
  }

  // QR kodundan makine ID'sini çıkarır
  String _extractMachineIdFromQR(String qrCode) {
    // Gerçek uygulamada QR kodunun formatına göre uyarlanmalı
    // Örnek format: "MACHINE:123"
    if (qrCode.startsWith("MACHINE:")) {
      return qrCode.split(":")[1];
    }
    return qrCode; // Basit demo için direkt makine ID'si döndürülüyor
  }

  // Hata mesajı gösterme
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );

    // Kısa bir gecikme sonrası taramayı yeniden etkinleştir
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isScanning = true;
        });
      }
    });
  }

  // Kullanıcı bilgilerini gösteren dialog
  void _showUserInfoDialog(Machine machine, User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("${machine.name} Kullanım Bilgisi"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Kullanıcı: ${user.fullName}"),
            Text("Oda No: ${user.roomNumber ?? 'Belirtilmemiş'}"),
            Text("Başlangıç: 14:30"), // Gerçek uygulamada machine.startTime olacak
            Text("Tahmini Bitiş: ${machine.endTime}"),
            Text("Kalan Süre: ${machine.remainingMinutes ?? '?'} dakika"),
            const Divider(),
            const Text("Acil bir durum olduğunda kullanıcıya bildirim gönderilebilir.")
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isScanning = true;
              });
            },
            child: const Text("Kapat"),
          ),
          TextButton(
            onPressed: () => _sendNotificationToUser(user.id),
            child: const Text("Bildirim Gönder"),
          ),
        ],
      ),
    );
  }

  // Kullanıcıya acil durum bildirimi gönder
  void _sendNotificationToUser(String userId) {
    _notificationService.sendEmergencyNotification(
        userId,
        "Çamaşırınızla ilgili bir mesaj var",
        "Çamaşırhanenin diğer kullanıcılarından biri sizinle iletişime geçmek istiyor."
    );
    Navigator.pop(context);
    setState(() {
      _isScanning = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Bildirim gönderildi")),
    );
  }

  // Makine kullanımı onay dialogu
  void _showUseMachineConfirmation(Machine machine) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppTexts.confirmUse),
        content: Text('${machine.name} ${AppTexts.confirmUseMessage}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isScanning = true;
              });
            },
            child: const Text(AppTexts.cancel),
          ),
          TextButton(
            onPressed: () {
              _useMachine(machine);
              Navigator.pop(context);
            },
            child: const Text(AppTexts.start),
          ),
        ],
      ),
    );
  }

  // Makine kullanımı başlatma
  void _useMachine(Machine machine) {
    // Burada makine kullanımı başlatma API çağrısı yapılacak
    // Şimdilik demo amaçlı simüle ediliyor
    final updatedMachine = machine.copyWith(
      status: MachineStatus.inUse,
      isUsersMachine: true,
      endTime: '16:30', // Simüle edilmiş bitiş zamanı
      remainingMinutes: 40,
    );

    // Makine ve kullanıcı bilgilerini güncelle
    _machineService.updateMachine(updatedMachine);
    _userService.addActiveMachine(updatedMachine.id.toString());

    // Kullanıcıya bildirim ayarlarına göre hatırlatıcı planla
    final currentUser = _userService.getCurrentUser();
    if (currentUser != null && currentUser.reminderEnabled == true) {
      _notificationService.scheduleReminder(
          currentUser,
          updatedMachine,
          currentUser.reminderMinutes ?? 10
      );
    }

    // Ana sayfaya başarı mesajıyla dön
    Navigator.pop(context, updatedMachine);
  }

  // Simülasyon için QR tarama
  void _simulateQRScanned(int machineId) {
    final qrCode = "MACHINE:$machineId";
    _handleQRScan(qrCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          AppTexts.qrScannerTitle,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          // Kamera önizleme (simülasyon)
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Köşe işaretçileri
                  _buildCornerMarkers(),

                  // Tarama çizgisi
                  AnimatedBuilder(
                    animation: _scanAnimation,
                    builder: (context, child) {
                      return Positioned(
                        top: 125 + _scanAnimation.value,
                        left: 0,
                        right: 0,
                        child: Container(
                          width: double.infinity,
                          height: 2,
                          color: const Color(0xFF2563EB),
                        ),
                      );
                    },
                  ),

                  // Bilgi metni
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    color: Colors.black.withOpacity(0.7),
                    child: const Text(
                      AppTexts.qrScannerInstruction,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Flaş Düğmesi
          Positioned(
            right: 20,
            bottom: 120,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isFlashOn = !_isFlashOn;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_isFlashOn ? 'Flaş açıldı' : 'Flaş kapatıldı'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.shade800.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isFlashOn ? Icons.flash_on : Icons.flash_off,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Alt bilgi metni
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              color: const Color(0xFF111111),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppTexts.qrScannerInfo1,
                    style: TextStyle(color: Colors.white, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  Text(
                    AppTexts.qrScannerInfo2,
                    style: TextStyle(color: Colors.white, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  Text(
                    AppTexts.qrScannerInfo3,
                    style: TextStyle(color: Colors.white, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // Simüle QR Tarama Butonları - Demo amaçlı
          Positioned(
            bottom: 150,
            left: 0,
            right: 0,
            child: _isScanning ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    onPressed: () => _simulateQRScanned(index + 1),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text('Makine ${index + 1}'),
                  ),
                );
              }),
            ) : const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          ),

          // Kullanımda olan makine simülasyonu için buton
          Positioned(
            bottom: 210,
            left: 0,
            right: 0,
            child: _isScanning ? Center(
              child: ElevatedButton(
                onPressed: () => _simulateQRScanned(3), // Makine 3 kullanımda olacak şekilde kurgulandı
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text('Kullanımdaki Makine Tarama'),
              ),
            ) : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  // Köşe işaretleri
  Widget _buildCornerMarkers() {
    const double markerSize = 20;
    const double thickness = 3;
    final Color color = Colors.white;

    return Stack(
      children: [
        // Sol üst köşe
        Positioned(
          top: 0,
          left: 0,
          child: Container(
            width: markerSize,
            height: thickness,
            color: color,
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          child: Container(
            width: thickness,
            height: markerSize,
            color: color,
          ),
        ),

        // Sağ üst köşe
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: markerSize,
            height: thickness,
            color: color,
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: thickness,
            height: markerSize,
            color: color,
          ),
        ),

        // Sol alt köşe
        Positioned(
          bottom: 0,
          left: 0,
          child: Container(
            width: markerSize,
            height: thickness,
            color: color,
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: Container(
            width: thickness,
            height: markerSize,
            color: color,
          ),
        ),

        // Sağ alt köşe
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: markerSize,
            height: thickness,
            color: color,
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: thickness,
            height: markerSize,
            color: color,
          ),
        ),
      ],
    );
  }
}
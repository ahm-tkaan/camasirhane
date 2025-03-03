import 'package:flutter/material.dart';
import '../models/machine.dart';
import '../utils/constants.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({Key? key}) : super(key: key);

  @override
  _QRScannerPageState createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> with SingleTickerProviderStateMixin {
  bool _isFlashOn = false;
  bool _isScanning = true;

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

  // Simülasyon - gerçek uygulamada QR okuma kütüphanesi kullanılacak
  void _simulateQRScanned(int machineId) {
    setState(() {
      _isScanning = false;
    });

    // QR kod okunduğunda kullanıcıya bildir
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('QR Kod tarandı: Çamaşır Makinesi $machineId'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 1),
      ),
    );

    // Ana sayfaya dön ve simüle edilmiş veri ile makineyi kullanıma al
    Future.delayed(const Duration(seconds: 1), () {
      // Simüle edilmiş makine verisi
      final scannedMachine = Machine(
        id: machineId,
        name: 'Çamaşır Makinesi $machineId',
        status: MachineStatus.available,
        type: MachineType.washer,
      );

      Navigator.pop(context, scannedMachine);
    });
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

          // Simüle QR Tarama Butonları
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
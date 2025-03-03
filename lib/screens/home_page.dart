import 'package:flutter/material.dart';
import '../models/machine.dart';
import '../utils/constants.dart';
import '../widgets/active_machine.dart';
import '../widgets/machine_card.dart';
import 'qr_scanner_page.dart';
import 'history_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Test için makine verilerini içeren basit mock veritabanı
  final List<Machine> _machines = [
    Machine(
      id: 1,
      name: 'Çamaşır Makinesi 1',
      status: MachineStatus.available,
      type: MachineType.washer,
    ),
    Machine(
      id: 2,
      name: 'Çamaşır Makinesi 2',
      status: MachineStatus.inUse,
      endTime: '15:45',
      type: MachineType.washer,
      remainingMinutes: 25,
    ),
    Machine(
      id: 3,
      name: 'Çamaşır Makinesi 3',
      status: MachineStatus.inUse,
      isUsersMachine: true,
      endTime: '15:30',
      type: MachineType.washer,
      remainingMinutes: 15,
    ),
    Machine(
      id: 4,
      name: 'Çamaşır Makinesi 4',
      status: MachineStatus.available,
      type: MachineType.washer,
    ),
    Machine(
      id: 5,
      name: 'Kurutma Makinesi 1',
      status: MachineStatus.available,
      type: MachineType.dryer,
    ),
    Machine(
      id: 6,
      name: 'Kurutma Makinesi 2',
      status: MachineStatus.outOfOrder,
      type: MachineType.dryer,
    ),
  ];

  // Alt menü seçimi
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // QR Tara butonu özel olarak işleniyor
    if (index == 2) {
      _scanQR();
    }
  }

  // Makine kullanımı başlatma
  void _useMachine(Machine machine) {
    if (machine.status == MachineStatus.available) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(AppTexts.confirmUse),
          content: Text('${machine.name} ${AppTexts.confirmUseMessage}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(AppTexts.cancel),
            ),
            TextButton(
              onPressed: () {
                // Simülasyon: Makineyi kullanıma al
                setState(() {
                  final index = _machines.indexOf(machine);
                  if (index != -1) {
                    _machines[index] = machine.copyWith(
                      status: MachineStatus.inUse,
                      isUsersMachine: true,
                      endTime: '16:30', // Simüle edilmiş bitiş zamanı
                      remainingMinutes: 40,
                    );
                  }
                });
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${machine.name} ${AppTexts.usageStarted}'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              child: const Text(AppTexts.start),
            ),
          ],
        ),
      );
    }
  }

  // QR tarama sayfasına gitme
  void _scanQR() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerPage()),
    ).then((scannedMachine) {
      if (scannedMachine != null) {
        _useMachine(scannedMachine);
      }
    });
  }

  // Aktif makine detaylarını gösterme
  void _showActiveMachineDetails() {
    final activeMachine = _getUserActiveMachine();

    if (activeMachine != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => _buildActiveMachineBottomSheet(activeMachine),
      );
    }
  }

  // Mevcut durumu hesapla
  int _getAvailableWashers() {
    int available = 0;
    int total = 0;
    for (var machine in _machines) {
      if (machine.type == MachineType.washer) {
        total++;
        if (machine.status == MachineStatus.available) {
          available++;
        }
      }
    }
    return available;
  }

  int _getAvailableDryers() {
    int available = 0;
    int total = 0;
    for (var machine in _machines) {
      if (machine.type == MachineType.dryer) {
        total++;
        if (machine.status == MachineStatus.available) {
          available++;
        }
      }
    }
    return available;
  }

  Machine? _getUserActiveMachine() {
    for (var machine in _machines) {
      if (machine.isUsersMachine && machine.status == MachineStatus.inUse) {
        return machine;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Ana sayfa görünümü
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppTexts.loginTitle),
        actions: [
          // Profil icon
          Container(
            margin: const EdgeInsets.only(right: 16.0),
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.primaryDark,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                'AKÇ',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: AppTexts.homeTab,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: AppTexts.historyTab,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code),
            label: AppTexts.qrScanTab,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: AppTexts.profileTab,
          ),
        ],
        currentIndex: _selectedIndex == 2 ? 0 : _selectedIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
        onPressed: _scanQR,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.qr_code_scanner),
      )
          : null,
    );
  }

  // İçerik oluşturma
  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return const HistoryPage();
      case 3:
        return const ProfilePage();
      default:
        return _buildHomeTab();
    }
  }

  // Ana sayfa içeriği
  Widget _buildHomeTab() {
    final activeMachine = _getUserActiveMachine();
    final availableWashers = _getAvailableWashers();
    final totalWashers = _machines.where((m) => m.type == MachineType.washer).length;
    final availableDryers = _getAvailableDryers();
    final totalDryers = _machines.where((m) => m.type == MachineType.dryer).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // İstatistik kartları
          _buildStatsRow(availableWashers, totalWashers, availableDryers, totalDryers),

          const SizedBox(height: 24.0),

          // Aktif çamaşır
          if (activeMachine != null)
            ActiveMachineCard(
              machine: activeMachine,
              onPressed: _showActiveMachineDetails,
            ),

          const SizedBox(height: 24.0),

          // Makineler Listesi
          _buildMachinesList(),
        ],
      ),
    );
  }

  // İstatistik satırı
  Widget _buildStatsRow(int availableWashers, int totalWashers, int availableDryers, int totalDryers) {
    return Row(
      children: [
        // Boş çamaşır makineleri
        Expanded(
          child: _buildStatCard(
            title: AppTexts.availableWasher,
            value: "$availableWashers/$totalWashers",
          ),
        ),
        const SizedBox(width: 16.0),
        // Boş kurutma makineleri
        Expanded(
          child: _buildStatCard(
            title: AppTexts.availableDryer,
            value: "$availableDryers/$totalDryers",
          ),
        ),
      ],
    );
  }

  // İstatistik kartı
  Widget _buildStatCard({required String title, required String value}) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14.0,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Makineler listesi kartı
  Widget _buildMachinesList() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Liste başlığı
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  AppTexts.machines,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                InkWell(
                  onTap: _scanQR,
                  child: const Text(
                    AppTexts.scanQR,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Çizgi
          const Divider(height: 1, color: AppColors.border),

          // Makine listesi
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _machines.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              color: AppColors.border,
            ),
            itemBuilder: (context, index) {
              final machine = _machines[index];
              return MachineCard(
                machine: machine,
                onUse: _useMachine,
              );
            },
          ),
        ],
      ),
    );
  }

  // Aktif makine detay modal
  Widget _buildActiveMachineBottomSheet(Machine machine) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_laundry_service,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                machine.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Tahmini Bitiş Zamanı'),
            subtitle: Text(machine.endTime ?? 'Bilinmiyor'),
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Kalan Süre'),
            subtitle: Text('${machine.remainingMinutes ?? '?'} dakika'),
          ),
          ListTile(
            leading: const Icon(Icons.date_range),
            title: const Text('Başlangıç Zamanı'),
            subtitle: Text('14:50'), // Mock veri
          ),
          const SizedBox(height: 10),
          // İlerleme çubuğu
          if (machine.remainingMinutes != null) ...[
            const Text(
              'İlerleme Durumu',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: 1 - ((machine.remainingMinutes ?? 0) / 40),
              backgroundColor: AppColors.border,
              color: AppColors.primary,
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Bildirim ayarları
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Makine bittiğinde size bildirim gönderilecek'),
                  ),
                );
              },
              icon: const Icon(Icons.notifications_active),
              label: const Text('Bitince Bildir'),
            ),
          ),
        ],
      ),
    );
  }
}
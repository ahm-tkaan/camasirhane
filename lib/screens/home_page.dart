import 'dart:async';
import 'package:flutter/material.dart';
import '../models/machine.dart';
import '../services/machine_service.dart';
import '../services/user_service.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';
import '../widgets/active_machine.dart';
import '../widgets/machine_card.dart';
import '../widgets/occupancy_chart.dart';
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
  bool _isLoading = true;

  // Servisler
  final MachineService _machineService = MachineService();
  final UserService _userService = UserService();
  final NotificationService _notificationService = NotificationService();

  // Makine listesi
  List<Machine> _machines = [];

  // Zamanlayıcı - Kalan süreleri güncellemek için
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadData();

    // Her dakika makine durumlarını güncelle
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      _updateMachines();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Veri yükleme
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    // API çağrıları olacak, şimdilik mock data kullanıyoruz
    _machines = _machineService.getAllMachines();

    setState(() {
      _isLoading = false;
    });
  }

  // Makine durumlarını güncelle
  void _updateMachines() {
    // Gerçek uygulamada API çağrısı olacak
    _machineService.updateAllMachinesRemainingTime();

    // Güncel makine listesini al
    setState(() {
      _machines = _machineService.getAllMachines();
    });

    // Aktif makinesi olan kullanıcının makinesini kontrol et
    final user = _userService.getCurrentUser();
    if (user != null && user.hasActiveMachine()) {
      for (final machineId in user.activeMachineIds!) {
        final machine = _machineService.getMachineById(int.parse(machineId));

        // Eğer makine kullanımda değilse bildirim gönder
        if (machine != null && machine.status == MachineStatus.available &&
            machine.isNotifiedOnComplete != true) {
          _notificationService.sendCompletionNotification(user, machine);

          // Makineyi bildirim gönderildi olarak işaretle
          final updatedMachine = machine.copyWith(isNotifiedOnComplete: true);
          _machineService.updateMachine(updatedMachine);
        }
      }
    }
  }

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
        builder: (context) => _buildProgramSelectionDialog(machine),
      );
    }
  }

  // Program seçim dialogu
  Widget _buildProgramSelectionDialog(Machine machine) {
    ProgramType selectedProgram = machine.type == MachineType.washer
        ? ProgramType.normalWash
        : ProgramType.normalDry;

    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Text(
            '${machine.name} için Program Seçin',
            style: const TextStyle(fontSize: 18.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Program seçimi
              if (machine.type == MachineType.washer) ...[
                _buildProgramOption(
                  ProgramType.quickWash,
                  'Hızlı Yıkama (30 dk)',
                  selectedProgram,
                      (value) => setState(() => selectedProgram = value),
                ),
                _buildProgramOption(
                  ProgramType.normalWash,
                  'Normal Yıkama (45 dk)',
                  selectedProgram,
                      (value) => setState(() => selectedProgram = value),
                ),
                _buildProgramOption(
                  ProgramType.heavyWash,
                  'Yoğun Yıkama (65 dk)',
                  selectedProgram,
                      (value) => setState(() => selectedProgram = value),
                ),
                _buildProgramOption(
                  ProgramType.ecoWash,
                  'Ekonomik Yıkama (55 dk)',
                  selectedProgram,
                      (value) => setState(() => selectedProgram = value),
                ),
              ] else ...[
                _buildProgramOption(
                  ProgramType.quickDry,
                  'Hızlı Kurutma (25 dk)',
                  selectedProgram,
                      (value) => setState(() => selectedProgram = value),
                ),
                _buildProgramOption(
                  ProgramType.normalDry,
                  'Normal Kurutma (40 dk)',
                  selectedProgram,
                      (value) => setState(() => selectedProgram = value),
                ),
                _buildProgramOption(
                  ProgramType.intenseDry,
                  'Yoğun Kurutma (60 dk)',
                  selectedProgram,
                      (value) => setState(() => selectedProgram = value),
                ),
              ],

              const SizedBox(height: 16.0),

              // Hatırlatıcı ayarı
              _buildReminderSetting(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(AppTexts.cancel),
            ),
            TextButton(
              onPressed: () {
                _startMachineUsage(machine, selectedProgram);
                Navigator.pop(context);
              },
              child: const Text(AppTexts.start),
            ),
          ],
        );
      },
    );
  }

  // Program seçeneği
  Widget _buildProgramOption(
      ProgramType program,
      String label,
      ProgramType selectedProgram,
      Function(ProgramType) onChanged
      ) {
    return RadioListTile<ProgramType>(
      title: Text(label),
      value: program,
      groupValue: selectedProgram,
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }

  // Hatırlatıcı ayarı
  Widget _buildReminderSetting() {
    final user = _userService.getCurrentUser();
    bool reminderEnabled = user?.reminderEnabled ?? true;

    return CheckboxListTile(
      title: const Text('Çamaşır bitmeden önce hatırlat',
        style: TextStyle(fontSize: 14.0),
      ),
      subtitle: Text(
        'Çamaşırınız bitmeden ${user?.reminderMinutes ?? 10} dakika önce bildirim alacaksınız',
        style: const TextStyle(fontSize: 12.0),
      ),
      value: reminderEnabled,
      onChanged: null, // Profil sayfasında değiştirilebilir
    );
  }

  // Makine kullanımını başlat
  void _startMachineUsage(Machine machine, ProgramType programType) {
    final user = _userService.getCurrentUser();
    if (user == null) return;

    try {
      // Makine kullanımını başlat
      final updatedMachine = _machineService.startMachineUsage(
          machine.id,
          user.id,
          programType
      );

      // Kullanıcının aktif makine listesine ekle
      _userService.addActiveMachine(machine.id.toString());

      // Gerekirse hatırlatıcı planla
      if (user.reminderEnabled == true) {
        _notificationService.scheduleReminder(
            user,
            updatedMachine,
            user.reminderMinutes ?? 10
        );
      }

      // Makine listesini güncelle
      setState(() {
        _machines = _machineService.getAllMachines();
      });

      // Başarı mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${machine.name} kullanımı başlatıldı!'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      // Hata mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // QR tarama sayfasına gitme
  void _scanQR() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerPage()),
    ).then((result) {
      if (result != null && result is Machine) {
        // QR sayfasından dönen makine varsa
        setState(() {
          _machines = _machineService.getAllMachines();
        });

        // Başarı mesajı göster
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.name} kullanımı başlatıldı!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    });
  }

  // Aktif makine detaylarını gösterme
  void _showActiveMachineDetails(Machine machine) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildActiveMachineBottomSheet(machine),
    );
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

  // Yoğunluk grafiğini göster
  void _showOccupancyChart() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final forecast = _machineService.getOccupancyForecast(DateTime.now());
        final bestHours = _machineService.suggestBestHours(DateTime.now());

        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.access_time, color: AppColors.primary),
                  const SizedBox(width: 8.0),
                  const Text(
                    'Günlük Yoğunluk Tahmini',
                    style: TextStyle(
                      fontSize: 18.0,
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
              const SizedBox(height: 8.0),
              const Text(
                'Aşağıdaki grafik, çamaşırhanenin saat bazlı tahmini doluluk oranını göstermektedir.',
                style: TextStyle(
                  fontSize: 14.0,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16.0),
              // Burada OccupancyChart widget'ı olacak
              Expanded(
                child: OccupancyChart(occupancyData: forecast),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Önerilen en uygun saatler: ${bestHours.map((h) => '$h:00').join(', ')}',
                style: const TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 8.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.notification_add),
                  label: const Text('Müsait Olduğunda Bildir'),
                  onPressed: () {
                    _notificationService.sendLowOccupancyAlert(bestHours);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Çamaşırhane müsait olduğunda size bildirim gönderilecek.'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ana sayfa görünümü
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppTexts.loginTitle),
        actions: [
          // Yoğunluk grafiği butonu
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: _showOccupancyChart,
          ),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadData,
        child: _buildBody(),
      ),
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
              onPressed: () => _showActiveMachineDetails(activeMachine),
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
            icon: Icons.local_laundry_service,
          ),
        ),
        const SizedBox(width: 16.0),
        // Boş kurutma makineleri
        Expanded(
          child: _buildStatCard(
            title: AppTexts.availableDryer,
            value: "$availableDryers/$totalDryers",
            icon: Icons.dry,
          ),
        ),
      ],
    );
  }

  // İstatistik kartı
  Widget _buildStatCard({required String title, required String value, required IconData icon}) {
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
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14.0,
                ),
              ),
            ],
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
                onViewUser: _showMachineUserInfo,
              );
            },
          ),
        ],
      ),
    );
  }

  // Makineyi kullanan kullanıcıyı göster
  void _showMachineUserInfo(Machine machine) {
    if (machine.status != MachineStatus.inUse || machine.userId == null) {
      return;
    }

    final user = _userService.getUserById(machine.userId!);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kullanıcı bilgisi bulunamadı'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

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
            Text("Başlangıç: ${machine.startTime ?? 'Belirtilmemiş'}"),
            Text("Tahmini Bitiş: ${machine.endTime}"),
            Text("Program: ${_getProgramName(machine.programType)}"),
            Text("Kalan Süre: ${machine.remainingMinutes ?? '?'} dakika"),
            const Divider(),
            const Text("Acil bir durum olduğunda kullanıcıya bildirim gönderilebilir.")
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
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

  // Program adını al
  String _getProgramName(ProgramType? programType) {
    if (programType == null) return 'Bilinmiyor';

    switch (programType) {
      case ProgramType.quickWash:
        return 'Hızlı Yıkama';
      case ProgramType.normalWash:
        return 'Normal Yıkama';
      case ProgramType.heavyWash:
        return 'Yoğun Yıkama';
      case ProgramType.ecoWash:
        return 'Ekonomik Yıkama';
      case ProgramType.quickDry:
        return 'Hızlı Kurutma';
      case ProgramType.normalDry:
        return 'Normal Kurutma';
      case ProgramType.intenseDry:
        return 'Yoğun Kurutma';
      default:
        return 'Bilinmiyor';
    }
  }

  // Kullanıcıya acil durum bildirimi gönder
  void _sendNotificationToUser(String userId) {
    _notificationService.sendEmergencyNotification(
        userId,
        "Çamaşırınızla ilgili bir mesaj var",
        "Çamaşırhanenin diğer kullanıcılarından biri sizinle iletişime geçmek istiyor."
    );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Bildirim gönderildi")),
    );
  }

  // Aktif makine detay modal
  Widget _buildActiveMachineBottomSheet(Machine machine) {
    final completionPercentage = machine.getCompletionPercentage();

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
      Row(
      children: [
      Icon(
      machine.type == MachineType.washer
      ? Icons.local_laundry_service
          : Icons.dry,
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
    subtitle: Text(machine.startTime ?? 'Bilinmiyor'),
    ),
    ListTile(
    leading: const Icon(Icons.wash),
    title: const Text('Program'),
    subtitle: Text(_getProgramName(machine.programType)),
    ),
    const SizedBox(height: 10),
    // İlerleme çubuğu
    const Text(
    'İlerleme Durumu',
    style: TextStyle(fontWeight: FontWeight.bold),
    ),
    const SizedBox(height: 10),
    LinearProgressIndicator(
    value: completionPercentage / 100,
    backgroundColor: AppColors.border,
    color: AppColors.primary,
    minHeight: 10,
    borderRadius: BorderRadius.circular(5),
    ),
    const SizedBox(height: 4),
    Text(
    '%${completionPercentage.toStringAsFixed(0)} tamamlandı',
    style: const TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
    ),
    ),
    const SizedBox(height: 20),
    SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
    onPressed: () {
    // Bildirim ayarları
    Navigator.pop(context);

    final user = _userService.getCurrentUser();
    if (user != null) {
    // Bildirim zaten planlanmış mı?
    final bool hasReminder = user.reminderEnabled == true;

    if (hasReminder) {
    ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
    content: Text('Hatırlatıcı zaten planlandı. Ayarlardan değiştirebilirsiniz.'),
    ),
    );
    } else {
    _userService.updateReminderSettings(true, 5);
    _notificationService.scheduleReminder(
    user,
    machine,
    5
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Makine bittiğinde size bildirim gönderilecek'),
        backgroundColor: AppColors.success,
      ),
    );
    }
    }
    },
      icon: const Icon(Icons.notifications_active),
      label: const Text('Bitince Bildir'),
    ),
    ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // Arıza bildir
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Arıza Bildir'),
                    content: const Text('Bu makineyi arızalı olarak işaretlemek istediğinize emin misiniz?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('İptal'),
                      ),
                      TextButton(
                        onPressed: () {
                          _machineService.reportMachineIssue(machine.id);
                          Navigator.pop(context); // Dialog'u kapat
                          Navigator.pop(context); // BottomSheet'i kapat

                          // Bildirimleri etkilenen kullanıcılara gönder
                          _notificationService.sendMaintenanceAlert(machine);

                          // Makine listesini güncelle
                          setState(() {
                            _machines = _machineService.getAllMachines();
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Arıza bildirimi alındı. Yetkililer bilgilendirildi.'),
                              backgroundColor: AppColors.warning,
                            ),
                          );
                        },
                        child: const Text('Arıza Bildir', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.report_problem, color: Colors.red),
              label: const Text('Arıza Bildir', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
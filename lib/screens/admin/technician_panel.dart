import 'package:flutter/material.dart';
import '../../models/admin.dart';
import '../../models/machine.dart';
import '../../services/admin_service.dart';
import '../../services/machine_service.dart';
import '../../utils/constants.dart';

class TechnicianPanel extends StatefulWidget {
  const TechnicianPanel({Key? key}) : super(key: key);

  @override
  _TechnicianPanelState createState() => _TechnicianPanelState();
}

class _TechnicianPanelState extends State<TechnicianPanel> with SingleTickerProviderStateMixin {
  final AdminService _adminService = AdminService();
  final MachineService _machineService = MachineService();

  late TabController _tabController;
  bool _isLoading = true;
  Admin? _currentTechnician;
  List<Machine> _outOfOrderMachines = [];
  List<MaintenanceSchedule> _mySchedules = [];
  Map<String, dynamic> _maintenanceStats = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Verileri yükle
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Mevcut teknisyeni al
      _currentTechnician = _adminService.getCurrentAdmin();
      if (_currentTechnician == null || _currentTechnician!.role != AdminRole.technician) {
        // Eğer teknisyen değilse, uygun bir hata göster
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bu sayfaya erişim yetkiniz yok'),
            backgroundColor: AppColors.error,
          ),
        );
        Navigator.pop(context);
        return;
      }

      // Arızalı makineleri al
      _outOfOrderMachines = _adminService.getOutOfOrderMachines();

      // Teknisyenin bakım planlarını al
      _mySchedules = _machineService.getTechnicianSchedules(_currentTechnician!.id);

      // Bakım istatistiklerini al
      _maintenanceStats = _machineService.getMaintenanceStats();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teknisyen Paneli'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Arızalı Makineler'),
            Tab(text: 'Bakım Planlarım'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          // Arızalı Makineler Tab
          _buildOutOfOrderMachinesTab(),

          // Bakım Planlarım Tab
          _buildMaintenanceSchedulesTab(),
        ],
      ),
    );
  }

  // Arızalı Makineler Tab
  Widget _buildOutOfOrderMachinesTab() {
    if (_outOfOrderMachines.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Colors.green.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              'Arızalı makine bulunmamaktadır',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: Column(
        children: [
          // İstatistik özeti
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Toplam ${_outOfOrderMachines.length} arızalı makine',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Arıza Oranı: %${(_maintenanceStats['outOfOrderRate'] ?? 0).toStringAsFixed(1)}',
                  style: TextStyle(
                    color: _maintenanceStats['outOfOrderRate'] > 20
                        ? Colors.red
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Arızalı makineler listesi
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _outOfOrderMachines.length,
              itemBuilder: (context, index) {
                final machine = _outOfOrderMachines[index];
                return _buildRepairCard(machine);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Bakım Planlarım Tab
  Widget _buildMaintenanceSchedulesTab() {
    if (_mySchedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 64,
              color: Colors.blue.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              'Size atanmış bakım planı bulunmamaktadır',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    // Tarihe göre sırala (yakın tarihli önce)
    _mySchedules.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _mySchedules.length,
        itemBuilder: (context, index) {
          final schedule = _mySchedules[index];
          return _buildScheduleCard(schedule);
        },
      ),
    );
  }

  // Onarım kartı
  Widget _buildRepairCard(Machine machine) {
    return Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () => _showMachineDetails(machine),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            // Başlık ve makine tipi
            Row(
            children: [
            Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              machine.type == MachineType.washer
                  ? Icons.local_laundry_service
                  : Icons.dry,
              color: Colors.red,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  machine.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  machine.type == MachineType.washer
                      ? 'Çamaşır Makinesi'
                      : 'Kurutma Makinesi',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Arızalı',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ],
        ),
        const SizedBox(height: 12),

        // Model ve son bakım bilgileri
        if (machine.model != null || machine.serialNumber != null)
    Padding(
        padding: const EdgeInsets.only(bottom: 8),
    child: Row(
    children: [
    Text(
    machine.model != null
    ? 'Model: ${machine.model}'
        : '',
    style: const TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
    ),
    ),
      if (machine.model != null && machine.serialNumber != null)
        const SizedBox(width: 8),
      if (machine.serialNumber != null)
        Text(
          'S/N: ${machine.serialNumber}',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
    ],
    ),
    ),

                  Text(
                    'Son Bakım: ${machine.lastMaintenanceDate != null
                        ? '${machine.lastMaintenanceDate!.day}.${machine.lastMaintenanceDate!.month}.${machine.lastMaintenanceDate!.year}'
                        : 'Bilgi yok'}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  if (machine.lastMaintenanceBy != null)
                    Text(
                      'Bakım Yapan: ${machine.lastMaintenanceBy}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Onarım butonu
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showServiceMachineDialog(machine),
                      icon: const Icon(Icons.build),
                      label: const Text('Onarım Yap'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
            ),
          ),
        ),
    );
  }

  // Bakım planı kartı
  Widget _buildScheduleCard(MaintenanceSchedule schedule) {
    // İlgili makineyi bul
    final machine = _machineService.getMachineById(schedule.machineId);
    if (machine == null) return const SizedBox.shrink();

    // Durum rengini belirle
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (schedule.status) {
      case MaintenanceStatus.scheduled:
        statusColor = Colors.blue;
        statusText = 'Planlandı';
        statusIcon = Icons.calendar_today;
        break;
      case MaintenanceStatus.inProgress:
        statusColor = Colors.orange;
        statusText = 'Devam Ediyor';
        statusIcon = Icons.pending;
        break;
      case MaintenanceStatus.completed:
        statusColor = Colors.green;
        statusText = 'Tamamlandı';
        statusIcon = Icons.check_circle;
        break;
      case MaintenanceStatus.cancelled:
        statusColor = Colors.red;
        statusText = 'İptal Edildi';
        statusIcon = Icons.cancel;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık ve tarih
            Row(
              children: [
                Icon(statusIcon, color: statusColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${machine.name} - Planlı Bakım',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Tarih ve diğer bilgiler
            Text(
              'Tarih: ${schedule.scheduledDate.day}.${schedule.scheduledDate.month}.${schedule.scheduledDate.year}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),

            if (schedule.notes != null && schedule.notes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Not: ${schedule.notes}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // İşlem butonları
            if (schedule.status == MaintenanceStatus.scheduled)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showUpdateScheduleDialog(schedule, MaintenanceStatus.inProgress),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Başlat'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showServiceMachineDialog(machine, schedule),
                      icon: const Icon(Icons.check),
                      label: const Text('Tamamla'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              )
            else if (schedule.status == MaintenanceStatus.inProgress)
              ElevatedButton.icon(
                onPressed: () => _showServiceMachineDialog(machine, schedule),
                icon: const Icon(Icons.check),
                label: const Text('Tamamla'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Bakım yapma dialogu
  void _showServiceMachineDialog(Machine machine, [MaintenanceSchedule? schedule]) {
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${machine.name} Bakımı'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Yapılan işlemler ve değiştirilen parçalar:'),
            const SizedBox(height: 8.0),
            TextField(
              controller: notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Örn: Filtre değiştirildi, motor tamir edildi...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (notesController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lütfen bakım notlarını giriniz'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              try {
                // Bakım işlemini kaydet
                _adminService.serviceMachine(
                    machine.id,
                    notesController.text
                );

                // Eğer bir bakım planı varsa, onu da tamamlandı olarak işaretle
                if (schedule != null) {
                  _machineService.updateMaintenanceSchedule(
                      schedule.id,
                      MaintenanceStatus.completed,
                      notes: notesController.text
                  );
                }

                Navigator.pop(context);

                // Verileri yenile
                _loadData();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${machine.name} bakımı tamamlandı'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Hata: ${e.toString()}'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Bakımı Tamamla'),
          ),
        ],
      ),
    );
  }

  // Bakım planı durumunu güncelleme dialogu
  void _showUpdateScheduleDialog(MaintenanceSchedule schedule, MaintenanceStatus newStatus) {
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bakım Durumunu Güncelle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bakım durumunu "${_getStatusText(newStatus)}" olarak güncellemek istiyor musunuz?',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text('Not (opsiyonel):'),
            const SizedBox(height: 8),
            TextField(
              controller: notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Notunuzu buraya yazın...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              try {
                // Bakım planını güncelle
                _machineService.updateMaintenanceSchedule(
                    schedule.id,
                    newStatus,
                    notes: notesController.text.isEmpty ? null : notesController.text
                );

                Navigator.pop(context);

                // Verileri yenile
                _loadData();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Bakım durumu güncellendi'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Hata: ${e.toString()}'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Güncelle'),
          ),
        ],
      ),
    );
  }

  // Makine detaylarını göster
  void _showMachineDetails(Machine machine) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              machine.type == MachineType.washer
                  ? Icons.local_laundry_service
                  : Icons.dry,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8.0),
            Text(machine.name),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              _buildDetailItem('Durum', _getMachineStatusText(machine.status)),
              _buildDetailItem('Tip', machine.type == MachineType.washer
                  ? 'Çamaşır Makinesi'
                  : 'Kurutma Makinesi'),
              _buildDetailItem('Son Bakım', machine.lastMaintenanceDate != null
                  ? '${machine.lastMaintenanceDate!.day}.${machine.lastMaintenanceDate!.month}.${machine.lastMaintenanceDate!.year}'
                  : 'Bilgi yok'),
              _buildDetailItem('Yapan Teknisyen', machine.lastMaintenanceBy ?? 'Bilgi yok'),
              _buildDetailItem('Bakım Notları', machine.maintenanceNotes ?? 'Not girilmemiş'),
              _buildDetailItem('Toplam Kullanım', '${machine.usageCount ?? 0} kez'),
              _buildDetailItem('Sağlık Puanı', '${machine.calculateHealthScore()} / 100'),

              if (machine.errorCount != null && machine.errorCount! > 0)
                _buildDetailItem('Toplam Arıza', '${machine.errorCount} kez'),

              if (machine.serialNumber != null)
                _buildDetailItem('Seri No', machine.serialNumber!),

              if (machine.model != null)
                _buildDetailItem('Model', machine.model!),

              if (machine.manufacturer != null)
                _buildDetailItem('Üretici', machine.manufacturer!),

              if (machine.installationDate != null)
                _buildDetailItem('Kurulum Tarihi', '${machine.installationDate!.day}.${machine.installationDate!.month}.${machine.installationDate!.year}'),

              if (machine.purchaseDate != null)
                _buildDetailItem('Satın Alma Tarihi', '${machine.purchaseDate!.day}.${machine.purchaseDate!.month}.${machine.purchaseDate!.year}'),

              if (machine.warrantyEndDate != null)
                _buildDetailItem('Garanti Bitiş', '${machine.warrantyEndDate!.day}.${machine.warrantyEndDate!.month}.${machine.warrantyEndDate!.year}'),

              if (machine.location != null)
                _buildDetailItem('Konum', machine.location!),

              const SizedBox(height: 16),
              const Text(
                'İşlemler',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ActionChip(
                    label: const Text('Onarım Yap'),
                    avatar: const Icon(Icons.build, size: 16),
                    backgroundColor: Colors.green.shade100,
                    onPressed: () {
                      Navigator.pop(context);
                      _showServiceMachineDialog(machine);
                    },
                  ),
                  ActionChip(
                    label: const Text('Bakım Planla'),
                    avatar: const Icon(Icons.calendar_today, size: 16),
                    onPressed: () {
                      Navigator.pop(context);
                      _showScheduleMaintenanceDialog(machine);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showServiceMachineDialog(machine);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Onarım Yap'),
          ),
        ],
      ),
    );
  }

  // Bakım planlama dialogu
  void _showScheduleMaintenanceDialog(Machine machine) {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('${machine.name} İçin Bakım Planla'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Bakım Tarihi:'),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );

                  if (picked != null) {
                    setState(() {
                      selectedDate = picked;
                    });
                  }
                },
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  '${selectedDate.day}.${selectedDate.month}.${selectedDate.year}',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                try {
                  // Bakım planla
                  _adminService.scheduleMaintenance(
                      machine.id,
                      selectedDate,
                      _currentTechnician!.id
                  );

                  Navigator.pop(context);

                  // Verileri yenile
                  _loadData();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${machine.name} için bakım planlandı'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Hata: ${e.toString()}'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              child: const Text('Planla'),
            ),
          ],
        ),
      ),
    );
  }

  // Detay öğesi widget'ı
  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Makine durumunu metin olarak döndür
  String _getMachineStatusText(MachineStatus status) {
    switch (status) {
      case MachineStatus.available:
        return 'Kullanılabilir';
      case MachineStatus.inUse:
        return 'Kullanımda';
      case MachineStatus.outOfOrder:
        return 'Arızalı';
      default:
        return '';
    }
  }

  // Bakım durumunu metin olarak döndür
  String _getStatusText(MaintenanceStatus status) {
    switch (status) {
      case MaintenanceStatus.scheduled:
        return 'Planlandı';
      case MaintenanceStatus.inProgress:
        return 'Devam Ediyor';
      case MaintenanceStatus.completed:
        return 'Tamamlandı';
      case MaintenanceStatus.cancelled:
        return 'İptal Edildi';
      default:
        return '';
    }
  }
}
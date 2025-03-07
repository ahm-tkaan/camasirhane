import 'package:flutter/material.dart';
import '../../models/admin.dart';
import '../../models/machine.dart';
import '../../services/admin_service.dart';
import '../../services/machine_service.dart';
import '../../utils/constants.dart';

class MaintenanceSchedulePage extends StatefulWidget {
  final Machine? selectedMachine;

  const MaintenanceSchedulePage({
    Key? key,
    this.selectedMachine,
  }) : super(key: key);

  @override
  _MaintenanceSchedulePageState createState() => _MaintenanceSchedulePageState();
}

class _MaintenanceSchedulePageState extends State<MaintenanceSchedulePage> {
  final AdminService _adminService = AdminService();
  final MachineService _machineService = MachineService();

  bool _isLoading = true;
  List<MaintenanceSchedule> _allSchedules = [];
  List<MaintenanceSchedule> _pendingSchedules = [];
  List<MaintenanceSchedule> _completedSchedules = [];
  List<Admin> _technicians = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Verileri yükle
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Tüm bakım planlarını al
      _allSchedules = _machineService.getAllMaintenanceSchedules();

      // Teknisyenleri al
      _technicians = _adminService.getAdminsByRole(AdminRole.technician);

      // Bekleyen ve tamamlanan planları filtrele
      _pendingSchedules = _allSchedules.where((s) =>
      s.status == MaintenanceStatus.scheduled ||
          s.status == MaintenanceStatus.inProgress
      ).toList();

      _completedSchedules = _allSchedules.where((s) =>
      s.status == MaintenanceStatus.completed ||
          s.status == MaintenanceStatus.cancelled
      ).toList();

      // Tarihe göre sırala
      _pendingSchedules.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
      _completedSchedules.sort((a, b) => (b.completedAt ?? b.scheduledDate).compareTo(a.completedAt ?? a.scheduledDate));

      // Eğer bir makine seçiliyse ve yetki varsa, yeni bakım planı oluştur
      if (widget.selectedMachine != null) {
        final admin = _adminService.getCurrentAdmin();
        if (admin != null && (
            admin.hasPermission(AdminPermission.assignTechnicians) ||
                admin.hasPermission(AdminPermission.technicalOperations))) {
          // Tab'e gerek kalmadan doğrudan planlama dialogunu göster
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showScheduleMaintenanceDialog(widget.selectedMachine!);
          });
        }
      }
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bakım Planları'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Bekleyen'),
              Tab(text: 'Tamamlanan'),
            ],
          ),
          actions: [
            // Yeni plan ekleme butonu
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Yeni Bakım Planı',
              onPressed: _showSelectMachineDialog,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
          children: [
            // Bekleyen Tab
            _buildScheduleList(_pendingSchedules),

            // Tamamlanan Tab
            _buildScheduleList(_completedSchedules),
          ],
        ),
      ),
    );
  }

  // Bakım planı listesi
  Widget _buildScheduleList(List<MaintenanceSchedule> schedules) {
    if (schedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              'Bakım planı bulunamadı',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: schedules.length,
        itemBuilder: (context, index) {
          final schedule = schedules[index];
          return _buildScheduleCard(schedule);
        },
      ),
    );
  }

  // Bakım planı kartı
  Widget _buildScheduleCard(MaintenanceSchedule schedule) {
    // İlgili makineyi bul
    final machine = _machineService.getMachineById(schedule.machineId);
    if (machine == null) return const SizedBox.shrink();

    // İlgili teknisyeni bul
    final technician = _technicians.firstWhere(
          (t) => t.id == schedule.technicianId,
      orElse: () => Admin(
        id: 'unknown',
        username: 'unknown',
        fullName: 'Bilinmeyen Teknisyen',
        role: AdminRole.technician,
        permissions: [],
        createdAt: DateTime.now(),
      ),
    );

    // Durum rengi ve metni
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
        child: InkWell(
        onTap: () => _showScheduleDetails(schedule, machine, technician),
    borderRadius: BorderRadius.circular(12),
    child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    // Başlık ve durum
    Row(
    children: [
    Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
    color: machine.type == MachineType.washer
    ? AppColors.primaryLight
        : AppColors.warningLight,
    borderRadius: BorderRadius.circular(8),
    ),
    child: Icon(
    machine.type == MachineType.washer
    ? Icons.local_laundry_service
        : Icons.dry,
    color: machine.type == MachineType.washer
    ? AppColors.primary
        : AppColors.warning,
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
    'Teknisyen: ${technician.fullName}',
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
    color: statusColor.withOpacity(0.1),
    borderRadius: BorderRadius.circular(4),
    border: Border.all(color: statusColor),),
      child: Row(
        children: [
          Icon(statusIcon, size: 12, color: statusColor),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
    ],
    ),
      const SizedBox(height: 12),

      // Tarih bilgileri
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Planlanan Tarih:',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${schedule.scheduledDate.day}.${schedule.scheduledDate.month}.${schedule.scheduledDate.year}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (schedule.completedAt != null)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tamamlanma Tarihi:',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${schedule.completedAt!.day}.${schedule.completedAt!.month}.${schedule.completedAt!.year}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),

      // Notlar
      if (schedule.notes != null && schedule.notes!.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Notlar:',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                schedule.notes!,
                style: const TextStyle(
                  fontSize: 13,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

      // İşlem butonları
      if (schedule.status == MaintenanceStatus.scheduled)
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () => _showCancelDialog(schedule),
                child: const Text('İptal Et'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _showEditScheduleDialog(schedule),
                child: const Text('Düzenle'),
              ),
            ],
          ),
        ),
    ],
    ),
    ),
        ),
    );
  }

  // Bakım planı detayları
  void _showScheduleDetails(MaintenanceSchedule schedule, Machine machine, Admin technician) {
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
            Expanded(
              child: Text(
                '${machine.name} Bakım Planı',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              _buildDetailItem('Durum', _getStatusText(schedule.status)),
              _buildDetailItem('Planlanan Tarih', '${schedule.scheduledDate.day}.${schedule.scheduledDate.month}.${schedule.scheduledDate.year}'),

              if (schedule.completedAt != null)
                _buildDetailItem('Tamamlanma Tarihi', '${schedule.completedAt!.day}.${schedule.completedAt!.month}.${schedule.completedAt!.year}'),

              _buildDetailItem('Teknisyen', technician.fullName),
              _buildDetailItem('Oluşturulma', '${schedule.createdAt.day}.${schedule.createdAt.month}.${schedule.createdAt.year}'),

              if (schedule.notes != null)
                _buildDetailItem('Notlar', schedule.notes!),

              const Divider(),

              // Makine bilgileri
              const Text(
                'Makine Bilgileri',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),

              _buildDetailItem('Makine', machine.name),
              _buildDetailItem('Tipi', machine.type == MachineType.washer
                  ? 'Çamaşır Makinesi'
                  : 'Kurutma Makinesi'),
              _buildDetailItem('Son Bakım', machine.lastMaintenanceDate != null
                  ? '${machine.lastMaintenanceDate!.day}.${machine.lastMaintenanceDate!.month}.${machine.lastMaintenanceDate!.year}'
                  : 'Bilgi yok'),
              _buildDetailItem('Durumu', _getMachineStatusText(machine.status)),

              if (machine.serialNumber != null)
                _buildDetailItem('Seri No', machine.serialNumber!),

              if (machine.model != null)
                _buildDetailItem('Model', machine.model!),

              // İşlem butonları
              if (schedule.status == MaintenanceStatus.scheduled)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          label: const Text('Düzenle'),
                          avatar: const Icon(Icons.edit, size: 16),
                          onPressed: () {
                            Navigator.pop(context);
                            _showEditScheduleDialog(schedule);
                          },
                        ),
                        ActionChip(
                          label: const Text('İptal Et'),
                          avatar: const Icon(Icons.cancel, size: 16),
                          backgroundColor: Colors.red.shade100,
                          onPressed: () {
                            Navigator.pop(context);
                            _showCancelDialog(schedule);
                          },
                        ),
                      ],
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
        ],
      ),
    );
  }

  // Makine seçme dialogu
  void _showSelectMachineDialog() {
    final machines = _machineService.getAllMachines();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Makine Seçin'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: machines.length,
            itemBuilder: (context, index) {
              final machine = machines[index];
              return ListTile(
                leading: Icon(
                  machine.type == MachineType.washer
                      ? Icons.local_laundry_service
                      : Icons.dry,
                  color: machine.status == MachineStatus.outOfOrder
                      ? Colors.red
                      : AppColors.primary,
                ),
                title: Text(machine.name),
                subtitle: Text(machine.status == MachineStatus.outOfOrder
                    ? 'Arızalı'
                    : machine.status == MachineStatus.inUse
                    ? 'Kullanımda'
                    : 'Kullanılabilir'),
                onTap: () {
                  Navigator.pop(context);
                  _showScheduleMaintenanceDialog(machine);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
        ],
      ),
    );
  }

  // Bakım planlama dialogu
  void _showScheduleMaintenanceDialog(Machine machine) {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    Admin? selectedTechnician = _technicians.isNotEmpty ? _technicians.first : null;
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('${machine.name} İçin Bakım Planla'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tarih seçimi
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
                const SizedBox(height: 16),

                // Teknisyen seçimi
                const Text('Teknisyen:'),
                const SizedBox(height: 8),
                DropdownButton<Admin>(
                  isExpanded: true,
                  value: selectedTechnician,
                  hint: const Text('Teknisyen Seçin'),
                  items: _technicians.map((technician) {
                    return DropdownMenuItem<Admin>(
                      value: technician,
                      child: Text(technician.fullName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedTechnician = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Notlar
                const Text('Notlar (opsiyonel):'),
                const SizedBox(height: 8),
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Bakım ile ilgili notlar...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedTechnician == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lütfen bir teknisyen seçin'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                try {
                  // Bakım planla
                  _adminService.scheduleMaintenance(
                      machine.id,
                      selectedDate,
                      selectedTechnician!.id
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

  // Bakım planı düzenleme dialogu
  void _showEditScheduleDialog(MaintenanceSchedule schedule) {
    final machine = _machineService.getMachineById(schedule.machineId);
    if (machine == null) return;

    DateTime selectedDate = schedule.scheduledDate;
    Admin? selectedTechnician = _technicians.firstWhere(
          (t) => t.id == schedule.technicianId,
      orElse: () => _technicians.isNotEmpty ? _technicians.first : null,
    );
    final notesController = TextEditingController(text: schedule.notes);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('${machine.name} Bakım Planını Düzenle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tarih seçimi
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
                const SizedBox(height: 16),

                // Teknisyen seçimi
                const Text('Teknisyen:'),
                const SizedBox(height: 8),
                DropdownButton<Admin>(
                  isExpanded: true,
                  value: selectedTechnician,
                  hint: const Text('Teknisyen Seçin'),
                  items: _technicians.map((technician) {
                    return DropdownMenuItem<Admin>(
                      value: technician,
                      child: Text(technician.fullName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedTechnician = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Notlar
                const Text('Notlar (opsiyonel):'),
                const SizedBox(height: 8),
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Bakım ile ilgili notlar...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedTechnician == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lütfen bir teknisyen seçin'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                try {
                  // Bakım planını güncelle (gerçek uygulamada bu işlevi eklemen gerekecek)

                  Navigator.pop(context);

                  // Verileri yenile
                  _loadData();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Bakım planı güncellendi'),
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
      ),
    );
  }

  // İptal etme dialogu
  void _showCancelDialog(MaintenanceSchedule schedule) {
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bakım Planını İptal Et'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bu bakım planını iptal etmek istediğinize emin misiniz?'),
            const SizedBox(height: 16),
            const Text('İptal nedeni (opsiyonel):'),
            const SizedBox(height: 8),
            TextField(
              controller: notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'İptal nedeninizi yazın...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              try {
                // Bakım planını iptal et
                _machineService.updateMaintenanceSchedule(
                    schedule.id,
                    MaintenanceStatus.cancelled,
                    notes: notesController.text.isEmpty
                        ? null
                        : notesController.text
                );

                Navigator.pop(context);

                // Verileri yenile
                _loadData();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bakım planı iptal edildi'),
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
            child: const Text('İptal Et', style: TextStyle(color: Colors.white)),
          ),
        ],
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
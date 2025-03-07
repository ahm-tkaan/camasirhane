import 'package:flutter/material.dart';
import '../../../models/machine.dart';
import '../../../services/admin_service.dart';
import '../../../services/machine_service.dart';
import '../../../utils/constants.dart';
import '../maintenance_schedule_page.dart';

class MachineManagementPage extends StatefulWidget {
  const MachineManagementPage({Key? key}) : super(key: key);

  @override
  _MachineManagementPageState createState() => _MachineManagementPageState();
}

class _MachineManagementPageState extends State<MachineManagementPage> with SingleTickerProviderStateMixin {
  final AdminService _adminService = AdminService();
  final MachineService _machineService = MachineService();

  late TabController _tabController;
  bool _isLoading = true;
  List<Machine> _allMachines = [];
  List<Machine> _washers = [];
  List<Machine> _dryers = [];
  List<Machine> _outOfOrderMachines = [];
  int _totalMachines = 0;
  int _availableMachines = 0;
  int _outOfOrderCount = 0;

  // Yeni makine için form controller
  final _machineNameController = TextEditingController();
  final _serialNumberController = TextEditingController();
  final _modelController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _locationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _machineNameController.dispose();
    _serialNumberController.dispose();
    _modelController.dispose();
    _manufacturerController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // Verileri yükle
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Tüm makineleri al
      _allMachines = _adminService.getAllMachines();

      // Çamaşır ve kurutma makinelerini ayrıştır
      _washers = _allMachines.where((m) => m.type == MachineType.washer).toList();
      _dryers = _allMachines.where((m) => m.type == MachineType.dryer).toList();

      // Arızalı makineleri al
      _outOfOrderMachines = _allMachines.where((m) => m.status == MachineStatus.outOfOrder).toList();

      // İstatistikleri güncelle
      _totalMachines = _allMachines.length;
      _availableMachines = _allMachines.where((m) => m.status == MachineStatus.available).length;
      _outOfOrderCount = _outOfOrderMachines.length;
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
        title: const Text('Makine Yönetimi'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tümü'),
            Tab(text: 'Çamaşır'),
            Tab(text: 'Kurutma'),
            Tab(text: 'Arızalı'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          // Tümü Tab
          _buildMachineList(_allMachines),

          // Çamaşır Tab
          _buildMachineList(_washers),

          // Kurutma Tab
          _buildMachineList(_dryers),

          // Arızalı Tab
          _buildMachineList(_outOfOrderMachines),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMachineDialog,
        child: const Icon(Icons.add),
        tooltip: 'Yeni Makine Ekle',
      ),
    );
  }

  // Makine listesi
  Widget _buildMachineList(List<Machine> machines) {
    if (machines.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'Bu kategoride makine bulunamadı',
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
      child: Column(
        children: [
          // İstatistik özeti
          _buildStatsRow(),

          // Makine listesi
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: machines.length,
              itemBuilder: (context, index) {
                final machine = machines[index];
                return _buildMachineCard(machine);
              },
            ),
          ),
        ],
      ),
    );
  }

  // İstatistik özeti satırı
  Widget _buildStatsRow() {
    return Container(
      color: Colors.grey.shade50,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Toplam', _totalMachines, Colors.blue),
          _buildStatItem('Müsait', _availableMachines, Colors.green),
          _buildStatItem('Arızalı', _outOfOrderCount, Colors.red),
        ],
      ),
    );
  }

  // İstatistik öğesi
  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // Makine kartı
  Widget _buildMachineCard(Machine machine) {
    Color statusColor;
    String statusText;

    // Durum rengini ve metnini ayarla
    switch (machine.status) {
      case MachineStatus.available:
        statusColor = AppColors.success;
        statusText = 'Kullanılabilir';
        break;
      case MachineStatus.inUse:
        statusColor = AppColors.warning;
        statusText = 'Kullanımda';
        break;
      case MachineStatus.outOfOrder:
        statusColor = AppColors.error;
        statusText = 'Arızalı';
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showMachineDetails(machine),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Makine tipi ikonu
              Container(
                width: 50,
                height: 50,
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
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

              // Makine detayları
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      machine.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Son bakım: ${machine.lastMaintenanceDate != null
                          ? '${machine.lastMaintenanceDate!.day}.${machine.lastMaintenanceDate!.month}.${machine.lastMaintenanceDate!.year}'
                          : 'Bilgi yok'}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 12,
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Sağlık puanı
              if (machine.status != MachineStatus.outOfOrder)
                _buildHealthIndicator(machine.calculateHealthScore()),

              // İşlem menüsü
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditMachineDialog(machine);
                  } else if (value == 'service') {
                    _showServiceMachineDialog(machine);
                  } else if (value == 'maintenance') {
                    _navigateToMaintenanceSchedule(machine);
                  } else if (value == 'delete') {
                    _showDeleteConfirmation(machine);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text('Düzenle'),
                      ],
                    ),
                  ),
                  if (machine.status == MachineStatus.outOfOrder)
                    const PopupMenuItem(
                      value: 'service',
                      child: Row(
                        children: [
                          Icon(Icons.build, size: 18),
                          SizedBox(width: 8),
                          Text('Bakım Yap'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'maintenance',
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, size: 18),
                        SizedBox(width: 8),
                        Text('Bakım Planla'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red, size: 18),
                        SizedBox(width: 8),
                        Text('Sil', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Sağlık göstergesi
  Widget _buildHealthIndicator(int healthScore) {
    Color color;
    if (healthScore >= 80) {
      color = Colors.green;
    } else if (healthScore >= 50) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.1),
        border: Border.all(
          color: color,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          '$healthScore',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // Makine ekleme dialogu
  void _showAddMachineDialog() {
    MachineType selectedType = MachineType.washer;
    DateTime? installationDate;
    DateTime? purchaseDate;

    // Form alanlarını temizle
    _machineNameController.clear();
    _serialNumberController.clear();
    _modelController.clear();
    _manufacturerController.clear();
    _locationController.clear();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Yeni Makine Ekle'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Makine adı
                  TextFormField(
                    controller: _machineNameController,
                    decoration: const InputDecoration(
                      labelText: 'Makine Adı*',
                      hintText: 'Örn: Çamaşır Makinesi 5',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Makine adı gerekli';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Makine tipi
                  DropdownButtonFormField<MachineType>(
                    value: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Makine Tipi*',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: MachineType.washer,
                        child: Text('Çamaşır Makinesi'),
                      ),
                      DropdownMenuItem(
                        value: MachineType.dryer,
                        child: Text('Kurutma Makinesi'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedType = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Seri numarası
                  TextFormField(
                    controller: _serialNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Seri Numarası',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Model
                  TextFormField(
                    controller: _modelController,
                    decoration: const InputDecoration(
                      labelText: 'Model',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Üretici
                  TextFormField(
                    controller: _manufacturerController,
                    decoration: const InputDecoration(
                      labelText: 'Üretici',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Konum
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Konum',
                      hintText: 'Örn: 1. Kat, A Blok',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Kurulum tarihi
                  Row(
                    children: [
                      const Text('Kurulum Tarihi:'),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: installationDate ?? DateTime.now(),
                              firstDate: DateTime(2010),
                              lastDate: DateTime.now(),
                            );

                            if (picked != null) {
                              setState(() {
                                installationDate = picked;
                              });
                            }
                          },
                          child: Text(
                            installationDate != null
                                ? '${installationDate!.day}.${installationDate!.month}.${installationDate!.year}'
                                : 'Seç',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Satın alma tarihi
                  Row(
                    children: [
                      const Text('Satın Alma Tarihi:'),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: purchaseDate ?? DateTime.now(),
                              firstDate: DateTime(2010),
                              lastDate: DateTime.now(),
                            );

                            if (picked != null) {
                              setState(() {
                                purchaseDate = picked;
                              });
                            }
                          },
                          child: Text(
                            purchaseDate != null
                                ? '${purchaseDate!.day}.${purchaseDate!.month}.${purchaseDate!.year}'
                                : 'Seç',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                // Form doğrulama
                if (_formKey.currentState!.validate()) {
                  try {
                    // Makineyi ekle (Bu metod gerçek uygulamada tüm alanları alacak şekilde genişletilmeli)
                    final newMachine = _adminService.addMachine(
                      _machineNameController.text,
                      selectedType,
                    );

                    Navigator.pop(context);

                    // Verileri yenile
                    _loadData();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Makine başarıyla eklendi'),
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
                }
              },
              child: const Text('Ekle'),
            ),
          ],
        ),
      ),
    );
  }

  // Makine düzenleme dialogu
  void _showEditMachineDialog(Machine machine) {
    // Form alanlarını doldur
    _machineNameController.text = machine.name;
    _serialNumberController.text = machine.serialNumber ?? '';
    _modelController.text = machine.model ?? '';
    _manufacturerController.text = machine.manufacturer ?? '';
    _locationController.text = machine.location ?? '';

    MachineType selectedType = machine.type;
    DateTime? installationDate = machine.installationDate;
    DateTime? purchaseDate = machine.purchaseDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('${machine.name} Düzenle'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Makine adı
                  TextFormField(
                    controller: _machineNameController,
                    decoration: const InputDecoration(
                      labelText: 'Makine Adı*',
                      hintText: 'Örn: Çamaşır Makinesi 5',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Makine adı gerekli';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Makine tipi
                  DropdownButtonFormField<MachineType>(
                    value: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Makine Tipi*',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: MachineType.washer,
                        child: Text('Çamaşır Makinesi'),
                      ),
                      DropdownMenuItem(
                        value: MachineType.dryer,
                        child: Text('Kurutma Makinesi'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedType = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Seri numarası
                  TextFormField(
                    controller: _serialNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Seri Numarası',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Model
                  TextFormField(
                    controller: _modelController,
                    decoration: const InputDecoration(
                      labelText: 'Model',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Üretici
                  TextFormField(
                    controller: _manufacturerController,
                    decoration: const InputDecoration(
                      labelText: 'Üretici',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Konum
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Konum',
                      hintText: 'Örn: 1. Kat, A Blok',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Kurulum tarihi
                  Row(
                    children: [
                      const Text('Kurulum Tarihi:'),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: installationDate ?? DateTime.now(),
                              firstDate: DateTime(2010),
                              lastDate: DateTime.now(),
                            );

                            if (picked != null) {
                              setState(() {
                                installationDate = picked;
                              });
                            }
                          },
                          child: Text(
                            installationDate != null
                                ? '${installationDate!.day}.${installationDate!.month}.${installationDate!.year}'
                                : 'Seç',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Satın alma tarihi
                  Row(
                    children: [
                      const Text('Satın Alma Tarihi:'),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: purchaseDate ?? DateTime.now(),
                              firstDate: DateTime(2010),
                              lastDate: DateTime.now(),
                            );

                            if (picked != null) {
                              setState(() {
                                purchaseDate = picked;
                              });
                            }
                          },
                          child: Text(
                            purchaseDate != null
                                ? '${purchaseDate!.day}.${purchaseDate!.month}.${purchaseDate!.year}'
                                : 'Seç',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                // Form doğrulama
                if (_formKey.currentState!.validate()) {
                  try {
                    // Makineyi güncelle (Bu metod gerçek uygulamada tüm alanları alacak şekilde genişletilmeli)
                    // Gerçek uygulamada makine servisi üzerinden makine bilgilerini güncelleyecek bir metot gerekir

                    final updatedMachine = machine.copyWith(
                      name: _machineNameController.text,
                      type: selectedType,
                      serialNumber: _serialNumberController.text.isEmpty ? null : _serialNumberController.text,
                      model: _modelController.text.isEmpty ? null : _modelController.text,
                      manufacturer: _manufacturerController.text.isEmpty ? null : _manufacturerController.text,
                      location: _locationController.text.isEmpty ? null : _locationController.text,
                      installationDate: installationDate,
                      purchaseDate: purchaseDate,
                    );

                    _machineService.updateMachine(updatedMachine);

                    Navigator.pop(context);

                    // Verileri yenile
                    _loadData();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${machine.name} başarıyla güncellendi'),
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
                }
              },
              child: const Text('Güncelle'),
            ),
          ],
        ),
      ),
    );
  }

  // Makine bakımı yapma dialogu
  void _showServiceMachineDialog(Machine machine) {
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${machine.name} Bakımı'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bakım notları:'),
            const SizedBox(height: 8.0),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Yapılan işlemleri ve değiştirilen parçaları giriniz...',
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

  // Bakım sayfasına yönlendirme
  void _navigateToMaintenanceSchedule(Machine machine) {
    Navigator.push(context,
      MaterialPageRoute(
        builder: (context) => MaintenanceSchedulePage(selectedMachine: machine),
      ),
    ).then((_) => _loadData());
  }

  // Silme onayı dialogu
  void _showDeleteConfirmation(Machine machine) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Makine Sil'),
        content: Text('${machine.name} makinesini silmek istediğinize emin misiniz? Bu işlem geri alınamaz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              try {
                // Makineyi sil
                _adminService.removeMachine(machine.id);

                Navigator.pop(context);

                // Verileri yenile
                _loadData();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${machine.name} başarıyla silindi'),
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
            child: const Text('Sil', style: TextStyle(color: Colors.white)),
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
                    label: const Text('Düzenle'),
                    avatar: const Icon(Icons.edit, size: 16),
                    onPressed: () {
                      Navigator.pop(context);
                      _showEditMachineDialog(machine);
                    },
                  ),
                  if (machine.status == MachineStatus.outOfOrder)
                    ActionChip(
                      label: const Text('Bakım Yap'),
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
                      _navigateToMaintenanceSchedule(machine);
                    },
                  ),
                  ActionChip(
                    label: const Text('QR Kodu'),
                    avatar: const Icon(Icons.qr_code, size: 16),
                    onPressed: () {
                      Navigator.pop(context);
                      _showQRCodeDialog(machine);
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
        ],
      ),
    );
  }

  // QR Kod dialogu
  void _showQRCodeDialog(Machine machine) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${machine.name} QR Kodu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 200,
              color: Colors.grey.shade200,
              child: Center(
                child: Text(
                  machine.qrCode ?? 'QR kod mevcut değil',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Gerçek uygulamada burada QR kod görüntüsü olacak',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
          ElevatedButton(
            onPressed: () {
              // Gerçek uygulamada QR kodu yazdırma/paylaşma işlemi
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('QR kod yazdırma simülasyonu'),
                ),
              );
            },
            child: const Text('Yazdır'),
          ),
        ],
      ),
    );
  }

  // Makine detay öğesi
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
}
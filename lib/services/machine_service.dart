import '../models/machine.dart';

/// Makine servisi - Makine operasyonlarını yönetir
class MachineService {
  static final MachineService _instance = MachineService._internal();

  factory MachineService() {
    return _instance;
  }

  MachineService._internal();

  // Bu mock servis gerçek bir API servisi ile değiştirilmelidir
  // Demo amaçlı basit bir liste kullanıyoruz
  static final List<Machine> _machines = [
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
      userId: 'user123',
      endTime: '15:45',
      type: MachineType.washer,
      programType: ProgramType.normalWash,
      totalMinutes: 45,
      remainingMinutes: 25,
    ),
    Machine(
      id: 3,
      name: 'Çamaşır Makinesi 3',
      status: MachineStatus.inUse,
      isUsersMachine: true,
      userId: 'current-user-id',
      endTime: '15:30',
      type: MachineType.washer,
      programType: ProgramType.quickWash,
      totalMinutes: 30,
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
      lastMaintenanceDate: DateTime.now().subtract(const Duration(days: 30)),
    ),
  ];

  // Bakım planları listesi (Admin için)
  static final List<MaintenanceSchedule> _maintenanceSchedules = [];

  // Tüm makineleri getir
  List<Machine> getAllMachines() {
    return List.from(_machines);
  }

  // ID'ye göre makine getir
  Machine? getMachineById(int id) {
    try {
      return _machines.firstWhere((machine) => machine.id == id);
    } catch (e) {
      return null;
    }
  }

  // Tip ve duruma göre makine getir
  List<Machine> getMachinesByTypeAndStatus(MachineType type, MachineStatus? status) {
    return _machines.where((machine) =>
    machine.type == type && (status == null || machine.status == status)
    ).toList();
  }

  // Duruma göre makine getir
  List<Machine> getMachinesByStatus(MachineStatus status) {
    return _machines.where((machine) => machine.status == status).toList();
  }

  // Makineyi güncelle
  void updateMachine(Machine updatedMachine) {
    final index = _machines.indexWhere((machine) => machine.id == updatedMachine.id);
    if (index != -1) {
      _machines[index] = updatedMachine;
    }
  }

  // Belirli bir kullanıcının aktif makinesini getir
  Machine? getUserActiveMachine(String userId) {
    try {
      return _machines.firstWhere(
              (machine) => machine.status == MachineStatus.inUse && machine.userId == userId
      );
    } catch (e) {
      return null;
    }
  }

  // Kullanılabilir makine sayısını getir
  int getAvailableMachineCount(MachineType type) {
    return _machines.where(
            (machine) => machine.type == type && machine.status == MachineStatus.available
    ).length;
  }

  // QR koduna göre makine getir
  Machine? getMachineByQR(String qrCode) {
    final machineId = int.tryParse(qrCode.split(':').last);
    if (machineId != null) {
      return getMachineById(machineId);
    }
    return null;
  }

  // Makine kullanımını başlat
  Machine startMachineUsage(int machineId, String userId, ProgramType programType) {
    final machine = getMachineById(machineId);
    if (machine == null || machine.status != MachineStatus.available) {
      throw Exception('Makine kullanılamaz durumda');
    }

    final updatedMachine = Machine.startUsage(machine, userId, programType);
    updateMachine(updatedMachine);
    return updatedMachine;
  }

  // Makine arızası bildir
  void reportMachineIssue(int machineId) {
    final machine = getMachineById(machineId);
    if (machine != null) {
      final updatedMachine = machine.reportOutOfOrder();
      updateMachine(updatedMachine);
    }
  }

  // Yoğunluk tahmini yap - Saatlik olarak 0-10 arası doluluk skoru döndürür
  Map<int, double> getOccupancyForecast(DateTime date) {
    // Gerçek uygulamada geçmiş verilere dayalı bir tahmin algoritması olacak
    // Burada mock veriler döndürüyoruz

    // Saat başına doluluk tahminleri (0-10 skala, 10 = tamamen dolu)
    final Map<int, double> forecast = {};

    // Sabah saatleri genelde boş
    forecast[7] = 1.0;
    forecast[8] = 2.5;
    forecast[9] = 3.0;

    // Öğle saatleri orta yoğunlukta
    forecast[10] = 4.5;
    forecast[11] = 5.0;
    forecast[12] = 6.0;
    forecast[13] = 5.5;

    // Akşam saatleri en yoğun
    forecast[14] = 6.5;
    forecast[15] = 7.0;
    forecast[16] = 8.0;
    forecast[17] = 9.0;
    forecast[18] = 8.5;
    forecast[19] = 8.0;

    // Gece saatleri tekrar sakin
    forecast[20] = 7.0;
    forecast[21] = 5.5;
    forecast[22] = 4.0;
    forecast[23] = 2.5;

    return forecast;
  }

  // En uygun saatleri öner - 5'in altında yoğunluk olan saatleri listeler
  List<int> suggestBestHours(DateTime date) {
    final forecast = getOccupancyForecast(date);
    return forecast.entries
        .where((entry) => entry.value < 5.0)
        .map((entry) => entry.key)
        .toList();
  }

  // Makinelerin kalan sürelerini güncelle - Zamanlayıcı tarafından periyodik olarak çağrılacak
  void updateAllMachinesRemainingTime() {
    for (final machine in _machines.where((m) => m.status == MachineStatus.inUse)) {
      final updatedMachine = machine.updateRemainingTime();
      updateMachine(updatedMachine);
    }
  }

  // ===== YENİ EKLENEN ADMIN METODLARI =====

  // Yeni makine ekle (Admin için)
  Machine addMachine(String name, MachineType type) {
    // Makine ID'si oluşturma (gerçek uygulamada uygun şekilde yapılmalı)
    final newId = _machines.isEmpty
        ? 1
        : _machines.map((m) => m.id).reduce((a, b) => a > b ? a : b) + 1;

    // Yeni makine oluştur
    final newMachine = Machine(
      id: newId,
      name: name,
      type: type,
      status: MachineStatus.available,
      qrCode: Machine.generateQRCode(newId),
      lastMaintenanceDate: DateTime.now(),
      usageCount: 0,
    );

    // Listeye ekle
    _machines.add(newMachine);

    return newMachine;
  }

  // Makine silme/deaktif etme (Admin için)
  void removeMachine(int machineId) {
    // Uygulamada gerçek silme yapmak yerine, makineyi deaktif ederiz
    // Bu örnekte sadece listeden çıkaracağız
    _machines.removeWhere((machine) => machine.id == machineId);
  }

  // Makine bakımını kaydet (Admin/Teknisyen için)
  Machine serviceMachine(int machineId, String technicianName, String notes) {
    final machine = getMachineById(machineId);
    if (machine == null) {
      throw Exception('Makine bulunamadı');
    }

    // Makineyi bakımdan çıkar ve kullanılabilir yap
    final updatedMachine = machine.markAsServiced().copyWith(
      maintenanceNotes: notes, // Bu alanın Machine sınıfında eklenmesi gerekiyor
      lastMaintenanceBy: technicianName, // Bu alanın Machine sınıfında eklenmesi gerekiyor
    );

    updateMachine(updatedMachine);

    return updatedMachine;
  }

  // Bakım planı oluştur (Admin için)
  MaintenanceSchedule scheduleMaintenance(int machineId, DateTime scheduledDate, String technicianId) {
    final machine = getMachineById(machineId);
    if (machine == null) {
      throw Exception('Makine bulunamadı');
    }

    // Yeni bakım planı oluştur
    final schedule = MaintenanceSchedule(
      id: 'schedule_${_maintenanceSchedules.length + 1}',
      machineId: machineId,
      scheduledDate: scheduledDate,
      technicianId: technicianId,
      status: MaintenanceStatus.scheduled,
      createdAt: DateTime.now(),
    );

    // Listeye ekle
    _maintenanceSchedules.add(schedule);

    return schedule;
  }

  // Bakım planını güncelle (Admin için)
  MaintenanceSchedule updateMaintenanceSchedule(String scheduleId, MaintenanceStatus status, {String? notes}) {
    final index = _maintenanceSchedules.indexWhere((s) => s.id == scheduleId);
    if (index == -1) {
      throw Exception('Bakım planı bulunamadı');
    }

    // Planı güncelle
    final updatedSchedule = _maintenanceSchedules[index].copyWith(
      status: status,
      notes: notes,
      completedAt: status == MaintenanceStatus.completed ? DateTime.now() : null,
    );

    _maintenanceSchedules[index] = updatedSchedule;

    // Eğer bakım tamamlandıysa, makineyi de güncelle
    if (status == MaintenanceStatus.completed) {
      final machine = getMachineById(updatedSchedule.machineId);
      if (machine != null) {
        serviceMachine(machine.id, "Teknisyen", notes ?? "Planlı bakım tamamlandı");
      }
    }

    return updatedSchedule;
  }

  // Teknisyene atanmış bakım planlarını getir
  List<MaintenanceSchedule> getTechnicianSchedules(String technicianId) {
    return _maintenanceSchedules.where((s) =>
    s.technicianId == technicianId &&
        s.status != MaintenanceStatus.completed
    ).toList();
  }

  // Bakım planlarını getir
  List<MaintenanceSchedule> getAllMaintenanceSchedules() {
    return List.from(_maintenanceSchedules);
  }

  // Bakım özeti getir
  Map<String, dynamic> getMaintenanceStats() {
    final allMachines = getAllMachines();
    final totalMachines = allMachines.length;
    final outOfOrderCount = allMachines.where((m) => m.status == MachineStatus.outOfOrder).length;
    final scheduledMaintenances = _maintenanceSchedules.where((s) =>
    s.status == MaintenanceStatus.scheduled
    ).length;

    // Bakım geçmişi - Son 10 tamamlanan bakım
    final recentMaintenance = _maintenanceSchedules
        .where((s) => s.status == MaintenanceStatus.completed)
        .toList()
      ..sort((a, b) => (b.completedAt ?? DateTime.now()).compareTo(a.completedAt ?? DateTime.now()));

    final recentMaintenanceList = recentMaintenance.take(10).toList();

    return {
      'totalMachines': totalMachines,
      'outOfOrderCount': outOfOrderCount,
      'outOfOrderRate': totalMachines > 0 ? (outOfOrderCount / totalMachines) * 100 : 0,
      'scheduledMaintenances': scheduledMaintenances,
      'recentMaintenance': recentMaintenanceList,
    };
  }

  // Makine performans raporunu getir
  Map<String, dynamic> getMachinePerformanceReport(int machineId) {
    final machine = getMachineById(machineId);
    if (machine == null) {
      throw Exception('Makine bulunamadı');
    }

    // Arıza geçmişi - Bu uygulamada simüle ediyoruz
    final issueHistory = _generateMockIssueHistory(machine);

    // Bu makinenin tüm bakımları
    final maintenanceHistory = _maintenanceSchedules
        .where((s) => s.machineId == machineId && s.status == MaintenanceStatus.completed)
        .toList();

    // Kullanım saatleri - Bu uygulamada simüle ediyoruz
    final usageHours = _generateMockUsageHours(machine);

    return {
      'machine': machine,
      'totalUsageCount': machine.usageCount ?? 0,
      'lastMaintenanceDate': machine.lastMaintenanceDate,
      'daysSinceLastMaintenance': machine.lastMaintenanceDate != null ?
      DateTime.now().difference(machine.lastMaintenanceDate!).inDays : null,
      'issueHistory': issueHistory,
      'maintenanceHistory': maintenanceHistory,
      'usageHours': usageHours,
      'reliability': _calculateReliability(machine, issueHistory),
    };
  }

  // Güvenilirlik skoru hesapla (0-100 arası)
  double _calculateReliability(Machine machine, List<dynamic> issueHistory) {
    // Gerçek uygulamada daha karmaşık bir algoritma kullanılacak
    if (machine.usageCount == null || machine.usageCount == 0) {
      return 100.0; // Hiç kullanılmamışsa %100 güvenilir
    }

    double baseReliability = 100.0;

    // Her arıza %10 düşürür
    baseReliability -= (issueHistory.length * 10);

    // Eski makineler daha az güvenilir (bu örnek için)
    final lastMaintenanceDays = machine.lastMaintenanceDate != null ?
    DateTime.now().difference(machine.lastMaintenanceDate!).inDays : 0;

    if (lastMaintenanceDays > 30) {
      baseReliability -= (lastMaintenanceDays - 30) * 0.5; // Her ekstra 2 gün için %1 azalma
    }

    // Sınırla
    return baseReliability.clamp(0.0, 100.0);
  }

  // Mock arıza geçmişi oluştur
  List<Map<String, dynamic>> _generateMockIssueHistory(Machine machine) {
    // Gerçek uygulamada veritabanından gelecek
    return [
      {
        'date': DateTime.now().subtract(const Duration(days: 45)),
        'issue': 'Su tahliye sorunu',
        'reportedBy': 'Öğrenci',
        'resolvedBy': 'Teknisyen',
        'resolutionDate': DateTime.now().subtract(const Duration(days: 44)),
      },
      {
        'date': DateTime.now().subtract(const Duration(days: 90)),
        'issue': 'Kapak kilidi arızası',
        'reportedBy': 'Yurt Personeli',
        'resolvedBy': 'Teknisyen',
        'resolutionDate': DateTime.now().subtract(const Duration(days: 88)),
      },
    ];
  }

  // Mock kullanım saatleri oluştur (son 7 gün)
  Map<String, double> _generateMockUsageHours(Machine machine) {
    // Gerçek uygulamada analitik veriden gelecek
    final result = <String, double>{};

    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = "${date.day}.${date.month}";

      // Rastgele 0-8 saat arası kullanım süresi
      final hours = (machine.id * date.day) % 8 + 0.5;
      result[dateKey] = hours;
    }

    return result;
  }
}

/// Bakım durumu enumları
enum MaintenanceStatus {
  scheduled,   // Planlandı
  inProgress,  // Devam ediyor
  completed,   // Tamamlandı
  cancelled    // İptal edildi
}

/// Bakım plan modeli
class MaintenanceSchedule {
  final String id;
  final int machineId;
  final DateTime scheduledDate;
  final String technicianId;
  final MaintenanceStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? notes;

  MaintenanceSchedule({
    required this.id,
    required this.machineId,
    required this.scheduledDate,
    required this.technicianId,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.notes,
  });

  // Güncelleme için yeni nesne oluştur
  MaintenanceSchedule copyWith({
    String? id,
    int? machineId,
    DateTime? scheduledDate,
    String? technicianId,
    MaintenanceStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
    String? notes,
  }) {
    return MaintenanceSchedule(
      id: id ?? this.id,
      machineId: machineId ?? this.machineId,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      technicianId: technicianId ?? this.technicianId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
    );
  }
}
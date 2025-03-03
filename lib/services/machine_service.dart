import '../models/machine.dart';

/// Makine servisi - Makine operasyonlarını yönetir
class MachineService {
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
}
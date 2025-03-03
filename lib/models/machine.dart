/// Makine durum enumları
enum MachineStatus {
  available,  // Kullanılabilir
  inUse,      // Kullanımda
  outOfOrder  // Arızalı
}

/// Makine tipi enumları
enum MachineType {
  washer,  // Çamaşır makinesi
  dryer    // Kurutma makinesi
}

/// Program tipi
enum ProgramType {
  quickWash,       // Hızlı yıkama
  normalWash,      // Normal yıkama
  heavyWash,       // Yoğun yıkama
  ecoWash,         // Ekonomik yıkama
  quickDry,        // Hızlı kurutma
  normalDry,       // Normal kurutma
  intenseDry       // Yoğun kurutma
}

/// Makine modeli
class Machine {
  final int id;
  final String name;
  final MachineStatus status;
  final bool isUsersMachine;
  final String? startTime;
  final String? endTime;
  final MachineType type;
  final String? qrCode;
  final int? remainingMinutes;
  final String? userId;         // Makinenin şu anki kullanıcısının ID'si
  final ProgramType? programType; // Çalıştırılan program tipi
  final int? totalMinutes;     // Programın toplam süresi
  final bool? isNotifiedOnComplete; // Tamamlandığında bildirim gönderildi mi
  final DateTime? lastMaintenanceDate; // Son bakım tarihi
  final int? usageCount;       // Toplam kullanım sayısı

  Machine({
    required this.id,
    required this.name,
    required this.status,
    this.isUsersMachine = false,
    this.startTime,
    this.endTime,
    required this.type,
    this.qrCode,
    this.remainingMinutes,
    this.userId,
    this.programType,
    this.totalMinutes,
    this.isNotifiedOnComplete = false,
    this.lastMaintenanceDate,
    this.usageCount,
  });

  /// Mock verilerden makine objesi oluşturma
  factory Machine.fromJson(Map<String, dynamic> json) {
    return Machine(
      id: json['id'],
      name: json['name'],
      status: MachineStatus.values.firstWhere(
            (e) => e.toString() == 'MachineStatus.${json['status']}',
      ),
      isUsersMachine: json['isUsersMachine'] ?? false,
      startTime: json['startTime'],
      endTime: json['endTime'],
      type: MachineType.values.firstWhere(
            (e) => e.toString() == 'MachineType.${json['type']}',
      ),
      qrCode: json['qrCode'],
      remainingMinutes: json['remainingMinutes'],
      userId: json['userId'],
      programType: json['programType'] != null
          ? ProgramType.values.firstWhere(
            (e) => e.toString() == 'ProgramType.${json['programType']}',
      )
          : null,
      totalMinutes: json['totalMinutes'],
      isNotifiedOnComplete: json['isNotifiedOnComplete'] ?? false,
      lastMaintenanceDate: json['lastMaintenanceDate'] != null
          ? DateTime.parse(json['lastMaintenanceDate'])
          : null,
      usageCount: json['usageCount'],
    );
  }

  /// Makineyi JSON formatına dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status.toString().split('.').last,
      'isUsersMachine': isUsersMachine,
      'startTime': startTime,
      'endTime': endTime,
      'type': type.toString().split('.').last,
      'qrCode': qrCode,
      'remainingMinutes': remainingMinutes,
      'userId': userId,
      'programType': programType?.toString().split('.').last,
      'totalMinutes': totalMinutes,
      'isNotifiedOnComplete': isNotifiedOnComplete,
      'lastMaintenanceDate': lastMaintenanceDate?.toIso8601String(),
      'usageCount': usageCount,
    };
  }

  /// Durum değişikliği için yeni bir makine objesi oluşturma
  Machine copyWith({
    int? id,
    String? name,
    MachineStatus? status,
    bool? isUsersMachine,
    String? startTime,
    String? endTime,
    MachineType? type,
    String? qrCode,
    int? remainingMinutes,
    String? userId,
    ProgramType? programType,
    int? totalMinutes,
    bool? isNotifiedOnComplete,
    DateTime? lastMaintenanceDate,
    int? usageCount,
  }) {
    return Machine(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      isUsersMachine: isUsersMachine ?? this.isUsersMachine,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      type: type ?? this.type,
      qrCode: qrCode ?? this.qrCode,
      remainingMinutes: remainingMinutes ?? this.remainingMinutes,
      userId: userId ?? this.userId,
      programType: programType ?? this.programType,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      isNotifiedOnComplete: isNotifiedOnComplete ?? this.isNotifiedOnComplete,
      lastMaintenanceDate: lastMaintenanceDate ?? this.lastMaintenanceDate,
      usageCount: usageCount ?? this.usageCount,
    );
  }

  /// Program tipine göre toplam süre hesapla
  static int calculateTotalMinutes(ProgramType programType) {
    switch (programType) {
      case ProgramType.quickWash:
        return 30;
      case ProgramType.normalWash:
        return 45;
      case ProgramType.heavyWash:
        return 65;
      case ProgramType.ecoWash:
        return 55;
      case ProgramType.quickDry:
        return 25;
      case ProgramType.normalDry:
        return 40;
      case ProgramType.intenseDry:
        return 60;
      default:
        return 45; // Varsayılan süre
    }
  }

  /// Kullanıma alma ve programı başlatma
  static Machine startUsage(Machine machine, String userId, ProgramType programType) {
    final now = DateTime.now();
    final totalMinutes = calculateTotalMinutes(programType);

    // Bitiş saatini hesapla
    final endTime = DateTime(
        now.year, now.month, now.day,
        now.hour, now.minute + totalMinutes
    );

    // Bitiş saatini 15:30 formatında çevir
    final formattedEndTime = "${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}";
    // Başlangıç saatini 15:30 formatında çevir
    final formattedStartTime = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    return machine.copyWith(
      status: MachineStatus.inUse,
      isUsersMachine: userId == machine.userId,
      userId: userId,
      startTime: formattedStartTime,
      endTime: formattedEndTime,
      programType: programType,
      totalMinutes: totalMinutes,
      remainingMinutes: totalMinutes,
      isNotifiedOnComplete: false,
      usageCount: (machine.usageCount ?? 0) + 1,
    );
  }

  /// Kalan süreyi güncelle
  Machine updateRemainingTime() {
    if (status != MachineStatus.inUse || remainingMinutes == null) {
      return this;
    }

    final newRemainingMinutes = remainingMinutes! - 1;

    // Eğer süre bitmiş ise makineyi kullanılabilir yap
    if (newRemainingMinutes <= 0) {
      return copyWith(
        status: MachineStatus.available,
        isUsersMachine: false,
        userId: null,
        remainingMinutes: 0,
        isNotifiedOnComplete: true,
      );
    }

    return copyWith(
      remainingMinutes: newRemainingMinutes,
    );
  }

  /// Tamamlanma yüzdesini hesapla
  double getCompletionPercentage() {
    if (totalMinutes == null || remainingMinutes == null || status != MachineStatus.inUse) {
      return 0.0;
    }

    return ((totalMinutes! - remainingMinutes!) / totalMinutes!) * 100.0;
  }

  /// QR Kodu oluştur
  static String generateQRCode(int machineId) {
    return "MACHINE:$machineId";
  }

  /// Arıza bildir
  Machine reportOutOfOrder() {
    return copyWith(
      status: MachineStatus.outOfOrder,
      isUsersMachine: false,
      userId: null,
      remainingMinutes: null,
    );
  }

  /// Bakımdan sonra kullanıma hazırla
  Machine markAsServiced() {
    return copyWith(
      status: MachineStatus.available,
      lastMaintenanceDate: DateTime.now(),
    );
  }
}
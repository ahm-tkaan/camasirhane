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

  // Yeni Eklenen Alanlar - Admin için
  final String? serialNumber;  // Seri numarası
  final String? model;         // Model
  final String? manufacturer;  // Üretici
  final DateTime? installationDate; // Kurulum tarihi
  final DateTime? purchaseDate;    // Satın alma tarihi
  final DateTime? warrantyEndDate; // Garanti bitiş tarihi
  final String? location;       // Konum (Örn: "1. Kat", "A Blok")
  final String? lastMaintenanceBy; // Son bakımı yapan teknisyen
  final String? maintenanceNotes;  // Bakım notları
  final List<DateTime>? maintenanceDates; // Tüm bakım tarihleri
  final int? errorCount;       // Toplam hata sayısı
  final bool? isActive;        // Aktif/pasif durumu

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
    // Yeni Eklenen Alanlar
    this.serialNumber,
    this.model,
    this.manufacturer,
    this.installationDate,
    this.purchaseDate,
    this.warrantyEndDate,
    this.location,
    this.lastMaintenanceBy,
    this.maintenanceNotes,
    this.maintenanceDates,
    this.errorCount,
    this.isActive = true,
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
      // Yeni Eklenen Alanlar
      serialNumber: json['serialNumber'],
      model: json['model'],
      manufacturer: json['manufacturer'],
      installationDate: json['installationDate'] != null
          ? DateTime.parse(json['installationDate'])
          : null,
      purchaseDate: json['purchaseDate'] != null
          ? DateTime.parse(json['purchaseDate'])
          : null,
      warrantyEndDate: json['warrantyEndDate'] != null
          ? DateTime.parse(json['warrantyEndDate'])
          : null,
      location: json['location'],
      lastMaintenanceBy: json['lastMaintenanceBy'],
      maintenanceNotes: json['maintenanceNotes'],
      maintenanceDates: json['maintenanceDates'] != null
          ? (json['maintenanceDates'] as List)
          .map((date) => DateTime.parse(date))
          .toList()
          : null,
      errorCount: json['errorCount'],
      isActive: json['isActive'] ?? true,
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
      // Yeni Eklenen Alanlar
      'serialNumber': serialNumber,
      'model': model,
      'manufacturer': manufacturer,
      'installationDate': installationDate?.toIso8601String(),
      'purchaseDate': purchaseDate?.toIso8601String(),
      'warrantyEndDate': warrantyEndDate?.toIso8601String(),
      'location': location,
      'lastMaintenanceBy': lastMaintenanceBy,
      'maintenanceNotes': maintenanceNotes,
      'maintenanceDates': maintenanceDates?.map((date) => date.toIso8601String()).toList(),
      'errorCount': errorCount,
      'isActive': isActive,
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
    // Yeni Eklenen Alanlar
    String? serialNumber,
    String? model,
    String? manufacturer,
    DateTime? installationDate,
    DateTime? purchaseDate,
    DateTime? warrantyEndDate,
    String? location,
    String? lastMaintenanceBy,
    String? maintenanceNotes,
    List<DateTime>? maintenanceDates,
    int? errorCount,
    bool? isActive,
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
      // Yeni Eklenen Alanlar
      serialNumber: serialNumber ?? this.serialNumber,
      model: model ?? this.model,
      manufacturer: manufacturer ?? this.manufacturer,
      installationDate: installationDate ?? this.installationDate,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      warrantyEndDate: warrantyEndDate ?? this.warrantyEndDate,
      location: location ?? this.location,
      lastMaintenanceBy: lastMaintenanceBy ?? this.lastMaintenanceBy,
      maintenanceNotes: maintenanceNotes ?? this.maintenanceNotes,
      maintenanceDates: maintenanceDates ?? this.maintenanceDates,
      errorCount: errorCount ?? this.errorCount,
      isActive: isActive ?? this.isActive,
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
      errorCount: (errorCount ?? 0) + 1, // Arıza sayısını artır
    );
  }

  /// Bakımdan sonra kullanıma hazırla
  Machine markAsServiced() {
    // Mevcut bakım tarihlerini al ve yeni tarihi ekle
    final List<DateTime> updatedMaintenanceDates = List.from(maintenanceDates ?? []);
    updatedMaintenanceDates.add(DateTime.now());

    return copyWith(
      status: MachineStatus.available,
      lastMaintenanceDate: DateTime.now(),
      maintenanceDates: updatedMaintenanceDates,
    );
  }

  /// Garanti durumunu kontrol et
  bool isUnderWarranty() {
    if (warrantyEndDate == null) return false;
    return DateTime.now().isBefore(warrantyEndDate!);
  }

  /// Son bakımdan bu yana geçen gün sayısını hesapla
  int? getDaysSinceLastMaintenance() {
    if (lastMaintenanceDate == null) return null;
    return DateTime.now().difference(lastMaintenanceDate!).inDays;
  }

  /// Bakım gerekli mi kontrol et (son bakımdan 90 gün geçmişse)
  bool isMaintenanceRequired() {
    final daysSinceLastMaintenance = getDaysSinceLastMaintenance();
    if (daysSinceLastMaintenance == null) return true; // Hiç bakım yapılmamışsa
    return daysSinceLastMaintenance > 90; // 3 aydan fazla olduysa
  }

  /// Makine sağlık puanı hesapla (0-100 arası)
  int calculateHealthScore() {
    if (status == MachineStatus.outOfOrder) return 0;

    int baseScore = 100;

    // Arıza sayısı puanı düşürür
    if (errorCount != null && errorCount! > 0) {
      baseScore -= errorCount! * 5; // Her arıza 5 puan düşürür
    }

    // Son bakımdan uzun zaman geçmişse puanı düşür
    final daysSinceLastMaintenance = getDaysSinceLastMaintenance();
    if (daysSinceLastMaintenance != null) {
      if (daysSinceLastMaintenance > 90) {
        baseScore -= 20; // 3 aydan fazla ise 20 puan düşür
      } else if (daysSinceLastMaintenance > 60) {
        baseScore -= 10; // 2 aydan fazla ise 10 puan düşür
      }
    } else {
      baseScore -= 30; // Hiç bakım yapılmamışsa 30 puan düşür
    }

    // Kullanım sayısına göre puan düşür (çok kullanılmış makineler daha riskli)
    if (usageCount != null && usageCount! > 1000) {
      baseScore -= 15; // 1000'den fazla kullanım varsa 15 puan düşür
    } else if (usageCount != null && usageCount! > 500) {
      baseScore -= 5; // 500'den fazla kullanım varsa 5 puan düşür
    }

    // Sınırla
    return baseScore.clamp(0, 100);
  }
}
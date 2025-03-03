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

/// Makine modeli
class Machine {
  final int id;
  final String name;
  final MachineStatus status;
  final bool isUsersMachine;
  final String? endTime;
  final MachineType type;
  final String? qrCode;
  final int? remainingMinutes;

  Machine({
    required this.id,
    required this.name,
    required this.status,
    this.isUsersMachine = false,
    this.endTime,
    required this.type,
    this.qrCode,
    this.remainingMinutes,
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
      endTime: json['endTime'],
      type: MachineType.values.firstWhere(
            (e) => e.toString() == 'MachineType.${json['type']}',
      ),
      qrCode: json['qrCode'],
      remainingMinutes: json['remainingMinutes'],
    );
  }

  /// Makineyi JSON formatına dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status.toString().split('.').last,
      'isUsersMachine': isUsersMachine,
      'endTime': endTime,
      'type': type.toString().split('.').last,
      'qrCode': qrCode,
      'remainingMinutes': remainingMinutes,
    };
  }

  /// Durum değişikliği için yeni bir makine objesi oluşturma
  Machine copyWith({
    int? id,
    String? name,
    MachineStatus? status,
    bool? isUsersMachine,
    String? endTime,
    MachineType? type,
    String? qrCode,
    int? remainingMinutes,
  }) {
    return Machine(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      isUsersMachine: isUsersMachine ?? this.isUsersMachine,
      endTime: endTime ?? this.endTime,
      type: type ?? this.type,
      qrCode: qrCode ?? this.qrCode,
      remainingMinutes: remainingMinutes ?? this.remainingMinutes,
    );
  }
}
/// Kullanıcı modeli - öğrenci bilgilerini içerir
class User {
  final String id;
  final String studentId;
  final String fullName;
  final String? phoneNumber;
  final String? dormitoryId;
  final String? roomNumber;
  final List<String>? activeMachineIds;
  final String? profileInitials;
  final int? usageCount;

  User({
    required this.id,
    required this.studentId,
    required this.fullName,
    this.phoneNumber,
    this.dormitoryId,
    this.roomNumber,
    this.activeMachineIds,
    this.profileInitials,
    this.usageCount,
  });

  /// Mock verilerden kullanıcı objesi oluşturma
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      studentId: json['studentId'],
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
      dormitoryId: json['dormitoryId'],
      roomNumber: json['roomNumber'],
      activeMachineIds: List<String>.from(json['activeMachineIds'] ?? []),
      profileInitials: json['profileInitials'] ?? _getInitials(json['fullName']),
      usageCount: json['usageCount'],
    );
  }

  /// Kullanıcıyı JSON formatına dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'dormitoryId': dormitoryId,
      'roomNumber': roomNumber,
      'activeMachineIds': activeMachineIds,
      'profileInitials': profileInitials ?? _getInitials(fullName),
      'usageCount': usageCount,
    };
  }

  /// İsimden baş harfleri alma
  static String _getInitials(String fullName) {
    if (fullName.isEmpty) return '';

    List<String> nameParts = fullName.split(' ');
    if (nameParts.length > 1) {
      return nameParts[0][0].toUpperCase() + nameParts[1][0].toUpperCase();
    } else {
      return nameParts[0][0].toUpperCase();
    }
  }

  /// Aktif makineye sahip olup olmadığını kontrol etme
  bool hasActiveMachine() {
    return activeMachineIds != null && activeMachineIds!.isNotEmpty;
  }

  /// Kullanıcı bilgilerini güncelleme
  User copyWith({
    String? id,
    String? studentId,
    String? fullName,
    String? phoneNumber,
    String? dormitoryId,
    String? roomNumber,
    List<String>? activeMachineIds,
    String? profileInitials,
    int? usageCount,
  }) {
    return User(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dormitoryId: dormitoryId ?? this.dormitoryId,
      roomNumber: roomNumber ?? this.roomNumber,
      activeMachineIds: activeMachineIds ?? this.activeMachineIds,
      profileInitials: profileInitials ?? this.profileInitials,
      usageCount: usageCount ?? this.usageCount,
    );
  }
}
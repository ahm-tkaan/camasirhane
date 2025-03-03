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

  // Yeni özellikler - hatırlatıcı ve bildirim tercihleri
  final bool? reminderEnabled;
  final int? reminderMinutes;
  final bool? notificationsEnabled;

  // İstatistik özellikleri
  final Map<String, int>? usageStats; // Örneğin: {'washer': 15, 'dryer': 8}
  final DateTime? lastUsageDate;

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
    this.reminderEnabled = true,
    this.reminderMinutes = 10,
    this.notificationsEnabled = true,
    this.usageStats,
    this.lastUsageDate,
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
      reminderEnabled: json['reminderEnabled'] ?? true,
      reminderMinutes: json['reminderMinutes'] ?? 10,
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      usageStats: json['usageStats'] != null
          ? Map<String, int>.from(json['usageStats'])
          : null,
      lastUsageDate: json['lastUsageDate'] != null
          ? DateTime.parse(json['lastUsageDate'])
          : null,
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
      'reminderEnabled': reminderEnabled,
      'reminderMinutes': reminderMinutes,
      'notificationsEnabled': notificationsEnabled,
      'usageStats': usageStats,
      'lastUsageDate': lastUsageDate?.toIso8601String(),
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
    bool? reminderEnabled,
    int? reminderMinutes,
    bool? notificationsEnabled,
    Map<String, int>? usageStats,
    DateTime? lastUsageDate,
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
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      usageStats: usageStats ?? this.usageStats,
      lastUsageDate: lastUsageDate ?? this.lastUsageDate,
    );
  }

  /// Kullanım istatistiklerini artırma
  User incrementUsageStats(String machineType) {
    final newStats = Map<String, int>.from(usageStats ?? {});
    newStats[machineType] = (newStats[machineType] ?? 0) + 1;

    return copyWith(
      usageStats: newStats,
      usageCount: (usageCount ?? 0) + 1,
      lastUsageDate: DateTime.now(),
    );
  }
}
/// Admin rol enumları
enum AdminRole {
  superAdmin,  // Tam yetkili yönetici
  manager,     // Yurt müdürü
  staff,       // Yurt personeli
  technician   // Teknik personel
}

/// Admin yetki enumları - daha granüler yetki kontrolü için
enum AdminPermission {
  viewDashboard,         // Kontrol panelini görüntüleme
  manageUsers,           // Kullanıcıları yönetme
  manageMachines,        // Makineleri yönetme
  viewReports,           // Raporları görüntüleme
  sendNotifications,     // Bildirim gönderme
  manageSettings,        // Ayarları yönetme
  technicalOperations,   // Teknik işlemler yapma
  assignTechnicians,     // Teknisyen atama
  createAdmin,           // Yeni admin oluşturma
  deleteAdmin            // Admin silme
}

/// Admin modeli
class Admin {
  final String id;
  final String username;
  final String fullName;
  final AdminRole role;
  final List<AdminPermission> permissions;
  final String? email;
  final String? phoneNumber;
  final DateTime createdAt;
  final String? createdBy;
  final DateTime? lastLogin;
  final bool isActive;
  final String? profileInitials;

  Admin({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
    required this.permissions,
    this.email,
    this.phoneNumber,
    required this.createdAt,
    this.createdBy,
    this.lastLogin,
    this.isActive = true,
    this.profileInitials,
  });

  /// Mock verilerden admin objesi oluşturma
  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      id: json['id'],
      username: json['username'],
      fullName: json['fullName'],
      role: AdminRole.values.firstWhere(
            (e) => e.toString() == 'AdminRole.${json['role']}',
      ),
      permissions: (json['permissions'] as List)
          .map((permission) => AdminPermission.values.firstWhere(
            (e) => e.toString() == 'AdminPermission.$permission',
      ))
          .toList(),
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      createdAt: DateTime.parse(json['createdAt']),
      createdBy: json['createdBy'],
      lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
      isActive: json['isActive'] ?? true,
      profileInitials: json['profileInitials'] ?? _getInitials(json['fullName']),
    );
  }

  /// Admin bilgilerini JSON formatına dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'fullName': fullName,
      'role': role.toString().split('.').last,
      'permissions': permissions
          .map((permission) => permission.toString().split('.').last)
          .toList(),
      'email': email,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'lastLogin': lastLogin?.toIso8601String(),
      'isActive': isActive,
      'profileInitials': profileInitials ?? _getInitials(fullName),
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

  /// Belirli bir yetkiye sahip olup olmadığını kontrol etme
  bool hasPermission(AdminPermission permission) {
    return permissions.contains(permission);
  }

  /// Admin bilgilerini güncelleme
  Admin copyWith({
    String? id,
    String? username,
    String? fullName,
    AdminRole? role,
    List<AdminPermission>? permissions,
    String? email,
    String? phoneNumber,
    DateTime? createdAt,
    String? createdBy,
    DateTime? lastLogin,
    bool? isActive,
    String? profileInitials,
  }) {
    return Admin(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
      profileInitials: profileInitials ?? this.profileInitials,
    );
  }

  /// Role göre varsayılan yetkileri döndürme
  static List<AdminPermission> getDefaultPermissions(AdminRole role) {
    switch (role) {
      case AdminRole.superAdmin:
        return AdminPermission.values.toList(); // Tüm yetkiler

      case AdminRole.manager:
        return [
          AdminPermission.viewDashboard,
          AdminPermission.manageUsers,
          AdminPermission.manageMachines,
          AdminPermission.viewReports,
          AdminPermission.sendNotifications,
          AdminPermission.manageSettings,
          AdminPermission.assignTechnicians,
        ];

      case AdminRole.staff:
        return [
          AdminPermission.viewDashboard,
          AdminPermission.viewReports,
          AdminPermission.sendNotifications,
        ];

      case AdminRole.technician:
        return [
          AdminPermission.viewDashboard,
          AdminPermission.manageMachines,
          AdminPermission.technicalOperations,
        ];
    }
  }
}
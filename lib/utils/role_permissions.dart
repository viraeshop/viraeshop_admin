class RolePermissions {
// Manager Screens
  static bool canAccessOrderAcceptance(String role) {
    return ['super_admin', 'order_manager'].contains(role);
  }

  static bool canAccessProcessingManager(String role) {
    return ['super_admin', 'processing_manager'].contains(role);
  }

  static bool canAccessDeliveryManager(String role) {
    return ['super_admin', 'delivery_manager'].contains(role);
  }

  static bool canAccessSuperAdminDashboard(String role) {
    return role == 'super_admin';
  }

// Agent/Staff Screens
  static bool canAccessProcessingTimer(String role) {
    return ['processor', 'processing_manager', 'super_admin'].contains(role);
  }

  static bool canAccessActiveDelivery(String role) {
    return ['driver', 'delivery_manager', 'super_admin'].contains(role);
  }

  static bool canAccessPaymentCollection(String role) {
    return ['driver', 'delivery_manager', 'super_admin'].contains(role);
  }

  static bool canAccessAgentSettlement(String role) {
    return ['driver', 'processor', 'super_admin'].contains(role);
  }

  static bool canAccessOrderTracking(String role) {
    return true; // Everyone
  }
}

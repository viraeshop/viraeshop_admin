class RolePermissions {
  // Manager Screens
  static bool canAccessSuperAdminDashboard(Map<String, dynamic> p) {
    return p['isAdmin'] == true ||
        p['canAcceptOrders'] == true ||
        p['canManageProcessing'] == true ||
        p['canManageDelivery'] == true;
  }

  static bool canAccessOrderAcceptance(Map<String, dynamic> p) {
    return p['isAdmin'] == true || p['canAcceptOrders'] == true;
  }

  static bool canAccessProcessingManager(Map<String, dynamic> p) {
    return p['isAdmin'] == true || p['canManageProcessing'] == true;
  }

  static bool canAccessDeliveryManager(Map<String, dynamic> p) {
    return p['isAdmin'] == true || p['canManageDelivery'] == true;
  }

  // Agent/Staff Screens
  static bool canAccessProcessingTimer(Map<String, dynamic> p) {
    return p['isAdmin'] == true || p['canProcessOrders'] == true;
  }

  static bool canAccessActiveDelivery(Map<String, dynamic> p) {
    return p['isAdmin'] == true || p['canDeliverOrders'] == true;
  }

  static bool canAccessPaymentCollection(Map<String, dynamic> p) {
    return p['isAdmin'] == true || p['canDeliverOrders'] == true;
  }

  static bool canAccessAgentSettlement(Map<String, dynamic> p) {
    return p['isAdmin'] == true || p['canDeliverOrders'] == true;
  }

  static bool canAccessOrderTracking(Map<String, dynamic> p) {
    return true; // Everyone
  }
}

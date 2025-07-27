/// Safe console output utility for preventing UTF-8 encoding issues
/// This utility replaces emoji characters with safe ASCII alternatives
class SafeConsole {
  static void log(String message) {
    // Replace common emoji characters with safe ASCII equivalents
    final safeMessage = message
        .replaceAll('🚀', '[START]')
        .replaceAll('🔥', '[INIT]')
        .replaceAll('✅', '[OK]')
        .replaceAll('🔧', '[MIGRATE]')
        .replaceAll('📄', '[FILE]')
        .replaceAll('📋', '[ORDER]')
        .replaceAll('📊', '[DATA]')
        .replaceAll('🌉', '[BRIDGE]')
        .replaceAll('📡', '[SYNC]')
        .replaceAll('❌', '[ERROR]')
        .replaceAll('⚠️', '[WARNING]')
        .replaceAll('🏪', '[STORE]')
        .replaceAll('🌾', '[FARMER]')
        .replaceAll('📦', '[INVENTORY]')
        .replaceAll('🛒', '[POS]')
        .replaceAll('👥', '[CUSTOMER]')
        .replaceAll('🔗', '[CONNECT]')
        .replaceAll('🌟', '[STATUS]')
        .replaceAll('•', '-');
    
    print(safeMessage);
  }
}

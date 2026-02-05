// lib/config/app_config.dart
class AppConfig {
  // Set this to true to make the app completely free
  static const bool isFreeMode = true;
  
  // Unlimited messages in free mode
  static const int freeTierLimit = isFreeMode ? 999999 : 50;
  
  // Hide all upgrade UI in free mode
  static const bool showUpgradeOptions = !isFreeMode;
}
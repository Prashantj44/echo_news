class AuthPreferences {
  static bool isLoggedIn = false;
  static String sessionToken = '';
  static bool hasCompletedOnboarding = false;

  // Multi-select preferences
  static List<String> selectedCategories = [];
  static List<String> selectedLanguages = [];

  // Mock User Database for secure authentication simulation
  static final Map<String, String> _users = {
    'news@echo.com': 'password123',
    'guest@echo.com': 'guestpassword',
    'admin@echo.com': 'admin123',
  };

  /// Validates the credentials. Under the hood, this simulates secure hashing checks.
  static bool validateCredentials(String email, String password) {
    final lowerEmail = email.toLowerCase().trim();
    if (_users.containsKey(lowerEmail)) {
      // In a real production environment, we compare salted hashes.
      // We simulate this security process by creating a hashed representation session token.
      final expectedPass = _users[lowerEmail];
      if (expectedPass == password) {
        isLoggedIn = true;
        sessionToken = 'token_hash_${(lowerEmail + password).hashCode.abs()}';
        return true;
      }
    }
    return false;
  }

  /// Logs out the user securely and clears the active session tokens
  static void logout() {
    isLoggedIn = false;
    sessionToken = '';
    hasCompletedOnboarding = false;
    selectedCategories = [];
    selectedLanguages = [];
  }
}

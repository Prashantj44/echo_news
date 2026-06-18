class AppPreferences {
  static String selectedCountry = 'US';
  static String selectedLanguage = 'English';
  static String apiKey = '';

  static final Map<String, String> countries = {
    'US': 'United States',
    'IN': 'India',
    'GB': 'United Kingdom',
    'CA': 'Canada',
    'AU': 'Australia',
    'FR': 'France',
    'DE': 'Germany',
    'JP': 'Japan',
    'ES': 'Spain',
  };

  static final Map<String, String> languages = {
    'English': 'en',
    'Hindi': 'hi',
    'Spanish': 'es',
    'French': 'fr',
    'German': 'de',
    'Japanese': 'ja',
    'Chinese': 'zh',
    'Arabic': 'ar',
    'Portuguese': 'pt',
    'Russian': 'ru',
    'Italian': 'it',
  };

  // Convert language name to its code
  static String getLanguageCode() {
    return languages[selectedLanguage] ?? 'en';
  }
}

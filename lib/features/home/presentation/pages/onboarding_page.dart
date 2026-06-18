import 'package:flutter/material.dart';
import '../../../../core/config/auth_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int _currentStep = 0; // 0: Categories, 1: Languages

  // Multi-selection temporary state holders
  final List<String> _selectedCategories = [];
  final List<String> _selectedLanguages = [];

  // Available Categories (label, apiValue, icon, color)
  final List<Map<String, dynamic>> _availableCategories = const [
    {'label': 'Headlines', 'value': 'headlines', 'icon': Icons.bolt, 'color': AppColors.categoryRose},
    {'label': 'World News', 'value': 'world', 'icon': Icons.public, 'color': AppColors.categoryBlue},
    {'label': 'Technology', 'value': 'technology', 'icon': Icons.memory, 'color': AppColors.accentTeal},
    {'label': 'Business', 'value': 'business', 'icon': Icons.analytics, 'color': AppColors.categoryAmber},
    {'label': 'Sports', 'value': 'sports', 'icon': Icons.sports_soccer, 'color': AppColors.categoryGreen},
    {'label': 'Science', 'value': 'science', 'icon': Icons.science, 'color': AppColors.categoryPurple},
    {'label': 'Health', 'value': 'health', 'icon': Icons.favorite, 'color': AppColors.categorySky},
    {'label': 'Entertainment', 'value': 'entertainment', 'icon': Icons.movie_filter, 'color': AppColors.categoryPink},
  ];

  // Available Languages
  final List<String> _availableLanguages = const [
    'English',
    'Hindi',
    'Spanish',
    'French',
    'German',
    'Japanese',
    'Chinese',
    'Arabic',
    'Portuguese',
    'Russian',
    'Italian',
  ];

  void _toggleCategory(String value) {
    setState(() {
      if (_selectedCategories.contains(value)) {
        _selectedCategories.remove(value);
      } else {
        _selectedCategories.add(value);
      }
    });
  }

  void _toggleLanguage(String lang) {
    setState(() {
      if (_selectedLanguages.contains(lang)) {
        _selectedLanguages.remove(lang);
      } else {
        _selectedLanguages.add(lang);
      }
    });
  }

  void _handleNextStep() {
    if (_currentStep == 0) {
      if (_selectedCategories.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one interest to customize your feed!'),
            backgroundColor: AppColors.categoryRose,
          ),
        );
        return;
      }
      setState(() {
        _currentStep = 1;
      });
    } else {
      if (_selectedLanguages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one preferred reading language!'),
            backgroundColor: AppColors.categoryRose,
          ),
        );
        return;
      }

      // Securely save onboarding configurations
      AuthPreferences.selectedCategories = List.from(_selectedCategories);
      AuthPreferences.selectedLanguages = List.from(_selectedLanguages);
      AuthPreferences.hasCompletedOnboarding = true;

      // Navigate to HomePage
      Navigator.of(context).pushReplacementNamed(AppRouter.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'ONBOARDING',
              style: TextStyle(color: AppColors.slateDark, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 2.0),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryIndigo.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Step ${_currentStep + 1} of 2',
                style: const TextStyle(color: AppColors.primaryIndigo, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: AppColors.slate200,
            height: 1.0,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header title based on active step
              Text(
                _currentStep == 0 ? 'Select your Interests' : 'Choose Reading Languages',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.slateDark),
              ),
              const SizedBox(height: 6),
              Text(
                _currentStep == 0
                    ? 'Pick one or more categories. We will combine them chronologically into your secure custom global feed.'
                    : 'Choose your languages. EchoNews World will automatically translate global news feeds to fit these preferences.',
                style: const TextStyle(fontSize: 13, color: AppColors.slate500, height: 1.4, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 24),

              // Content Area
              Expanded(
                child: _currentStep == 0
                    ? _buildInterestsGrid()
                    : _buildLanguagesList(),
              ),

              const SizedBox(height: 24),

              // Bottom Actions
              Row(
                children: [
                  if (_currentStep == 1) ...[
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        setState(() {
                          _currentStep = 0;
                        });
                      },
                      child: const Text(
                        'BACK',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.slate500),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryIndigo,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _handleNextStep,
                      child: Text(
                        _currentStep == 0 ? 'CONTINUE' : 'FINISH & LAUNCH',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.0),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Interests multi-select grid layout
  Widget _buildInterestsGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: _availableCategories.length,
      itemBuilder: (context, index) {
        final cat = _availableCategories[index];
        final isSelected = _selectedCategories.contains(cat['value']);
        final color = cat['color'] as Color;

        return InkWell(
          onTap: () => _toggleCategory(cat['value']),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? color.withValues(alpha: 0.08) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? color : AppColors.slate200,
                width: isSelected ? 2.0 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.015),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  cat['icon'] as IconData,
                  color: isSelected ? color : AppColors.slate500,
                  size: 24,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      cat['label'],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? color : AppColors.slate800,
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle_rounded, color: color, size: 16),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Languages multi-select grid/list layout
  Widget _buildLanguagesList() {
    return ListView.separated(
      itemCount: _availableLanguages.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final lang = _availableLanguages[index];
        final isSelected = _selectedLanguages.contains(lang);

        return InkWell(
          onTap: () => _toggleLanguage(lang),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.accentTeal.withValues(alpha: 0.06) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.accentTeal : AppColors.slate200,
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: isSelected ? AppColors.accentTeal : AppColors.slate200,
                  radius: 16,
                  child: Text(
                    lang[0],
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.slate500,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  lang,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppColors.accentTeal : AppColors.slate800,
                  ),
                ),
                const Spacer(),
                Checkbox(
                  value: isSelected,
                  activeColor: AppColors.accentTeal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  onChanged: (_) => _toggleLanguage(lang),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

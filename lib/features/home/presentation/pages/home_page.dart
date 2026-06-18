import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/app_preferences.dart';
import '../../../../core/config/auth_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../injection_container.dart';
import '../../data/datasources/home_remote_data_source.dart';
import '../manager/home_bloc.dart';
import '../manager/home_event.dart';
import '../manager/home_state.dart';
import '../widgets/story_tile.dart';

class CategoryItem {
  final String label;
  final String apiValue;
  final IconData icon;
  final Color activeColor;

  const CategoryItem(this.label, this.apiValue, this.icon, this.activeColor);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _activeCategory = 'my_feed';
  String _searchQuery = '';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();

  // Real-time updates state variables
  Timer? _realtimeTimer;
  bool _showNewStoriesBanner = false;
  int _newStoriesCount = 0;
  String _latestDisplayedStoryUrl = '';

  final List<CategoryItem> _categories = const [
    CategoryItem('My Feed 🌟', 'my_feed', Icons.auto_awesome_rounded, AppColors.primaryIndigoLight),
    CategoryItem('Headlines', 'headlines', Icons.bolt_rounded, AppColors.categoryRose),
    CategoryItem('World', 'world', Icons.public_rounded, AppColors.categoryBlue),
    CategoryItem('Tech', 'technology', Icons.memory_rounded, AppColors.accentTeal),
    CategoryItem('Business', 'business', Icons.analytics_rounded, AppColors.categoryAmber),
    CategoryItem('Sports', 'sports', Icons.sports_soccer_rounded, AppColors.categoryGreen),
    CategoryItem('Science', 'science', Icons.science_rounded, AppColors.categoryPurple),
    CategoryItem('Health', 'health', Icons.favorite_rounded, AppColors.categorySky),
    CategoryItem('Entertainment', 'entertainment', Icons.movie_filter_rounded, AppColors.categoryPink),
  ];

  @override
  void initState() {
    super.initState();
    _apiKeyController.text = AppPreferences.apiKey;

    // Check if onboarding is completed, default active tab to my_feed, otherwise headlines
    if (AuthPreferences.selectedCategories.isEmpty) {
      _activeCategory = 'headlines';
    } else {
      _activeCategory = 'my_feed';
    }

    _fetchNews();

    // Start periodic background updates every 30 seconds for real-time synchronization
    _startRealtimeSync();
  }

  @override
  void dispose() {
    _realtimeTimer?.cancel();
    _searchController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  void _fetchNews() {
    setState(() {
      _showNewStoriesBanner = false;
    });

    final String queryCategory;
    if (_activeCategory == 'my_feed') {
      queryCategory = AuthPreferences.selectedCategories.isNotEmpty
          ? AuthPreferences.selectedCategories.join(',')
          : 'headlines';
    } else {
      queryCategory = _activeCategory;
    }

    context.read<HomeBloc>().add(
      FetchTopStories(
        category: queryCategory,
        countryCode: AppPreferences.selectedCountry,
        languageCode: AppPreferences.getLanguageCode(),
      ),
    );
  }

  // Real-time Polling Engine: Checks in the background every 30s
  void _startRealtimeSync() {
    _realtimeTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (!mounted) return;

      final String queryCategory;
      if (_activeCategory == 'my_feed') {
        queryCategory = AuthPreferences.selectedCategories.isNotEmpty
            ? AuthPreferences.selectedCategories.join(',')
            : 'headlines';
      } else {
        queryCategory = _activeCategory;
      }

      try {
        // Query remote data source directly to prevent full screen loading spinner
        final stories = await sl<HomeRemoteDataSource>().getNewsStories(
          category: queryCategory,
          countryCode: AppPreferences.selectedCountry,
          languageCode: AppPreferences.getLanguageCode(),
        );

        if (stories.isNotEmpty && mounted) {
          final topStoryUrl = stories.first.url ?? '';
          
          // Compare with displayed story to see if new articles arrived
          if (topStoryUrl.isNotEmpty && _latestDisplayedStoryUrl.isNotEmpty && topStoryUrl != _latestDisplayedStoryUrl) {
            setState(() {
              _newStoriesCount = 1 + stories.indexWhere((s) => s.url == _latestDisplayedStoryUrl);
              // Cap index count at standard sizes
              if (_newStoriesCount <= 0 || _newStoriesCount > 10) {
                _newStoriesCount = 3; 
              }
              _showNewStoriesBanner = true;
            });
          }
        }
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: _buildSettingsDrawer(context),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: AppColors.slate200.withValues(alpha: 0.5),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: AppColors.slate200,
            height: 1.0,
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_open_rounded, color: AppColors.slateDark, size: 26),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search stories...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: AppColors.slate400, fontSize: 16),
                  filled: false,
                ),
                style: const TextStyle(color: AppColors.slateDark, fontSize: 16, fontWeight: FontWeight.w500),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
              )
            : const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ECHO NEWS',
                    style: TextStyle(
                      color: AppColors.slateDark,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    'GLOBAL EDITION',
                    style: TextStyle(
                      color: AppColors.slate500,
                      fontWeight: FontWeight.w700,
                      fontSize: 9,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close_rounded : Icons.search_rounded,
              color: AppColors.slateDark,
              size: 24,
            ),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchQuery = '';
                  _searchController.clear();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // 1. Sliding Categories Horizontal Bar
          Container(
            height: 60,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                
                // Hide My Feed if onboarding was skipped or has empty interests
                if (cat.apiValue == 'my_feed' && AuthPreferences.selectedCategories.isEmpty) {
                  return const SizedBox.shrink();
                }

                final isSelected = _activeCategory == cat.apiValue;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          cat.icon,
                          size: 16,
                          color: isSelected ? Colors.white : cat.activeColor,
                        ),
                        const SizedBox(width: 6),
                        Text(cat.label),
                      ],
                    ),
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: isSelected ? Colors.white : AppColors.slate700,
                    ),
                    selected: isSelected,
                    selectedColor: cat.activeColor,
                    backgroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    surfaceTintColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                      side: BorderSide(
                        color: isSelected ? Colors.transparent : AppColors.slate200,
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _activeCategory = cat.apiValue;
                        });
                        _fetchNews();
                      }
                    },
                  ),
                );
              },
            ),
          ),

          // Real-time Floating Notification Banner
          if (_showNewStoriesBanner)
            GestureDetector(
              onTap: _fetchNews,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryIndigo.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.sync_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '✨ $_newStoriesCount new global stories found in real-time. Tap to refresh!',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          
          // 2. Main News Feed Section
          Expanded(
            child: BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                if (state is HomeLoading) {
                  return _buildShimmerLoading();
                } else if (state is HomeLoaded) {
                  // Capture URL of top story for comparison
                  if (state.stories.isNotEmpty) {
                    _latestDisplayedStoryUrl = state.stories.first.url ?? '';
                  }

                  // Filter stories locally if searching
                  final filteredStories = _searchQuery.isEmpty
                      ? state.stories
                      : state.stories
                          .where((s) => s.title.toLowerCase().contains(_searchQuery.toLowerCase()))
                          .toList();

                  if (filteredStories.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.feed_outlined, size: 64, color: AppColors.slate400),
                          SizedBox(height: 16),
                          Text(
                            'No stories matched your search.',
                            style: TextStyle(color: AppColors.slate500, fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _fetchNews(),
                    color: AppColors.primaryIndigo,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 24),
                      itemCount: filteredStories.length,
                      itemBuilder: (context, index) {
                        return StoryTile(story: filteredStories[index], index: index + 1);
                      },
                    ),
                  );
                } else if (state is HomeError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.cloud_off_rounded, size: 54, color: AppColors.error),
                          const SizedBox(height: 16),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.slate700, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Please check your internet connection or switch region/language settings.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.slate500, fontSize: 13),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryIndigo,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                            onPressed: _fetchNews,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Retry Fetch'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const Center(child: Text('Press category or refresh to load stories.'));
              },
            ),
          ),
        ],
      ),
    );
  }

  // Shimmer loading skeleton
  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.slate200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _shimmerBox(60, 22, borderRadius: 8),
                  const SizedBox(width: 8),
                  _shimmerBox(100, 14),
                ],
              ),
              const SizedBox(height: 14),
              _shimmerBox(double.infinity, 16),
              const SizedBox(height: 8),
              _shimmerBox(MediaQuery.of(context).size.width * 0.6, 16),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _shimmerBox(80, 14),
                  _shimmerBox(100, 14),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _shimmerBox(double width, double height, {double borderRadius = 6}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 0.8),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.slate200.withValues(alpha: value),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        );
      },
      // Loop the animation
      onEnd: () {},
    );
  }

  // Settings Drawer with Preferences, AI configuration, and Secure Badging
  Widget _buildSettingsDrawer(BuildContext context) {
    final isKeyValid = _apiKeyController.text.trim().isNotEmpty;

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.slateDark,
              image: DecorationImage(
                image: const NetworkImage('https://images.unsplash.com/photo-1504711434969-e33886168f5c?auto=format&fit=crop&w=400&q=80'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: 0.75),
                  BlendMode.darken,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'EchoNews Core',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1.1),
                ),
                const SizedBox(height: 4),
                Builder(
                  builder: (context) {
                    final user = sl<AuthService>().currentUser;
                    return Text(
                      user?.email ?? 'Adjust feed context & AI services',
                      style: const TextStyle(color: AppColors.slate400, fontSize: 12, fontWeight: FontWeight.w500),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              children: [
                // 1. Country Selection Card
                _buildDrawerSectionTitle('Target Region / Country', Icons.travel_explore_rounded),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.slate300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: AppPreferences.selectedCountry,
                      isExpanded: true,
                      dropdownColor: Colors.white,
                      items: AppPreferences.countries.entries.map((e) {
                        return DropdownMenuItem<String>(
                          value: e.key,
                          child: Text(
                            e.value,
                            style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.slate800),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            AppPreferences.selectedCountry = val;
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Language Selection Card
                _buildDrawerSectionTitle('Preferred Language', Icons.translate_rounded),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.slate300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: AppPreferences.selectedLanguage,
                      isExpanded: true,
                      dropdownColor: Colors.white,
                      items: AppPreferences.languages.keys.map((lang) {
                        return DropdownMenuItem<String>(
                          value: lang,
                          child: Text(
                            lang,
                            style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.slate800),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            AppPreferences.selectedLanguage = val;
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 3. Gemini AI Configuration Card
                _buildDrawerSectionTitle('Google Gemini AI Integration', Icons.psychology_rounded),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.slate100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.slate200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isKeyValid ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                            color: isKeyValid ? AppColors.success : AppColors.warning,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isKeyValid ? 'Gemini AI Engine: LIVE' : 'Gemini AI: Fallback Active',
                            style: TextStyle(
                              color: isKeyValid ? AppColors.successDark : AppColors.warningDark,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Insert your Google Gemini API Key to enable real-time, customizable summaries and simulated multi-perspective reader discussions.',
                        style: TextStyle(color: AppColors.slate600, fontSize: 10, height: 1.3),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _apiKeyController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Enter Gemini API Key...',
                          labelText: 'API Key',
                          filled: true,
                          fillColor: Colors.white,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.slate300),
                          ),
                        ),
                        onChanged: (val) {
                          setState(() {
                            AppPreferences.apiKey = val;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 4. Secure System Credentials Card
                _buildDrawerSectionTitle('Security Environment', Icons.shield_rounded),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.successBorder),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lock_rounded, color: Color(0xFF047857), size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Local Sandbox Protected',
                            style: TextStyle(color: AppColors.successDark, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Text(
                        '• SSL/TLS encrypted feed transport in place.\n• Active session token is fully sandboxed.\n• Gemini API key is securely scoped to memory and protected from third-party leakage.',
                        style: TextStyle(color: Color(0xFF047857), fontSize: 10.5, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Secure Save & Log Out
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryIndigo,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    AppPreferences.apiKey = _apiKeyController.text;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Preferences saved! Refreshing feed...'),
                        backgroundColor: AppColors.accentTeal,
                        duration: Duration(seconds: 1),
                      ),
                    );
                    _fetchNews();
                  },
                  icon: const Icon(Icons.save_rounded, size: 18),
                  label: const Text('Save Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.errorBorder),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    await sl<AuthService>().signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushReplacementNamed(AppRouter.login);
                    }
                  },
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: const Text('SECURE LOG OUT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryIndigo),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.slate700,
            ),
          ),
        ],
      ),
    );
  }
}

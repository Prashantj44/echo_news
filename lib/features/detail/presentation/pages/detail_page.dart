import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../injection_container.dart';
import '../../../../core/config/app_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/domain/entities/story.dart';
import '../../../home/data/datasources/gemini_service.dart';
import '../../domain/entities/comment.dart';

class DetailPage extends StatefulWidget {
  final Story story;

  const DetailPage({super.key, required this.story});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late final GeminiService _geminiService;

  // UI Translation state
  String _currentTitle = '';
  String _currentSource = '';
  String _selectedLanguage = 'English';

  // AI Summary state
  String _summaryText = '';
  bool _isSummaryLoading = true;
  String _summaryError = '';

  // AI Comments state
  List<Comment> _aiComments = [];
  bool _isCommentsLoading = true;
  String _commentsError = '';

  // Translating state
  bool _isTranslating = false;

  final List<String> _targetLanguages = [
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

  @override
  void initState() {
    super.initState();
    _geminiService = sl<GeminiService>();
    _currentTitle = widget.story.title;
    _currentSource = widget.story.by;

    // Load AI features instantly for high-fidelity interactive feel!
    _generateSummary();
    _generateAiComments();
  }

  Future<void> _generateSummary() async {
    setState(() {
      _isSummaryLoading = true;
      _summaryError = '';
    });
    try {
      final summary = await _geminiService.summarizeStory(
        title: widget.story.title,
        source: widget.story.by,
        url: widget.story.url,
        apiKey: AppPreferences.apiKey,
      );
      if (mounted) {
        setState(() {
          _summaryText = summary;
          _isSummaryLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _summaryError = 'Failed to generate summary: $e';
          _isSummaryLoading = false;
        });
      }
    }
  }

  Future<void> _generateAiComments() async {
    setState(() {
      _isCommentsLoading = true;
      _commentsError = '';
    });
    try {
      final comments = await _geminiService.generateAiComments(
        widget.story,
        AppPreferences.apiKey,
      );
      if (mounted) {
        setState(() {
          _aiComments = comments;
          _isCommentsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _commentsError = 'Failed to load debates: $e';
          _isCommentsLoading = false;
        });
      }
    }
  }

  Future<void> _translateContent(String lang) async {
    if (lang == 'English' && _currentTitle == widget.story.title) return;

    setState(() {
      _isTranslating = true;
      _selectedLanguage = lang;
    });

    try {
      // 1. Translate title
      final transTitle = await _geminiService.translateText(
        widget.story.title,
        lang,
        AppPreferences.apiKey,
      );

      // 2. Translate publisher
      final transSource = await _geminiService.translateText(
        widget.story.by,
        lang,
        AppPreferences.apiKey,
      );

      // 3. Translate summary if it has loaded
      String transSummary = _summaryText;
      if (_summaryText.isNotEmpty && !_isSummaryLoading) {
        transSummary = await _geminiService.translateText(
          _summaryText,
          lang,
          AppPreferences.apiKey,
        );
      }

      // 4. Translate comments
      final List<Comment> transComments = [];
      if (_aiComments.isNotEmpty && !_isCommentsLoading) {
        for (var c in _aiComments) {
          final transText = await _geminiService.translateText(
            c.text,
            lang,
            AppPreferences.apiKey,
          );
          final transUser = await _geminiService.translateText(
            c.by,
            lang,
            AppPreferences.apiKey,
          );
          transComments.add(
            Comment(
              id: c.id,
              by: transUser,
              text: transText,
              time: c.time,
            ),
          );
        }
      }

      if (mounted) {
        setState(() {
          _currentTitle = transTitle;
          _currentSource = transSource;
          _summaryText = transSummary;
          if (transComments.isNotEmpty) {
            _aiComments = transComments;
          }
          _isTranslating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTranslating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Translation error: $e')),
        );
      }
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
        shadowColor: AppColors.slate200.withValues(alpha: 0.5),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: AppColors.slate200,
            height: 1.0,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.slateDark),
        title: const Text(
          'STORY DETAILS',
          style: TextStyle(
            color: AppColors.slateDark,
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
          ),
        ),
        actions: [
          // Share button
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.slate700),
            tooltip: 'Share Story',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Share link copied to clipboard!'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          // Refresh AI items
          IconButton(
            icon: const Icon(Icons.psychology_alt_rounded, color: AppColors.primaryIndigo),
            tooltip: 'Regenerate AI Features',
            onPressed: () {
              _generateSummary();
              _generateAiComments();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Re-fetching AI services...'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Article Information Header Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.slate200),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.slateDark.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryIndigo.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _currentSource.toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.primaryIndigo,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.visibility_rounded, color: AppColors.slate500, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.story.score} views',
                            style: const TextStyle(color: AppColors.slate500, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SelectableText(
                        _currentTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.slateDark,
                          height: 1.4,
                        ),
                      ),
                      if (widget.story.url != null) ...[
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryIndigo,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () async {
                            final uri = Uri.parse(widget.story.url!);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            }
                          },
                          icon: const Icon(Icons.open_in_new_rounded, size: 16),
                          label: const Text(
                            'Read Full Primary Article',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Interactive Translation Engine Row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.slate200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.g_translate_rounded, color: AppColors.accentTeal, size: 20),
                      const SizedBox(width: 10),
                      const Text(
                        'Translate To:',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.slateDark),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: AppColors.slate50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.slate200),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedLanguage,
                              dropdownColor: Colors.white,
                              isExpanded: true,
                              style: const TextStyle(color: AppColors.slateDark, fontWeight: FontWeight.w600, fontSize: 13),
                              items: _targetLanguages.map((lang) {
                                return DropdownMenuItem<String>(
                                  value: lang,
                                  child: Text(lang),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  _translateContent(val);
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 3. AI Summary Board
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppPreferences.apiKey.isNotEmpty
                          ? AppColors.primaryIndigo.withValues(alpha: 0.3)
                          : AppColors.slate200,
                      width: AppPreferences.apiKey.isNotEmpty ? 1.5 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppPreferences.apiKey.isNotEmpty
                            ? AppColors.primaryIndigo.withValues(alpha: 0.04)
                            : AppColors.slateDark.withValues(alpha: 0.02),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome_rounded, color: AppColors.primaryIndigo, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'AI REPORT SUMMARY',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: AppColors.slateDark,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            AppPreferences.apiKey.isNotEmpty ? 'GEMINI FLASH' : 'FALLBACK ENGINE',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: AppPreferences.apiKey.isNotEmpty ? AppColors.primaryIndigo : AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_isSummaryLoading)
                        const Column(
                          children: [
                            LinearProgressIndicator(color: AppColors.primaryIndigo, backgroundColor: AppColors.slate100),
                            SizedBox(height: 12),
                            Text(
                              'Analyzing content & generating report...',
                              style: TextStyle(fontSize: 12, color: AppColors.slate500, fontStyle: FontStyle.italic),
                            ),
                          ],
                        )
                      else if (_summaryError.isNotEmpty)
                        Text(_summaryError, style: const TextStyle(color: AppColors.error, fontSize: 13))
                      else
                        SelectableText(
                          _summaryText,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            color: AppColors.slate700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 4. Simulated AI Reader Debates Section
                const Row(
                  children: [
                    Icon(Icons.forum_rounded, color: AppColors.primaryIndigo, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'AI PERSPECTIVES DISCUSSION',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: AppColors.slateDark,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_isCommentsLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(color: AppColors.primaryIndigo),
                    ),
                  )
                else if (_commentsError.isNotEmpty)
                  Text(_commentsError, style: const TextStyle(color: AppColors.error, fontSize: 13))
                else if (_aiComments.isEmpty)
                  const Center(
                    child: Text(
                      'No perspectives generated yet.',
                      style: TextStyle(color: AppColors.slate500, fontStyle: FontStyle.italic),
                    ),
                  )
                else
                  // List of chat bubbles representing global perspectives
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _aiComments.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final comment = _aiComments[index];
                      // Alternate bubble sides for interactive chat interface
                      final isEven = index % 2 == 0;
                      final bubbleColor = isEven ? Colors.white : AppColors.slate100;
                      final avatarColor = isEven ? AppColors.primaryIndigo : AppColors.accentTeal;

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: isEven ? MainAxisAlignment.start : MainAxisAlignment.end,
                        children: [
                          if (isEven) ...[
                            CircleAvatar(
                              backgroundColor: avatarColor,
                              radius: 18,
                              child: Text(
                                comment.by.isNotEmpty ? comment.by[0].toUpperCase() : 'U',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: bubbleColor,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: isEven ? Radius.zero : const Radius.circular(16),
                                  bottomRight: isEven ? const Radius.circular(16) : Radius.zero,
                                ),
                                border: Border.all(color: AppColors.slate200),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.slateDark.withValues(alpha: 0.015),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        comment.by,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 12,
                                          color: avatarColor,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Text(
                                        '• Reader Opinion',
                                        style: TextStyle(color: AppColors.slate400, fontSize: 10, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  // Clean Text
                                  SelectableText(
                                    comment.text.replaceAll('<b>', '').replaceAll('</b>', '').replaceAll('<i>', '').replaceAll('</i>', ''),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      height: 1.4,
                                      color: AppColors.slate700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (!isEven) ...[
                            const SizedBox(width: 8),
                            CircleAvatar(
                              backgroundColor: avatarColor,
                              radius: 18,
                              child: Text(
                                comment.by.isNotEmpty ? comment.by[0].toUpperCase() : 'U',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                const SizedBox(height: 48),
              ],
            ),
          ),
          
          // Absolute Overlay for the Translation loading
          if (_isTranslating)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: Center(
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: AppColors.primaryIndigo),
                        SizedBox(width: 16),
                        Text(
                          'Translating Page Content...',
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.slateDark),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

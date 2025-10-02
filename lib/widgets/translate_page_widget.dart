import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../widgets/common/unified_app_bar.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
import '../widgets/common/app_widgets.dart';
import '../tutorial_service.dart';
import '../services/simple_locale.dart';
import '../services/google_translate_service.dart';

class TranslationPage extends StatefulWidget {
  const TranslationPage({super.key});

  @override
  State<TranslationPage> createState() => _TranslationPageState();
}

class _TranslationPageState extends State<TranslationPage>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();
  String _translatedText = '';
  bool _isTranslating = false;
  String _sourceLanguage = 'fr';
  String _targetLanguage = 'bm';
  bool _hasError = false;
  String _errorMessage = '';

  // Animation controllers for smooth UX
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // GlobalKeys for tutorial targets
  final GlobalKey _inputFieldKey = GlobalKey();
  final GlobalKey _swapButtonKey = GlobalKey();
  final GlobalKey _translateButtonKey = GlobalKey();

  // Store reference to SimpleLocale provider
  SimpleLocale? _localeProvider;

  final Map<String, Map<String, dynamic>> _languages = {
    'bm': {
      'name': 'Bamanankan',
      'flag': '🇲🇱',
      'color': AppColors.primaryGreen,
    },
    'fr': {
      'name': 'Français',
      'flag': '🇫🇷',
      'color': AppColors.wisdomTeal,
    },
    'en': {
      'name': 'English',
      'flag': '🇺🇸',
      'color': AppColors.accentOrange,
    },
    'ar': {
      'name': 'العربية',
      'flag': '🇸🇦',
      'color': AppColors.bookBlue,
    },
  };

  // Translation history for enhanced UX
  final List<Map<String, String>> _translationHistory = [];
  final int _maxHistoryLength = 10;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupListeners();
    _checkAndShowTutorial();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Store reference to SimpleLocale provider for safe disposal
    _localeProvider = context.read<SimpleLocale>();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
  }

  void _setupListeners() {
    _textController.addListener(_onTextChanged);
    // Remove focus listener to prevent rebuilds
  }

  void _onTextChanged() {
    if (mounted) {
      setState(() {
        _hasError = false;
        _errorMessage = '';
      });
    }
  }

  @override
  void dispose() {
    // Re-enable notifications when disposing
    _localeProvider?.setNotificationsEnabled(true);

    _fadeController.dispose();
    _scaleController.dispose();
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  Future<void> _checkAndShowTutorial() async {
    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted && !TutorialService.isTutorialShowing()) {
        // Check if we should show tutorial
        bool shouldShow = await TutorialService.shouldShowTutorial('translate');
        if (shouldShow) {
          await Future.delayed(const Duration(milliseconds: 300));
          if (mounted) {
            await TutorialService.showTranslateTutorial(
              context,
              inputFieldKey: _inputFieldKey,
              swapButtonKey: _swapButtonKey,
              translateButtonKey: _translateButtonKey,
            );
          }
        }
      }
    });
  }

  Future<void> _translateText() async {
    if (_textController.text.trim().isEmpty || _isTranslating || !mounted) {
      return;
    }

    final inputText = _textController.text.trim();

    if (!mounted) return;
    setState(() {
      _isTranslating = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      // Add haptic feedback
      HapticFeedback.lightImpact();

      String translation;

      // Enhanced translation logic with better error handling
      if (_sourceLanguage == _targetLanguage) {
        translation = inputText; // Same language, no translation needed
      } else if (_targetLanguage == 'bm') {
        // Translation to Bambara
        translation = await _translateToBambara(inputText, _sourceLanguage);
      } else if (_sourceLanguage == 'bm') {
        // Translation from Bambara
        translation = await _translateFromBambara(inputText, _targetLanguage);
      } else {
        // Translation between other languages
        translation = await _translateBetweenLanguages(
            inputText, _sourceLanguage, _targetLanguage);
      }

      if (!mounted) return;

      // Add to history
      _addToHistory(inputText, translation, _sourceLanguage, _targetLanguage);

      // Animate the result appearance
      _scaleController.reset();
      _scaleController.forward();

      setState(() {
        _translatedText = translation;
        _isTranslating = false;
      });

      _showSuccessSnackbar('Bamanankan kɛra kosɛbɛ!');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isTranslating = false;
        _hasError = true;
        _errorMessage = _getLocalizedErrorMessage(e.toString());
      });

      _showErrorSnackbar(_errorMessage);
    }
  }

  Future<String> _translateToBambara(String text, String sourceLanguage) async {
    try {
      final translatedText = await GoogleTranslateService().translate(
        text: text,
        sourceLanguage: sourceLanguage,
        targetLanguage: 'bm',
      );
      return translatedText;
    } catch (e) {
      throw Exception('Failed to translate to Bambara: $e');
    }
  }

  Future<String> _translateFromBambara(
      String text, String targetLanguage) async {
    try {
      final translatedText = await GoogleTranslateService().translate(
        text: text,
        sourceLanguage: 'bm',
        targetLanguage: targetLanguage,
      );
      return translatedText;
    } catch (e) {
      throw Exception('Failed to translate from Bambara: $e');
    }
  }

  Future<String> _translateBetweenLanguages(
      String text, String source, String target) async {
    try {
      final translatedText = await GoogleTranslateService().translate(
        text: text,
        sourceLanguage: source,
        targetLanguage: target,
      );
      return translatedText;
    } catch (e) {
      throw Exception('Failed to translate between languages: $e');
    }
  }

  void _addToHistory(
      String original, String translated, String source, String target) {
    final historyItem = {
      'original': original,
      'translated': translated,
      'source': source,
      'target': target,
      'timestamp': DateTime.now().toString(),
    };

    _translationHistory.insert(0, historyItem);

    if (_translationHistory.length > _maxHistoryLength) {
      _translationHistory.removeLast();
    }
  }

  String _getLocalizedErrorMessage(String error) {
    if (error.contains('network') || error.contains('connection')) {
      return 'Ɛntɛrinɛti banabaali ye. Segin ka a lajɛ.';
    } else if (error.contains('timeout')) {
      return 'Waati banna. Segin ka a lajɛ.';
    } else {
      return 'Fili ye. Segin ka a lajɛ.';
    }
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.pureWhite),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        action: SnackBarAction(
          label: 'Segin',
          textColor: AppColors.pureWhite,
          onPressed: () => _translateText(),
        ),
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: AppColors.pureWhite),
            const SizedBox(width: AppSpacing.sm),
            Text(message),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _swapLanguages() {
    if (!mounted) return;

    HapticFeedback.selectionClick();

    setState(() {
      final temp = _sourceLanguage;
      _sourceLanguage = _targetLanguage;
      _targetLanguage = temp;

      // Swap text content if available
      if (_translatedText.isNotEmpty) {
        final tempText = _textController.text;
        _textController.text = _translatedText;
        _translatedText = tempText;
      }
    });

    // Animate the swap
    _scaleController.reset();
    _scaleController.forward();
  }

  void _copyToClipboard(String text) {
    if (text.isEmpty) return;

    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.content_copy, color: AppColors.pureWhite),
            const SizedBox(width: AppSpacing.sm),
            const Text('Kopi kɛra!'),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _clearText() {
    if (!mounted) return;

    _textController.clear();
    setState(() {
      _translatedText = '';
      _hasError = false;
      _errorMessage = '';
    });

    HapticFeedback.lightImpact();
  }

  void _showTranslationHistory() {
    if (_translationHistory.isEmpty) {
      _showErrorSnackbar('Bamanankan taarikuw tɛ fɔlɔ.');
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildHistoryBottomSheet(),
    );
  }

  Widget _buildHistoryBottomSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.md),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Icon(Icons.history, color: AppColors.primaryGreen),
                const SizedBox(width: AppSpacing.sm),
                Text('Bamanankan taarikuw', style: AppTextStyles.heading3),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // History list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: _translationHistory.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final item = _translationHistory[index];
                return _buildHistoryItem(item);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, String> item) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: _languages[item['source']]!['color'],
        child: Text(
          _languages[item['source']]!['flag'],
          style: const TextStyle(fontSize: 16),
        ),
      ),
      title: Text(
        item['original']!,
        style: AppTextStyles.bodyMedium,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        item['translated']!,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.mediumGrey),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _languages[item['target']]!['flag'],
            style: const TextStyle(fontSize: 16),
          ),
          IconButton(
            onPressed: () => _copyToClipboard(item['translated']!),
            icon: Icon(Icons.copy, size: 16, color: AppColors.mediumGrey),
          ),
        ],
      ),
      onTap: () {
        Navigator.pop(context);
        _textController.text = item['original']!;
        if (mounted) {
          setState(() {
            _sourceLanguage = item['source']!;
            _targetLanguage = item['target']!;
            _translatedText = item['translated']!;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: UnifiedAppBar(
        title: 'Bamanankan',
        actions: [
          if (_translationHistory.isNotEmpty)
            AppBarActionButton(
              icon: Icons.history,
              onPressed: _showTranslationHistory,
              tooltip: 'Taarikuw',
              backgroundColor: AppColors.surfaceLight,
              iconColor: AppColors.primaryGreen,
            ),
          AppBarActionButton(
            icon: Icons.swap_horiz,
            onPressed: _swapLanguages,
            tooltip: 'Kanw cayali',
            backgroundColor: AppColors.accentSurfaceLight,
            iconColor: AppColors.accentOrange,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: LoadingOverlay(
          isLoading: _isTranslating,
          message: 'Bamanankan ka kɛ...',
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Source language section
                  _buildLanguageSection(
                    title: 'Kan min na',
                    language: _sourceLanguage,
                    isSource: true,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Input text area
                  _buildInputSection(),
                  const SizedBox(height: AppSpacing.lg),

                  // Swap languages button
                  _buildSwapButton(),
                  const SizedBox(height: AppSpacing.lg),

                  // Target language section
                  _buildLanguageSection(
                    title: 'Kan min ma',
                    language: _targetLanguage,
                    isSource: false,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Output text area
                  _buildOutputSection(),
                  const SizedBox(height: AppSpacing.xl),

                  // Translate button
                  _buildTranslateButton(),

                  if (_hasError) ...[
                    const SizedBox(height: AppSpacing.md),
                    _buildErrorSection(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSection({
    required String title,
    required String language,
    required bool isSource,
  }) {
    final languageData = _languages[language]!;
    final color = languageData['color'] as Color;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  isSource ? Icons.input : Icons.output,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(title, style: AppTextStyles.heading4),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: language,
                isExpanded: true,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                style: AppTextStyles.bodyMedium,
                icon: Icon(Icons.arrow_drop_down, color: color),
                items: _languages.entries.map((entry) {
                  final data = entry.value;
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Row(
                      children: [
                        Text(data['flag'],
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: AppSpacing.sm),
                        Text(data['name']),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (mounted && newValue != null) {
                    setState(() {
                      if (isSource) {
                        _sourceLanguage = newValue;
                      } else {
                        _targetLanguage = newValue;
                      }
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  Icons.edit,
                  color: AppColors.primaryGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('Daɲɛ min bɛ ka baara kɛ', style: AppTextStyles.heading4),
              const Spacer(),
              if (_textController.text.isNotEmpty)
                IconButton(
                  onPressed: _clearText,
                  icon: Icon(
                    Icons.clear,
                    color: AppColors.mediumGrey,
                    size: 20,
                  ),
                  tooltip: 'Jate',
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildTextField(),
          const SizedBox(height: AppSpacing.sm),
          _buildInputFooter(),
        ],
      ),
    );
  }

  Widget _buildTextField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.lightGrey,
          width: 1,
        ),
      ),
      child: TextField(
        key: _inputFieldKey,
        controller: _textController,
        focusNode: _textFocusNode,
        maxLines: 5,
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          hintText: 'Sɛbɛnni min bɛ ka bamanankan kɛ...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.mediumGrey,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(AppSpacing.md),
        ),
      ),
    );
  }

  Widget _buildInputFooter() {
    return Row(
      children: [
        Text(
          '${_textController.text.length}/500',
          style: AppTextStyles.bodySmall.copyWith(
            color: _textController.text.length > 400
                ? AppColors.error
                : AppColors.mediumGrey,
          ),
        ),
        const Spacer(),
        if (_languages[_sourceLanguage] != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_languages[_sourceLanguage]!['flag']),
              const SizedBox(width: AppSpacing.xs),
              Text(
                _languages[_sourceLanguage]!['name'],
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.mediumGrey,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildSwapButton() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.accentOrange,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.accentOrange.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            key: _swapButtonKey,
            onPressed: _swapLanguages,
            icon: Icon(
              Icons.swap_vert,
              color: AppColors.pureWhite,
              size: 28,
            ),
            tooltip: 'Kanw cayali',
            padding: const EdgeInsets.all(AppSpacing.md),
          ),
        ),
      ),
    );
  }

  Widget _buildOutputSection() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.wisdomTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    Icons.translate,
                    color: AppColors.wisdomTeal,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text('Bamanankan kɛcogo', style: AppTextStyles.heading4),
                const Spacer(),
                if (_translatedText.isNotEmpty) ...[
                  IconButton(
                    onPressed: () => _copyToClipboard(_translatedText),
                    icon: Icon(
                      Icons.copy,
                      color: AppColors.wisdomTeal,
                      size: 20,
                    ),
                    tooltip: 'Kopi',
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 120),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.lightGrey),
              ),
              padding: const EdgeInsets.all(AppSpacing.md),
              child: _translatedText.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.translate,
                            color: AppColors.mediumGrey,
                            size: 32,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Bamanankan kɛcogo bɛ jira yan',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.mediumGrey,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SelectableText(
                          _translatedText,
                          style: AppTextStyles.bodyMedium,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            if (_languages[_targetLanguage] != null) ...[
                              Text(_languages[_targetLanguage]!['flag']),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                _languages[_targetLanguage]!['name'],
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.mediumGrey,
                                ),
                              ),
                            ],
                            const Spacer(),
                            Text(
                              '${_translatedText.length} characters',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.mediumGrey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTranslateButton() {
    final bool canTranslate =
        _textController.text.trim().isNotEmpty && !_isTranslating;

    return PrimaryButton(
      key: _translateButtonKey,
      text: _isTranslating ? 'Bamanankan ka kɛ...' : 'Bamanankan',
      onPressed: canTranslate
          ? () {
              _translateText();
            }
          : () {},
      isLoading: _isTranslating,
      icon: _isTranslating ? null : Icons.translate,
      width: double.infinity,
    );
  }

  Widget _buildErrorSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              _errorMessage,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
            ),
          ),
          TextButton(
            onPressed: () => _translateText(),
            child: Text('Segin', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

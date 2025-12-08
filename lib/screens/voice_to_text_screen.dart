import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:translator/translator.dart';

class VoiceToTextScreen extends StatefulWidget {
  const VoiceToTextScreen({super.key});

  @override
  State<VoiceToTextScreen> createState() => _VoiceToTextScreenState();
}

class _VoiceToTextScreenState extends State<VoiceToTextScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Speech to text
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _recognizedText = '';
  String _selectedLanguage = 'en';
  bool _isInitialized = false;
  double _confidence = 0.0;

  // Voice Translator
  bool _isListeningTranslator = false;
  String _recognizedTranslatorText = '';
  String _translatedVoiceText = '';
  bool _isTranslatingVoice = false;
  String _sourceLanguageVoice = 'en';
  String _targetLanguageVoice = 'vi';
  final translator = GoogleTranslator();

  // Language data with locale codes
  final Map<String, Map<String, String>> _languages = {
    'en': {'name': 'English', 'locale': 'en_US', 'flag': '🇺🇸'},
    'vi': {'name': 'Tiếng Việt', 'locale': 'vi_VN', 'flag': '🇻🇳'},
    'zh': {'name': '中文', 'locale': 'zh_CN', 'flag': '🇨🇳'},
    'ja': {'name': '日本語', 'locale': 'ja_JP', 'flag': '🇯🇵'},
    'ko': {'name': '한국어', 'locale': 'ko_KR', 'flag': '🇰🇷'},
    'es': {'name': 'Español', 'locale': 'es_ES', 'flag': '🇪🇸'},
    'fr': {'name': 'Français', 'locale': 'fr_FR', 'flag': '🇫🇷'},
    'de': {'name': 'Deutsch', 'locale': 'de_DE', 'flag': '🇩🇪'},
    'th': {'name': 'ภาษาไทย', 'locale': 'th_TH', 'flag': '🇹🇭'},
    'id': {'name': 'Bahasa Indonesia', 'locale': 'id_ID', 'flag': '🇮🇩'},
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _speech = stt.SpeechToText();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    try {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            setState(() {
              _isListening = false;
            });
          }
        },
        onError: (error) {
          setState(() {
            _isListening = false;
          });
          _showError('Error: ${error.errorMsg}');
        },
      );
      
      setState(() {
        _isInitialized = available;
      });

      if (!available) {
        _showError('Speech recognition not available on this device');
      }
    } catch (e) {
      _showError('Failed to initialize speech recognition: $e');
    }
  }

  Future<void> _startListening() async {
    if (!_isInitialized || !_speech.isAvailable) {
      _showError('Speech recognition not available');
      return;
    }

    setState(() {
      _isListening = true;
      _confidence = 0.0;
    });

    await _speech.listen(
      onResult: (result) {
        setState(() {
          _recognizedText = result.recognizedWords;
          _confidence = result.confidence;
        });
      },
      localeId: _languages[_selectedLanguage]!['locale']!,
      listenMode: stt.ListenMode.confirmation,
      cancelOnError: true,
      partialResults: true,
    );
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  void _clearText() {
    setState(() {
      _recognizedText = '';
      _confidence = 0.0;
    });
  }

  void _copyToClipboard() {
    if (_recognizedText.isEmpty) {
      _showError('No text to copy');
      return;
    }
    
    Clipboard.setData(ClipboardData(text: _recognizedText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Text copied to clipboard!'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Select Language',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const Divider(),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: _languages.keys.map((code) {
                    final isSelected = code == _selectedLanguage;
                    return ListTile(
                      leading: Text(
                        _languages[code]!['flag']!,
                        style: const TextStyle(fontSize: 28),
                      ),
                      title: Text(_languages[code]!['name']!),
                      trailing: isSelected
                          ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                          : null,
                      selected: isSelected,
                      onTap: () {
                        setState(() {
                          _selectedLanguage = code;
                        });
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Voice Translator methods
  Future<void> _startListeningTranslator() async {
    if (!_isInitialized || !_speech.isAvailable) {
      _showError('Speech recognition not available');
      return;
    }

    setState(() {
      _isListeningTranslator = true;
      _recognizedTranslatorText = '';
      _translatedVoiceText = '';
    });

    await _speech.listen(
      onResult: (result) {
        setState(() {
          _recognizedTranslatorText = result.recognizedWords;
        });
      },
      localeId: _languages[_sourceLanguageVoice]!['locale']!,
      listenMode: stt.ListenMode.confirmation,
      cancelOnError: true,
      partialResults: true,
    );
  }

  Future<void> _stopListeningTranslator() async {
    await _speech.stop();
    setState(() {
      _isListeningTranslator = false;
    });
    
    // Auto-translate after stopping
    if (_recognizedTranslatorText.isNotEmpty) {
      await _translateVoiceText();
    }
  }

  Future<void> _translateVoiceText() async {
    if (_recognizedTranslatorText.isEmpty) return;

    setState(() {
      _isTranslatingVoice = true;
    });

    try {
      final translation = await translator.translate(
        _recognizedTranslatorText,
        from: _sourceLanguageVoice,
        to: _targetLanguageVoice,
      );

      setState(() {
        _translatedVoiceText = translation.text;
        _isTranslatingVoice = false;
      });
    } catch (e) {
      setState(() {
        _translatedVoiceText = 'Translation error: $e';
        _isTranslatingVoice = false;
      });
    }
  }

  void _swapLanguagesVoice() {
    setState(() {
      final temp = _sourceLanguageVoice;
      _sourceLanguageVoice = _targetLanguageVoice;
      _targetLanguageVoice = temp;
    });
    if (_recognizedTranslatorText.isNotEmpty) {
      _translateVoiceText();
    }
  }

  void _showLanguageSelectorVoice(bool isSource) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  isSource ? 'Select Source Language' : 'Select Target Language',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const Divider(),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: _languages.keys.map((code) {
                    final isSelected = isSource 
                        ? code == _sourceLanguageVoice 
                        : code == _targetLanguageVoice;
                    return ListTile(
                      leading: Text(
                        _languages[code]!['flag']!,
                        style: const TextStyle(fontSize: 28),
                      ),
                      title: Text(_languages[code]!['name']!),
                      trailing: isSelected 
                          ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                          : null,
                      selected: isSelected,
                      onTap: () {
                        setState(() {
                          if (isSource) {
                            _sourceLanguageVoice = code;
                          } else {
                            _targetLanguageVoice = code;
                          }
                        });
                        Navigator.pop(context);
                        if (_recognizedTranslatorText.isNotEmpty) {
                          _translateVoiceText();
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _clearTranslatorText() {
    setState(() {
      _recognizedTranslatorText = '';
      _translatedVoiceText = '';
    });
  }

  void _copyVoiceTranslation() {
    if (_translatedVoiceText.isEmpty) {
      _showError('No translation to copy');
      return;
    }
    
    Clipboard.setData(ClipboardData(text: _translatedVoiceText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Translation copied to clipboard!'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Tools'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Voice to Text', icon: Icon(Icons.mic)),
            Tab(text: 'Voice Translator', icon: Icon(Icons.g_translate)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildVoiceToTextTab(),
          _buildVoiceTranslatorTab(),
        ],
      ),
    );
  }

  Widget _buildVoiceToTextTab() {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Language selector
          Card(
            child: InkWell(
              onTap: _isListening ? null : _showLanguageSelector,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      _languages[_selectedLanguage]!['flag']!,
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recording Language',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _languages[_selectedLanguage]!['name']!,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: _isListening ? colorScheme.onSurface.withValues(alpha: 0.3) : null,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 22),

          // Microphone button
          GestureDetector(
            onTap: _isListening ? _stopListening : _startListening,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isListening ? colorScheme.error : colorScheme.primary,
                boxShadow: _isListening
                    ? [
                        BoxShadow(
                          color: colorScheme.error.withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                size: 44,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Status text
          Text(
            _isListening ? 'Listening...' : 'Tap to start recording',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: _isListening ? colorScheme.error : colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
          ),

          if (!_isInitialized) ...[
            const SizedBox(height: 8),
            Text(
              'Initializing speech recognition...',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
            ),
          ],

          const SizedBox(height: 22),

          // Recognized text display
          Card(
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 200),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.text_fields,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Recognized Text',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const Spacer(),
                      if (_confidence > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 14,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${(_confidence * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const Divider(height: 24),
                  if (_recognizedText.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.mic_none,
                              size: 64,
                              color: colorScheme.onSurface.withValues(alpha: 0.2),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Your recognized text will appear here',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SelectableText(
                      _recognizedText,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            height: 1.5,
                          ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Action buttons
          if (_recognizedText.isNotEmpty)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _clearText,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Clear'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _copyToClipboard,
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildVoiceTranslatorTab() {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Language selector
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _showLanguageSelectorVoice(true),
                      child: Column(
                        children: [
                          Text(
                            _languages[_sourceLanguageVoice]!['flag']!,
                            style: const TextStyle(fontSize: 32),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _languages[_sourceLanguageVoice]!['name']!,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _swapLanguagesVoice,
                    icon: const Icon(Icons.swap_horiz, size: 32),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => _showLanguageSelectorVoice(false),
                      child: Column(
                        children: [
                          Text(
                            _languages[_targetLanguageVoice]!['flag']!,
                            style: const TextStyle(fontSize: 32),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _languages[_targetLanguageVoice]!['name']!,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 22),

          // Microphone button
          GestureDetector(
            onTap: _isListeningTranslator ? _stopListeningTranslator : _startListeningTranslator,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isListeningTranslator ? colorScheme.error : colorScheme.primary,
                boxShadow: _isListeningTranslator
                    ? [
                        BoxShadow(
                          color: colorScheme.error.withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                _isListeningTranslator ? Icons.mic : Icons.mic_none,
                size: 44,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Status text
          Text(
            _isListeningTranslator ? 'Listening...' : 'Tap to start recording',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: _isListeningTranslator ? colorScheme.error : colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
          ),

          if (!_isInitialized) ...[
            const SizedBox(height: 8),
            Text(
              'Initializing speech recognition...',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
            ),
          ],

          const SizedBox(height: 22),

          // Translation result
          if (_isTranslatingVoice)
            const CircularProgressIndicator()
          else if (_recognizedTranslatorText.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recognized Speech',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        IconButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _recognizedTranslatorText));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Copied to clipboard!')),
                            );
                          },
                          icon: const Icon(Icons.copy),
                        ),
                      ],
                    ),
                    const Divider(),
                    SelectableText(
                      _recognizedTranslatorText,
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Translation',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: colorScheme.onPrimaryContainer,
                              ),
                        ),
                        IconButton(
                          onPressed: _copyVoiceTranslation,
                          icon: Icon(
                            Icons.copy,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    SelectableText(
                      _translatedVoiceText,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _clearTranslatorText,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Clear'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                minimumSize: const Size(double.infinity, 0),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

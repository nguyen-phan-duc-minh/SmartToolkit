import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:translator/translator.dart';
import 'dart:io';

class ImageToTextScreen extends StatefulWidget {
  const ImageToTextScreen({super.key});

  @override
  State<ImageToTextScreen> createState() => _ImageToTextScreenState();
}

class _ImageToTextScreenState extends State<ImageToTextScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Image to Text state
  File? _selectedImage;
  String _extractedText = '';
  bool _isProcessing = false;
  final TextRecognizer _textRecognizer = TextRecognizer();

  // Voice Translator state
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _recognizedText = '';
  String _translatedText = '';
  String _sourceLanguage = 'en';
  String _targetLanguage = 'vi';
  final translator = GoogleTranslator();
  bool _isTranslating = false;

  // Language data
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
      await _speech.initialize(
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
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${error.errorMsg}')));
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Speech recognition not available: $e')),
        );
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _extractedText = '';
      });
      await _extractText();
    }
  }

  Future<void> _extractText() async {
    if (_selectedImage == null) return;

    setState(() {
      _isProcessing = true;
      _extractedText = '';
    });

    try {
      final inputImage = InputImage.fromFile(_selectedImage!);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      // Process and clean the extracted text
      String cleanedText = _processExtractedText(recognizedText);

      setState(() {
        _extractedText = cleanedText;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _extractedText =
            'Image processing error: $e\n\nTry:\n• Take a clearer photo\n• Ensure sufficient lighting\n• Text in image should not be blurry';
        _isProcessing = false;
      });
    }
  }

  String _processExtractedText(RecognizedText recognizedText) {
    if (recognizedText.text.isEmpty) {
      return 'No text found in image.\n\nSuggestions:\n• Ensure image contains text\n• Text should be clear and not blurry\n• Try taking photo from different angle\n• Check lighting when taking photo';
    }

    // Get all text blocks and process them
    List<String> processedLines = [];

    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        String lineText = line.text.trim();
        if (lineText.isNotEmpty) {
          processedLines.add(lineText);
        }
      }
    }

    if (processedLines.isEmpty) {
      return 'Cannot read text from this image.\n\nTry:\n• Take photo with higher resolution\n• Ensure text is not tilted\n• Use contrasting background with text';
    }

    // Join lines with proper spacing
    String result = processedLines.join('\n');

    // Add confidence information if available
    double totalConfidence = 0;
    int elementCount = 0;

    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement element in line.elements) {
          totalConfidence += element.confidence ?? 0;
          elementCount++;
        }
      }
    }

    if (elementCount > 0) {
      double avgConfidence = totalConfidence / elementCount;
      String confidenceText = '';

      if (avgConfidence > 0.8) {
        confidenceText =
            '\n\n✅ Confidence: High (${(avgConfidence * 100).toStringAsFixed(1)}%)';
      } else if (avgConfidence > 0.6) {
        confidenceText =
            '\n\n⚠️ Confidence: Medium (${(avgConfidence * 100).toStringAsFixed(1)}%)';
      } else {
        confidenceText =
            '\n\n❌ Confidence: Low (${(avgConfidence * 100).toStringAsFixed(1)}%)\nTry taking a clearer photo.';
      }

      result += confidenceText;
    }

    return result;
  }

  // Voice Translator methods
  void _startListening() async {
    if (!_speech.isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech recognition not available')),
      );
      return;
    }

    setState(() {
      _isListening = true;
      _recognizedText = '';
      _translatedText = '';
    });

    await _speech.listen(
      onResult: (result) {
        setState(() {
          _recognizedText = result.recognizedWords;
        });
        if (result.finalResult) {
          _translateText();
        }
      },
      localeId: _languages[_sourceLanguage]!['locale']!,
    );
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
    });
    if (_recognizedText.isNotEmpty && _translatedText.isEmpty) {
      _translateText();
    }
  }

  Future<void> _translateText() async {
    if (_recognizedText.isEmpty) return;

    setState(() {
      _isTranslating = true;
    });

    try {
      final translation = await translator.translate(
        _recognizedText,
        from: _sourceLanguage,
        to: _targetLanguage,
      );

      setState(() {
        _translatedText = translation.text;
        _isTranslating = false;
      });
    } catch (e) {
      setState(() {
        _translatedText = 'Translation error: $e';
        _isTranslating = false;
      });
    }
  }

  void _swapLanguages() {
    setState(() {
      final temp = _sourceLanguage;
      _sourceLanguage = _targetLanguage;
      _targetLanguage = temp;
      _recognizedText = '';
      _translatedText = '';
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  String _getLanguageName(String code) {
    return _languages[code]!['name']!;
  }

  String _getLanguageFlag(String code) {
    return _languages[code]!['flag']!;
  }

  void _showLanguageSelector(bool isSource) {
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
                        ? code == _sourceLanguage 
                        : code == _targetLanguage;
                    return ListTile(
                      leading: Text(
                        _getLanguageFlag(code),
                        style: const TextStyle(fontSize: 28),
                      ),
                      title: Text(_getLanguageName(code)),
                      trailing: isSelected 
                          ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                          : null,
                      selected: isSelected,
                      onTap: () {
                        setState(() {
                          if (isSource) {
                            _sourceLanguage = code;
                          } else {
                            _targetLanguage = code;
                          }
                          _recognizedText = '';
                          _translatedText = '';
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

  @override
  void dispose() {
    _tabController.dispose();
    _speech.stop();
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Tools'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Image to Text', icon: Icon(Icons.image_search)),
            Tab(text: 'Voice Translator', icon: Icon(Icons.translate)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildImageToTextTab(), _buildVoiceTranslatorTab()],
      ),
    );
  }

  Widget _buildImageToTextTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  'Select Image Source',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt, size: 28),
                        label: const Text('Camera', style: TextStyle(fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo, size: 28),
                        label: const Text('Gallery', style: TextStyle(fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_selectedImage != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Selected Image',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _selectedImage = null;
                              _extractedText = '';
                            });
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reselect'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _selectedImage!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _extractText,
                      icon: const Icon(Icons.text_fields),
                      label: const Text('Extract Text Again'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Extracted Result',
                          style: Theme.of(context).textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_extractedText.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: _extractedText),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Text copied to clipboard!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.copy, size: 18),
                          label: const Text(
                            'Copy',
                            style: TextStyle(fontSize: 12),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            minimumSize: const Size(0, 32),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(
                      minHeight: 120,
                      maxHeight: 300,
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    child: _isProcessing
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Analyzing image...'),
                            ],
                          )
                        : SingleChildScrollView(
                            child: SelectableText(
                              _extractedText.isEmpty
                                  ? 'No text extracted yet\n\nInstructions:\n• Select image from Camera or Gallery\n• Ensure image contains clear text\n• Text should not be too blurry or tilted\n• Best support for English and Vietnamese'
                                  : _extractedText,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontSize: 15, height: 1.4),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceTranslatorTab() {
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
                      onTap: () => _showLanguageSelector(true),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          children: [
                            const Text('From', style: TextStyle(fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(
                              _getLanguageFlag(_sourceLanguage),
                              style: const TextStyle(fontSize: 32),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getLanguageName(_sourceLanguage),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _swapLanguages,
                    icon: const Icon(Icons.swap_horiz),
                    iconSize: 32,
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => _showLanguageSelector(false),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          children: [
                            const Text('To', style: TextStyle(fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(
                              _getLanguageFlag(_targetLanguage),
                              style: const TextStyle(fontSize: 32),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getLanguageName(_targetLanguage),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Microphone button
          GestureDetector(
            onTap: _isListening ? _stopListening : _startListening,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isListening ? Colors.red : Colors.blue,
                boxShadow: [
                  if (_isListening)
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                ],
              ),
              child: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                size: 50,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _isListening ? 'Listening...' : 'Tap to speak',
            style: TextStyle(
              fontSize: 16,
              color: _isListening ? Colors.red : Colors.grey,
              fontWeight: _isListening ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 24),

          // Recognized text
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
                        'Recognized (${_getLanguageName(_sourceLanguage)})',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (_recognizedText.isNotEmpty)
                        IconButton(
                          onPressed: () => _copyToClipboard(_recognizedText),
                          icon: const Icon(Icons.copy, size: 18),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 60),
                    child: SelectableText(
                      _recognizedText.isEmpty
                          ? 'Your speech will appear here...'
                          : _recognizedText,
                      style: TextStyle(
                        fontSize: 16,
                        color: _recognizedText.isEmpty
                            ? Colors.grey
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Translation arrow
          const Icon(Icons.arrow_downward, size: 32, color: Colors.grey),
          const SizedBox(height: 6),

          // Translated text
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Translation (${_getLanguageName(_targetLanguage)})',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      if (_translatedText.isNotEmpty && !_isTranslating)
                        IconButton(
                          onPressed: () => _copyToClipboard(_translatedText),
                          icon: Icon(
                            Icons.copy,
                            size: 18,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 60),
                    child: _isTranslating
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : SelectableText(
                            _translatedText.isEmpty
                                ? 'Translation will appear here...'
                                : _translatedText,
                            style: TextStyle(
                              fontSize: 16,
                              color: _translatedText.isEmpty
                                  ? Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer
                                        .withValues(alpha: 0.6)
                                  : Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

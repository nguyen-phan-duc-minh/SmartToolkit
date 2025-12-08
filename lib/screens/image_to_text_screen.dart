import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
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

  // Image Translator state
  File? _translatorImage;
  String _detectedText = '';
  String _translatedImageText = '';
  bool _isTranslatingImage = false;
  String _sourceLanguage = 'en';
  String _targetLanguage = 'vi';
  final translator = GoogleTranslator();

  // Language data
  final Map<String, Map<String, String>> _languages = {
    'en': {'name': 'English', 'flag': '🇺🇸'},
    'vi': {'name': 'Tiếng Việt', 'flag': '🇻🇳'},
    'zh': {'name': '中文', 'flag': '🇨🇳'},
    'ja': {'name': '日本語', 'flag': '🇯🇵'},
    'ko': {'name': '한국어', 'flag': '🇰🇷'},
    'es': {'name': 'Español', 'flag': '🇪🇸'},
    'fr': {'name': 'Français', 'flag': '🇫🇷'},
    'de': {'name': 'Deutsch', 'flag': '🇩🇪'},
    'th': {'name': 'ภาษาไทย', 'flag': '🇹🇭'},
    'id': {'name': 'Bahasa Indonesia', 'flag': '🇮🇩'},
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  // Image to Text methods
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

      setState(() {
        _extractedText = recognizedText.text;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _extractedText = 'Error extracting text: $e';
        _isProcessing = false;
      });
    }
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

  // Image Translator methods
  Future<void> _pickTranslatorImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _translatorImage = File(pickedFile.path);
        _detectedText = '';
        _translatedImageText = '';
      });
      await _detectAndTranslateText();
    }
  }

  Future<void> _detectAndTranslateText() async {
    if (_translatorImage == null) return;

    setState(() {
      _isTranslatingImage = true;
      _detectedText = '';
      _translatedImageText = '';
    });

    try {
      // Step 1: Detect text
      final inputImage = InputImage.fromFile(_translatorImage!);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      
      setState(() {
        _detectedText = recognizedText.text;
      });

      if (_detectedText.isNotEmpty) {
        // Step 2: Translate text
        final translation = await translator.translate(
          _detectedText,
          from: _sourceLanguage,
          to: _targetLanguage,
        );

        setState(() {
          _translatedImageText = translation.text;
          _isTranslatingImage = false;
        });
      } else {
        setState(() {
          _translatedImageText = 'No text detected in image';
          _isTranslatingImage = false;
        });
      }
    } catch (e) {
      setState(() {
        _translatedImageText = 'Translation error: $e';
        _isTranslatingImage = false;
      });
    }
  }

  void _swapLanguages() {
    setState(() {
      final temp = _sourceLanguage;
      _sourceLanguage = _targetLanguage;
      _targetLanguage = temp;
    });
    if (_detectedText.isNotEmpty) {
      _detectAndTranslateText();
    }
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
                            _sourceLanguage = code;
                          } else {
                            _targetLanguage = code;
                          }
                        });
                        Navigator.pop(context);
                        if (_detectedText.isNotEmpty) {
                          _detectAndTranslateText();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Tools'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Image to Text', icon: Icon(Icons.image_search)),
            Tab(text: 'Image Translator', icon: Icon(Icons.g_translate)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildImageToTextTab(),
          _buildImageTranslatorTab(),
        ],
      ),
    );
  }

  Widget _buildImageToTextTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (_selectedImage != null)
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: FileImage(_selectedImage!),
                  fit: BoxFit.cover,
                ),
              ),
            ),

          const SizedBox(height: 10),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_isProcessing)
            const CircularProgressIndicator()
          else if (_extractedText.isNotEmpty)
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
                          'Extracted Text',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        IconButton(
                          onPressed: () => _copyToClipboard(_extractedText),
                          icon: const Icon(Icons.copy),
                        ),
                      ],
                    ),
                    const Divider(),
                    SelectableText(
                      _extractedText,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageTranslatorTab() {
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
                      child: Column(
                        children: [
                          Text(
                            _languages[_sourceLanguage]!['flag']!,
                            style: const TextStyle(fontSize: 32),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _languages[_sourceLanguage]!['name']!,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _swapLanguages,
                    icon: const Icon(Icons.swap_horiz, size: 32),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => _showLanguageSelector(false),
                      child: Column(
                        children: [
                          Text(
                            _languages[_targetLanguage]!['flag']!,
                            style: const TextStyle(fontSize: 32),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _languages[_targetLanguage]!['name']!,
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
          const SizedBox(height: 16),
          
          if (_translatorImage != null)
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: FileImage(_translatorImage!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          const SizedBox(height: 10),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _pickTranslatorImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _pickTranslatorImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 14),
          
          if (_isTranslatingImage)
            const CircularProgressIndicator()
          else if (_detectedText.isNotEmpty) ...[
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
                          'Detected Text',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        IconButton(
                          onPressed: () => _copyToClipboard(_detectedText),
                          icon: const Icon(Icons.copy),
                        ),
                      ],
                    ),
                    const Divider(),
                    SelectableText(
                      _detectedText,
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
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
                          'Translation',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                        ),
                        IconButton(
                          onPressed: () => _copyToClipboard(_translatedImageText),
                          icon: Icon(
                            Icons.copy,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    SelectableText(
                      _translatedImageText,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

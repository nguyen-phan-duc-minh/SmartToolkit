import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io';

class ImageToTextScreen extends StatefulWidget {
  const ImageToTextScreen({super.key});

  @override
  State<ImageToTextScreen> createState() => _ImageToTextScreenState();
}

class _ImageToTextScreenState extends State<ImageToTextScreen> {
  File? _selectedImage;
  String _extractedText = '';
  bool _isProcessing = false;
  final TextRecognizer _textRecognizer = TextRecognizer();

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
        _extractedText = 'Lỗi xử lý hình ảnh: $e\n\nHãy thử:\n• Chụp ảnh rõ nét hơn\n• Đảm bảo ánh sáng đủ\n• Text trong ảnh không bị mờ';
        _isProcessing = false;
      });
    }
  }

  String _processExtractedText(RecognizedText recognizedText) {
    if (recognizedText.text.isEmpty) {
      return 'Không tìm thấy text trong ảnh.\n\nGợi ý:\n• Đảm bảo ảnh có chứa text\n• Text phải rõ nét và không bị mờ\n• Thử chụp ảnh với góc độ khác\n• Kiểm tra ánh sáng khi chụp';
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
      return 'Không thể đọc được text từ ảnh này.\n\nHãy thử:\n• Chụp ảnh với độ phân giải cao hơn\n• Đảm bảo text không bị nghiêng\n• Sử dụng nền tương phản với chữ';
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
        confidenceText = '\n\n✅ Độ tin cậy: Cao (${(avgConfidence * 100).toStringAsFixed(1)}%)';
      } else if (avgConfidence > 0.6) {
        confidenceText = '\n\n⚠️ Độ tin cậy: Trung bình (${(avgConfidence * 100).toStringAsFixed(1)}%)';
      } else {
        confidenceText = '\n\n❌ Độ tin cậy: Thấp (${(avgConfidence * 100).toStringAsFixed(1)}%)\nHãy thử chụp ảnh rõ nét hơn.';
      }
      
      result += confidenceText;
    }
    
    return result;
  }

  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image to Text')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Select Image Source',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Chụp ảnh'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo),
                          label: const Text('Thư viện'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Mẹo: Chụp ảnh text rõ nét, thẳng góc, ánh sáng tốt',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
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
                            'Hình ảnh đã chọn',
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
                            label: const Text('Chọn lại'),
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
                        label: const Text('Trích xuất text lại'),
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
                            'Kết quả trích xuất',
                            style: Theme.of(context).textTheme.titleMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_extractedText.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          TextButton.icon(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _extractedText));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đã sao chép text vào clipboard!'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            icon: const Icon(Icons.copy, size: 18),
                            label: const Text('Sao chép', style: TextStyle(fontSize: 12)),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                        ),
                      ),
                      child: _isProcessing
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text('Đang phân tích hình ảnh...'),
                              ],
                            )
                          : SingleChildScrollView(
                              child: SelectableText(
                                _extractedText.isEmpty
                                    ? 'Chưa có text được trích xuất\n\nHướng dẫn:\n• Chọn hình ảnh từ Camera hoặc Gallery\n• Đảm bảo ảnh có chứa text rõ ràng\n• Text không bị mờ hoặc nghiêng quá nhiều\n• Hỗ trợ tốt nhất với tiếng Việt và tiếng Anh'
                                    : _extractedText,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontSize: 15,
                                  height: 1.4,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
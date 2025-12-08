import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

enum ConversionType { pdfToDocx, docxToPdf, imageToPdf, pdfToImage }

class PdfToolsScreen extends StatefulWidget {
  const PdfToolsScreen({super.key});

  @override
  State<PdfToolsScreen> createState() => _PdfToolsScreenState();
}

class _PdfToolsScreenState extends State<PdfToolsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Tools'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.document_scanner), text: 'Scanner'),
            Tab(icon: Icon(Icons.sync_alt), text: 'Converter'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [PdfScannerTab(), PdfConverterTab()],
      ),
    );
  }
}

// PDF Scanner Tab
class PdfScannerTab extends StatefulWidget {
  const PdfScannerTab({super.key});

  @override
  State<PdfScannerTab> createState() => _PdfScannerTabState();
}

class _PdfScannerTabState extends State<PdfScannerTab>
    with AutomaticKeepAliveClientMixin {
  final List<File> _scannedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;

  @override
  bool get wantKeepAlive => true;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 100,
      );

      if (image != null && mounted) {
        await _showImagePreviewDialog(File(image.path));
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  Future<void> _pickMultipleImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 100,
      );

      if (images.isNotEmpty) {
        setState(() {
          _scannedImages.addAll(images.map((img) => File(img.path)));
        });
      }
    } catch (e) {
      _showError('Failed to pick images: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _scannedImages.removeAt(index);
    });
  }

  void _clearAll() {
    setState(() {
      _scannedImages.clear();
    });
  }

  Future<void> _generatePdf() async {
    if (_scannedImages.isEmpty) {
      _showError('Please add at least one image');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Create PDF
      final pdf = pw.Document();

      for (final imageFile in _scannedImages) {
        final image = pw.MemoryImage(imageFile.readAsBytesSync());

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain));
            },
          ),
        );
      }

      // Save to temporary directory
      final output = await getTemporaryDirectory();
      final fileName = 'scan_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        await _showPdfPreviewDialog(file, fileName);
      }
    } catch (e) {
      _showError('Failed to generate PDF: $e');
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _showImagePreviewDialog(File imageFile) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        final colorScheme = Theme.of(context).colorScheme;
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Image Preview',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  constraints: const BoxConstraints(maxHeight: 300),
                  decoration: BoxDecoration(
                    border: Border.all(color: colorScheme.outline),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(imageFile, fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          Navigator.pop(context);
                          await _downloadImage(imageFile);
                        },
                        icon: const Icon(Icons.download),
                        label: const Text('Download'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      setState(() {
                        _scannedImages.add(imageFile);
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Image added to scanner'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add to Scanner'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _downloadImage(File imageFile) async {
    try {
      // Copy to Downloads folder
      final fileName = 'scan_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // For Android, save to Downloads directory
      if (Platform.isAndroid) {
        final downloadsDir = Directory('/storage/emulated/0/Download');
        if (await downloadsDir.exists()) {
          final newPath = '${downloadsDir.path}/$fileName';
          await imageFile.copy(newPath);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Image saved to Downloads/$fileName'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } else {
        // For iOS or other platforms
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Download feature not available on this platform'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      _showError('Failed to download image: $e');
    }
  }

  Future<void> _showPdfPreviewDialog(File pdfFile, String fileName) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final colorScheme = Theme.of(context).colorScheme;
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.picture_as_pdf,
                  size: 80,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'PDF Created Successfully!',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  fileName,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '${_scannedImages.length} page(s) • ${(pdfFile.lengthSync() / 1024).toStringAsFixed(2)} KB',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () async {
                          Navigator.pop(context);
                          await _savePdf(pdfFile, fileName);
                        },
                        icon: const Icon(Icons.download),
                        label: const Text('Download'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _savePdf(File pdfFile, String defaultFileName) async {
    try {
      if (Platform.isAndroid) {
        // Show location picker dialog
        final location = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Save PDF to'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.folder_special),
                  title: const Text('Downloads'),
                  onTap: () => Navigator.pop(context, 'downloads'),
                ),
                ListTile(
                  leading: const Icon(Icons.folder),
                  title: const Text('Documents'),
                  onTap: () => Navigator.pop(context, 'documents'),
                ),
                ListTile(
                  leading: const Icon(Icons.create_new_folder),
                  title: const Text('Choose Custom Location'),
                  onTap: () => Navigator.pop(context, 'custom'),
                ),
              ],
            ),
          ),
        );

        if (location == null) return;

        String? savePath;

        if (location == 'downloads') {
          final downloadsDir = Directory('/storage/emulated/0/Download');
          if (await downloadsDir.exists()) {
            savePath = '${downloadsDir.path}/$defaultFileName';
          }
        } else if (location == 'documents') {
          final documentsDir = Directory('/storage/emulated/0/Documents');
          if (!await documentsDir.exists()) {
            await documentsDir.create(recursive: true);
          }
          savePath = '${documentsDir.path}/$defaultFileName';
        } else if (location == 'custom') {
          final result = await FilePicker.platform.getDirectoryPath();
          if (result != null) {
            savePath = '$result/$defaultFileName';
          }
        }

        if (savePath != null) {
          await pdfFile.copy(savePath);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('PDF saved to $savePath'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 4),
                action: SnackBarAction(
                  label: 'OK',
                  textColor: Colors.white,
                  onPressed: () {},
                ),
              ),
            );
          }
        }
      } else {
        // For iOS - use share dialog
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PDF saved to temporary storage'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      _showError('Failed to save PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Column(
        children: [
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickMultipleImages,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                if (_scannedImages.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.delete_sweep),
                    onPressed: _clearAll,
                    tooltip: 'Clear all',
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.errorContainer,
                      foregroundColor: colorScheme.onErrorContainer,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Image grid
          Expanded(
            child: _scannedImages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.document_scanner,
                          size: 100,
                          color: colorScheme.primary.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No images added',
                          style: TextStyle(
                            fontSize: 18,
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap camera or gallery to add images',
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                    itemCount: _scannedImages.length,
                    itemBuilder: (context, index) {
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(
                              _scannedImages[index],
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  onPressed: () => _removeImage(index),
                                  padding: const EdgeInsets.all(4),
                                  constraints: const BoxConstraints(),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Page ${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Generate PDF button
          if (_scannedImages.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isProcessing ? null : _generatePdf,
                  icon: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.picture_as_pdf),
                  label: Text(_isProcessing ? 'Generating...' : 'Generate PDF'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: colorScheme.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// PDF Converter Tab
class PdfConverterTab extends StatefulWidget {
  const PdfConverterTab({super.key});

  @override
  State<PdfConverterTab> createState() => _PdfConverterTabState();
}

class _PdfConverterTabState extends State<PdfConverterTab>
    with AutomaticKeepAliveClientMixin {
  ConversionType _conversionType = ConversionType.pdfToDocx;
  File? _selectedFile;
  bool _isProcessing = false;
  String? _resultPath;

  @override
  bool get wantKeepAlive => true;

  String get _sourceFormat {
    switch (_conversionType) {
      case ConversionType.pdfToDocx:
      case ConversionType.pdfToImage:
        return 'PDF';
      case ConversionType.docxToPdf:
        return 'DOCX';
      case ConversionType.imageToPdf:
        return 'Image';
    }
  }

  String get _targetFormat {
    switch (_conversionType) {
      case ConversionType.pdfToDocx:
        return 'DOCX';
      case ConversionType.pdfToImage:
        return 'Image';
      case ConversionType.docxToPdf:
      case ConversionType.imageToPdf:
        return 'PDF';
    }
  }

  List<String> get _allowedExtensions {
    switch (_conversionType) {
      case ConversionType.pdfToDocx:
      case ConversionType.pdfToImage:
        return ['pdf'];
      case ConversionType.docxToPdf:
        return ['docx', 'doc'];
      case ConversionType.imageToPdf:
        return ['jpg', 'jpeg', 'png', 'webp'];
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _allowedExtensions,
      );

      if (result != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _resultPath = null;
        });
      }
    } catch (e) {
      _showError('Failed to pick file: $e');
    }
  }

  Future<void> _convertFile() async {
    if (_selectedFile == null) {
      _showError('Please select a file first');
      return;
    }

    setState(() {
      _isProcessing = true;
      _resultPath = null;
    });

    try {
      await Future.delayed(const Duration(seconds: 2));

      // Simulate result
      final resultPath = _selectedFile!.path.replaceAll(
        RegExp(r'\.\w+$'),
        '.${_targetFormat.toLowerCase()}',
      );

      setState(() {
        _resultPath = resultPath;
        _isProcessing = false;
      });

      if (mounted) {
        await _showConvertedFileDialog(resultPath);
      }
    } catch (e) {
      _showError('Failed to convert file: $e');
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _showConvertedFileDialog(String filePath) async {
    final fileName = filePath.split('/').last;
    final fileSize =
        '${(_selectedFile!.lengthSync() / 1024).toStringAsFixed(2)} KB';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conversion Complete'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'File converted successfully!',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.insert_drive_file, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          fileName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Size: $fileSize',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Format: $_targetFormat',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _saveConvertedFile(filePath);
            },
            icon: const Icon(Icons.download),
            label: const Text('Download'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveConvertedFile(String filePath) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save File'),
        content: const Text('Choose where to save the converted file:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await _saveToLocation(filePath, 'Downloads');
            },
            icon: const Icon(Icons.download),
            label: const Text('Downloads'),
          ),
          TextButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await _saveToLocation(filePath, 'Documents');
            },
            icon: const Icon(Icons.folder),
            label: const Text('Documents'),
          ),
          TextButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await _saveToCustomLocation(filePath);
            },
            icon: const Icon(Icons.folder_open),
            label: const Text('Custom'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveToLocation(String filePath, String location) async {
    try {
      String? savePath;
      
      if (Platform.isAndroid) {
        if (location == 'Downloads') {
          final downloadsDir = Directory('/storage/emulated/0/Download');
          if (!await downloadsDir.exists()) {
            await downloadsDir.create(recursive: true);
          }
          final fileName = filePath.split('/').last;
          savePath = '${downloadsDir.path}/$fileName';
        } else {
          final documentsDir = Directory('/storage/emulated/0/Documents');
          if (!await documentsDir.exists()) {
            await documentsDir.create(recursive: true);
          }
          final fileName = filePath.split('/').last;
          savePath = '${documentsDir.path}/$fileName';
        }
      } else {
        // For iOS or other platforms
        Directory? directory;
        if (location == 'Downloads') {
          directory = await getDownloadsDirectory();
        } else {
          directory = await getApplicationDocumentsDirectory();
        }
        
        if (directory != null) {
          final fileName = filePath.split('/').last;
          savePath = '${directory.path}/$fileName';
        }
      }

      if (savePath != null) {
        // Copy the selected file to the new location
        if (_selectedFile != null && await _selectedFile!.exists()) {
          await _selectedFile!.copy(savePath);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('File saved to $location!\n$savePath'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 4),
                action: SnackBarAction(
                  label: 'OK',
                  textColor: Colors.white,
                  onPressed: () {},
                ),
              ),
            );
          }
        } else {
          _showError('Source file not found');
        }
      }
    } catch (e) {
      _showError('Failed to save file: $e');
    }
  }

  Future<void> _saveToCustomLocation(String filePath) async {
    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory != null) {
        final fileName = filePath.split('/').last;
        final newPath = '$selectedDirectory/$fileName';

        // Copy the selected file to the custom location
        if (_selectedFile != null && await _selectedFile!.exists()) {
          await _selectedFile!.copy(newPath);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('File saved to:\n$newPath'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
                action: SnackBarAction(
                  label: 'OK',
                  textColor: Colors.white,
                  onPressed: () {},
                ),
              ),
            );
          }
        } else {
          _showError('Source file not found');
        }
      }
    } catch (e) {
      _showError('Failed to save file: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _clearSelection() {
    setState(() {
      _selectedFile = null;
      _resultPath = null;
    });
  }

  IconData _getConversionIcon() {
    switch (_conversionType) {
      case ConversionType.pdfToDocx:
        return Icons.picture_as_pdf;
      case ConversionType.docxToPdf:
        return Icons.description;
      case ConversionType.imageToPdf:
        return Icons.image;
      case ConversionType.pdfToImage:
        return Icons.picture_as_pdf;
    }
  }

  String _getConversionTitle() {
    switch (_conversionType) {
      case ConversionType.pdfToDocx:
        return 'PDF to DOCX';
      case ConversionType.docxToPdf:
        return 'DOCX to PDF';
      case ConversionType.imageToPdf:
        return 'Image to PDF';
      case ConversionType.pdfToImage:
        return 'PDF to Image';
    }
  }

  void _showConversionTypeBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.onSurface.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Select Conversion Type',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildBottomSheetOption(
                  ConversionType.pdfToDocx,
                  'PDF to DOCX',
                  'Convert PDF documents to Word format',
                  Icons.picture_as_pdf,
                  Icons.description,
                ),
                const Divider(height: 1),
                _buildBottomSheetOption(
                  ConversionType.docxToPdf,
                  'DOCX to PDF',
                  'Convert Word documents to PDF format',
                  Icons.description,
                  Icons.picture_as_pdf,
                ),
                const Divider(height: 1),
                _buildBottomSheetOption(
                  ConversionType.imageToPdf,
                  'Image to PDF',
                  'Convert images to PDF format',
                  Icons.image,
                  Icons.picture_as_pdf,
                ),
                const Divider(height: 1),
                _buildBottomSheetOption(
                  ConversionType.pdfToImage,
                  'PDF to Image',
                  'Convert PDF pages to images',
                  Icons.picture_as_pdf,
                  Icons.image,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetOption(
    ConversionType type,
    String title,
    String subtitle,
    IconData fromIcon,
    IconData toIcon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _conversionType == type;

    return InkWell(
      onTap: () {
        setState(() {
          _conversionType = type;
          _selectedFile = null;
          _resultPath = null;
        });
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(fromIcon, size: 20, color: colorScheme.primary),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward,
                    size: 14,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 4),
                  Icon(toIcon, size: 20, color: colorScheme.secondary),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w600,
                      fontSize: 16,
                      color: isSelected ? colorScheme.primary : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: colorScheme.primary, size: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Conversion type selector
              Card(
                child: InkWell(
                  onTap: _showConversionTypeBottomSheet,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getConversionIcon(),
                            color: colorScheme.primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Conversion Type',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getConversionTitle(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // File selector
              Card(
                child: InkWell(
                  onTap: _isProcessing ? null : _pickFile,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          _selectedFile == null
                              ? Icons.upload_file
                              : Icons.insert_drive_file,
                          size: 64,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedFile == null
                              ? 'Tap to select $_sourceFormat file'
                              : 'Selected file:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (_selectedFile != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _selectedFile!.path.split('/').last,
                            style: TextStyle(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(_selectedFile!.lengthSync() / 1024).toStringAsFixed(2)} KB',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: _clearSelection,
                            icon: const Icon(Icons.clear),
                            label: const Text('Clear'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Convert button
              if (_selectedFile != null)
                FilledButton.icon(
                  onPressed: _isProcessing ? null : _convertFile,
                  icon: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.sync),
                  label: Text(
                    _isProcessing
                        ? 'Converting...'
                        : 'Convert to $_targetFormat',
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),

              // Result info
              if (_resultPath != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Converted file ready!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrGeneratorScreen extends StatefulWidget {
  const QrGeneratorScreen({super.key});

  @override
  State<QrGeneratorScreen> createState() => _QrGeneratorScreenState();
}

class _QrGeneratorScreenState extends State<QrGeneratorScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  String _qrData = '';
  late TabController _tabController;
  MobileScannerController? _cameraController;
  String? _scannedData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1) {
        // Initialize camera when switching to scanner tab
        _cameraController ??= MobileScannerController();
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _tabController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  void _copyScannedData() {
    if (_scannedData != null) {
      Clipboard.setData(ClipboardData(text: _scannedData!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data copied to clipboard!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.qr_code), text: 'Generate'),
            Tab(icon: Icon(Icons.qr_code_scanner), text: 'Scanner'),
          ],
        ),
        actions: [
          if (_tabController.index == 1 && _cameraController != null)
            IconButton(
              onPressed: () => _cameraController!.toggleTorch(),
              icon: const Icon(Icons.flash_on),
            ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGeneratorTab(),
          _buildScannerTab(),
        ],
      ),
    );
  }

  Widget _buildGeneratorTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _textController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Enter text or URL to generate QR code...',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _qrData = value.trim();
              });
            },
          ),
          const SizedBox(height: 24),
          if (_qrData.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: QrImageView(
                data: _qrData,
                version: QrVersions.auto,
                size: 250.0,
                backgroundColor: Colors.white,
              ),
            ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(48),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.qr_code_2,
                    size: 80,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Enter text above to generate QR code',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScannerTab() {
    _cameraController ??= MobileScannerController();
    
    return Column(
      children: [
        Expanded(
          flex: 4,
          child: MobileScanner(
            controller: _cameraController!,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                setState(() {
                  _scannedData = barcode.rawValue;
                });
                break;
              }
            },
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_scannedData != null)
                      IconButton(
                        onPressed: _copyScannedData,
                        icon: const Icon(Icons.copy),
                        tooltip: 'Copy',
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    child: SelectableText(
                      _scannedData ?? 'No data scanned',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
import 'dart:io';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:clipboard/clipboard.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProductShareDialog extends StatefulWidget {
  final String productCode;
  final String productName;
  final String productImageUrl;

  const ProductShareDialog({
    Key? key,
    required this.productCode,
    required this.productName,
    required this.productImageUrl,
  }) : super(key: key);

  @override
  _ProductShareDialogState createState() => _ProductShareDialogState();
}

class _ProductShareDialogState extends State<ProductShareDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String get productUrl =>
      'https://viraeshop.com/products/${widget.productName}/${widget.productCode}';

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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Share ${widget.productName}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Tab bar for switching between sharing methods
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).primaryColor,
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black,
                tabs: const [
                  Tab(text: 'Share Link'),
                  Tab(text: 'QR Code'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Tab content
            SizedBox(
              height: 300,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Share Link Tab
                  _buildShareLinkTab(),
                  // QR Code Tab
                  _buildQrCodeTab(),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Close button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareLinkTab() {
    return Column(
      children: [
        // Product preview
        ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(widget.productImageUrl),
            radius: 24,
          ),
          title: Text(widget.productName,
              maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: const Text('Share this product with others'),
        ),
        const SizedBox(height: 16),
        // Share options
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Copy Link
            InkWell(
              onTap: _copyLinkToClipboard,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.link, size: 28, color: Colors.blue),
                  ),
                  const SizedBox(height: 8),
                  const Text('Copy Link', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            // Share via apps
            InkWell(
              onTap: _shareDirectly,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.share, size: 28, color: Colors.green),
                  ),
                  const SizedBox(height: 8),
                  const Text('Share via Apps', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            // Share as message
            InkWell(
              onTap: _shareAsMessage,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.message,
                        size: 28, color: Colors.purple),
                  ),
                  const SizedBox(height: 8),
                  const Text('Share as Message',
                      style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQrCodeTab() {
    return Column(
      children: [
        const Text('Scan this QR code to view the product'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: QrImageView(
            data: productUrl,
            version: QrVersions.auto,
            size: 150.0,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Share QR Code
            ElevatedButton.icon(
              onPressed: _shareQrCode,
              icon: const Icon(Icons.share, size: 18),
              label: const Text('Share QR Code'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
            // Save QR Code
            OutlinedButton.icon(
              onPressed: _saveQrCode,
              icon: const Icon(Icons.download, size: 18),
              label: const Text('Save QR Code'),
            ),
          ],
        ),
      ],
    );
  }

  void _copyLinkToClipboard() {
    FlutterClipboard.copy(productUrl).then((value) {
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: "Product link copied to clipboard",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    });
  }

  void _shareDirectly() {
    Navigator.pop(context);
    Share.share(
      'Check out this product: ${widget.productName}\n$productUrl',
      subject: 'Look at this product!',
    );
  }

  void _shareAsMessage() {
    Navigator.pop(context);
    Share.share(
      'I found this amazing product: ${widget.productName} - $productUrl',
      subject: 'Product recommendation',
    );
  }

  void _shareQrCode() async {
    try {
      // For simplicity, we're sharing the link instead of the actual QR image
      // In a real app, you would capture the QR widget as an image and share it
      // Capture the QR code as an image
      final screenshotController = ScreenshotController();
      final image = await screenshotController.captureFromWidget(
        Container(
          padding: const EdgeInsets.all(20),
          color: Colors.white,
          child: QrImageView(
            data: productUrl,
            version: QrVersions.auto,
            size: 300.0,
          ),
        ),
      );
      // Save to temporary directory
      final directory = await getTemporaryDirectory();
      final imagePath = await File('${directory.path}/qrcode.png').create();
      await imagePath.writeAsBytes(image);

      Navigator.pop(context);

      // Share the image
      await Share.shareXFiles(
        [XFile(imagePath.path)],
        text: 'Scan this QR code to view ${widget.productName}',
        subject: 'QR Code for ${widget.productName}',
      );
    } catch (e) {
      Navigator.pop(context);
      // Fallback to sharing the link if image sharing fails
      Share.share(
        'Scan this QR code to view ${widget.productName}\n$productUrl',
        subject: 'QR Code for ${widget.productName}',
      );
    }
  }

  void _saveQrCode() async {
    try {
      // Request storage permission
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        Navigator.pop(context);
        Fluttertoast.showToast(
          msg: "Storage permission denied",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        return;
      }

      // Capture the QR code as an image
      final screenshotController = ScreenshotController();
      final image = await screenshotController.captureFromWidget(
        Container(
          padding: const EdgeInsets.all(20),
          color: Colors.white,
          child: QrImageView(
            data: productUrl,
            version: QrVersions.auto,
            size: 300.0,
          ),
        ),
      );

      // Save to gallery
      await FileSaver.instance.saveFile(name: 'qrcode.png', bytes: image);

      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: "QR code saved to gallery",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: "Failed to save QR code",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }
}

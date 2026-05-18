// lib/qr_scanner_view.dart (Enhanced Design: Transparent Viewfinder + Animated Line)

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerView extends StatelessWidget {
  const QrScannerView({super.key});

  // Define your primary and secondary colors for consistent themeing
  static const Color primaryColor = Color(0xff261350);
  static const Color secondaryColor = Color(0xff57a2d4); // Accent color for corners and line

  @override
  Widget build(BuildContext context) {
    // Calculate the size for the square viewport (e.g., 70% of the screen width)
    final double scanAreaSize = MediaQuery.of(context).size.width * 0.7;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      // Use a Stack to layer the scanner view and the overlay
      body: Stack(
        children: [
          // 1. The actual MobileScanner widget (full screen)
          MobileScanner(
            onDetect: (BarcodeCapture capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final String scannedData = barcodes.first.rawValue ?? '';
                // CRITICAL LINE: Immediately pop the scanner screen
                if (Navigator.of(context).canPop()) {
                  Navigator.pop(context, scannedData);
                }
              }
            },
          ),

          // 2. The Custom Overlay (Focus Box and Corners)
          _ScannerOverlay(
            scanAreaSize: scanAreaSize,
            overlayColor: Colors.black54, // Dark transparent background
            borderColor: secondaryColor,
          ),

          // 3. The Animated Scan Line, centered over the scanner viewport
          Center(
            child: _AnimatedScanLine(
              size: scanAreaSize,
              lineColor: secondaryColor,
            ),
          ),

          // 4. Informative Text placed centrally above/below the scan area
          Center(
            child: Padding(
              padding: EdgeInsets.only(top: scanAreaSize + 80), // Position below the box
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Align the QR code within the frame',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                      shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Scanning is instant.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: secondaryColor,
                      fontSize: 14.0,
                      shadows: [Shadow(color: Colors.black, blurRadius: 4)],
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

// -------------------------------------------------------------------
// 💡 ANIMATED WIDGET FOR THE SCAN LINE
// -------------------------------------------------------------------
class _AnimatedScanLine extends StatefulWidget {
  final double size;
  final Color lineColor;
  const _AnimatedScanLine({required this.size, required this.lineColor});

  @override
  _AnimatedScanLineState createState() => _AnimatedScanLineState();
}

class _AnimatedScanLineState extends State<_AnimatedScanLine> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: widget.size - 3.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            children: [
              Positioned(
                top: _animation.value,
                child: Container(
                  height: 3,
                  width: widget.size,
                  decoration: BoxDecoration(
                    color: widget.lineColor,
                    boxShadow: [
                      BoxShadow(
                        color: widget.lineColor.withOpacity(0.5),
                        blurRadius: 8.0,
                        spreadRadius: 2.0,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


// -------------------------------------------------------------------
// 💡 CUSTOM OVERLAY WIDGET
// -------------------------------------------------------------------

class _ScannerOverlay extends StatelessWidget {
  final double scanAreaSize;
  final Color overlayColor;
  final Color borderColor;

  const _ScannerOverlay({
    required this.scanAreaSize,
    required this.overlayColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _OverlayPainter(
        scanAreaSize: scanAreaSize,
        overlayColor: overlayColor,
        borderColor: borderColor,
      ),
    );
  }
}

// -------------------------------------------------------------------
// 💡 CUSTOM PAINTER FOR TRANSPARENT CUTOUT AND CORNER DRAWING
// -------------------------------------------------------------------

class _OverlayPainter extends CustomPainter {
  final double scanAreaSize;
  final Color overlayColor;
  final Color borderColor;

  _OverlayPainter({
    required this.scanAreaSize,
    required this.overlayColor,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double halfSize = scanAreaSize / 2;

    // 1. Calculate the scanning rectangle
    final Rect scanRect = Rect.fromLTRB(
      centerX - halfSize,
      centerY - halfSize,
      centerX + halfSize,
      centerY + halfSize,
    );

    // 2. Draw the transparent dark overlay (The "hole" effect)
    final Path path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(scanRect);

    canvas.drawPath(
      path,
      Paint()
        ..color = overlayColor
        ..style = PaintingStyle.fill
        ..blendMode = BlendMode.dstOut, // Make the overlapping area transparent
    );

    // Reset blend mode for drawing the borders
    path.reset();

    // 3. Draw the corner highlights
    final Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;

    const double cornerLength = 30.0;

    // Top Left Corner
    canvas.drawLine(scanRect.topLeft, scanRect.topLeft.translate(cornerLength, 0), borderPaint);
    canvas.drawLine(scanRect.topLeft, scanRect.topLeft.translate(0, cornerLength), borderPaint);

    // Top Right Corner
    canvas.drawLine(scanRect.topRight, scanRect.topRight.translate(-cornerLength, 0), borderPaint);
    canvas.drawLine(scanRect.topRight, scanRect.topRight.translate(0, cornerLength), borderPaint);

    // Bottom Left Corner
    canvas.drawLine(scanRect.bottomLeft, scanRect.bottomLeft.translate(cornerLength, 0), borderPaint);
    canvas.drawLine(scanRect.bottomLeft, scanRect.bottomLeft.translate(0, -cornerLength), borderPaint);

    // Bottom Right Corner
    canvas.drawLine(scanRect.bottomRight, scanRect.bottomRight.translate(-cornerLength, 0), borderPaint);
    canvas.drawLine(scanRect.bottomRight, scanRect.bottomRight.translate(0, -cornerLength), borderPaint);
  }

  @override
  bool shouldRepaint(_OverlayPainter oldDelegate) {
    // Only repaint if the size or colors change
    return oldDelegate.scanAreaSize != scanAreaSize ||
        oldDelegate.overlayColor != overlayColor ||
        oldDelegate.borderColor != borderColor;
  }
}
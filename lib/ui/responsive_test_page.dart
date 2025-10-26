import 'dart:io';

import 'package:flutter/material.dart';

/// Halaman uji responsif: menampilkan dua kolom perbandingan
/// - Kiri: layout menggunakan MediaQuery
/// - Kanan: layout menggunakan LayoutBuilder
/// Setiap sisi menampilkan grid produk sederhana sebagai kotak warna.
class ResponsiveTestPage extends StatelessWidget {
  const ResponsiveTestPage({Key? key}) : super(key: key);

  List<Widget> _buildBoxes(int count, double boxSize) {
    return List.generate(
      count,
      (i) => Container(
        width: boxSize,
        height: boxSize,
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.primaries[i % Colors.primaries.length].shade300,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(child: Text('#${i + 1}', style: const TextStyle(fontWeight: FontWeight.bold))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenW = mq.size.width;
    final screenH = mq.size.height;
    final isLandscape = mq.orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(title: const Text('Uji Responsif — MediaQuery vs LayoutBuilder')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(child: Text('Layar: ${screenW.toStringAsFixed(0)} x ${screenH.toStringAsFixed(0)} — ${isLandscape ? 'Landscape' : 'Portrait'}')),
                  Text(Platform.isWindows ? 'Platform: Windows' : Platform.operatingSystem),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Row(children: [
              // MediaQuery side
              Expanded(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('MediaQuery', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: LayoutBuilder(builder: (context, constraints) {
                        // Use MediaQuery global screen width to decide box size
                        final double screenWidth = mq.size.width;
                        // media-driven: smaller box on small screens
                        final computed = screenWidth / (screenWidth > 800 ? 6 : screenWidth > 600 ? 4 : 3) - 16;
                        final boxSize = computed.clamp(48.0, double.infinity);
                        final boxes = _buildBoxes(12, boxSize);
                        return SingleChildScrollView(
                          child: Wrap(children: boxes),
                        );
                      }),
                    ),
                  ],
                ),
              ),

              const VerticalDivider(width: 16),

              // LayoutBuilder side
              Expanded(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('LayoutBuilder', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: LayoutBuilder(builder: (context, constraints) {
                        // layout-driven: decide box size based on local constraints
                        final double availableW = constraints.maxWidth;
                        final int cols = availableW > 800 ? 6 : availableW > 600 ? 4 : 3;
                        final computed = availableW / cols - 16;
                        final boxSize = computed.clamp(48.0, double.infinity);
                        final boxes = _buildBoxes(12, boxSize);
                        return SingleChildScrollView(child: Wrap(children: boxes));
                      }),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

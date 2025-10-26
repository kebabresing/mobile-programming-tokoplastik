import 'package:flutter/material.dart';
import 'package:toko_plastik_rizky/core/l10n/l10n.dart';
import 'package:toko_plastik_rizky/presentation/product/product_page.dart';
import 'package:toko_plastik_rizky/presentation/supplier/supplier_page.dart';
import 'package:toko_plastik_rizky/presentation/estimate_shipment_cost.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.dashboardTitle)),
      body: LayoutBuilder(builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 800;
        if (!isTablet) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Selamat datang di Toko Plastik Rizky', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 24),
                  Expanded(child: Center(child: _AnimatedButtons())),
                ],
              ),
            ),
          );
        }

        // Tablet / Desktop: persistent left menu + content area
        return Row(
          children: [
            Container(
              width: 260,
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.06),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Toko Plastik Rizky', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.inventory),
                      label: const Padding(padding: EdgeInsets.symmetric(vertical: 12.0), child: Text('Produk')),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductPage())),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.people),
                      label: const Padding(padding: EdgeInsets.symmetric(vertical: 12.0), child: Text('Pemasok')),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SupplierPage())),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.local_shipping),
                      label: const Padding(padding: EdgeInsets.symmetric(vertical: 12.0), child: Text('Estimate Shipment Cost')),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EstimateShipmentCostPage())),
                    ),
                    const SizedBox(height: 24),
                    // additional quick links or stats could go here
                    const Spacer(),
                    Text('Mode Tablet', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Selamat datang di Toko Plastik Rizky', style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 16),
                      // On tablet we show a clean content area and avoid duplicating the menu
                      const Text('Gunakan menu di sebelah kiri untuk mengakses Produk atau Pemasok.'),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.inventory, size: 28),
                                    const SizedBox(height: 8),
                                    Text('Produk', style: Theme.of(context).textTheme.titleMedium),
                                    const SizedBox(height: 4),
                                    const Text('Kelola produk Anda dari panel di kiri.'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.people, size: 28),
                                    const SizedBox(height: 8),
                                    Text('Pemasok', style: Theme.of(context).textTheme.titleMedium),
                                    const SizedBox(height: 4),
                                    const Text('Lihat atau edit pemasok melalui menu kiri.'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _AnimatedButtons extends StatefulWidget {
  const _AnimatedButtons({Key? key}) : super(key: key);

  @override
  State<_AnimatedButtons> createState() => _AnimatedButtonsState();
}

class _AnimatedButtonsState extends State<_AnimatedButtons> {
  bool visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 200), () => setState(() => visible = true));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedOpacity(
          duration: const Duration(milliseconds: 400),
          opacity: visible ? 1 : 0,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 400),
            scale: visible ? 1 : 0.95,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.inventory),
                label: const Padding(padding: EdgeInsets.symmetric(vertical: 12.0), child: Text('Produk')),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductPage())),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 500),
          opacity: visible ? 1 : 0,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 500),
            scale: visible ? 1 : 0.95,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.people),
                label: const Padding(padding: EdgeInsets.symmetric(vertical: 12.0), child: Text('Pemasok')),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SupplierPage())),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 600),
          opacity: visible ? 1 : 0,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 600),
            scale: visible ? 1 : 0.95,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.local_shipping),
                label: const Padding(padding: EdgeInsets.symmetric(vertical: 12.0), child: Text('Estimate Shipment Cost')),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EstimateShipmentCostPage())),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

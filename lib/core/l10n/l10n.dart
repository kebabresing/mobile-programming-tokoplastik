import 'package:flutter/material.dart';

class AppLocalizations {
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  String get dashboardTitle => 'Dashboard Stok';
  String get productTitle => 'Produk Plastik';
  String get addProduct => 'Tambah Produk';
  String get editProduct => 'Edit Produk';
  String get deleteProduct => 'Hapus Produk';
  String get sku => 'SKU';
  String get category => 'Kategori';
  String get price => 'Harga';
  String get stock => 'Stok';
  String get image => 'Gambar';
  String get lowStock => 'Stok Menipis';
  String get lastTransaction => 'Transaksi Terakhir';
  String get storeLocation => 'Lokasi Toko';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'id';

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations();

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

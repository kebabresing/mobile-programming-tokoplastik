import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Small helper page to estimate shipment cost using RajaOngkir Basic API
class EstimateShipmentCostPage extends StatefulWidget {
  const EstimateShipmentCostPage({Key? key}) : super(key: key);

  @override
  State<EstimateShipmentCostPage> createState() => _EstimateShipmentCostPageState();
}

class _EstimateShipmentCostPageState extends State<EstimateShipmentCostPage> {
  static const _apiKey = '06d633b9ccb5870ca5b0f5ca6e075b6e';
  static const _baseUrl = 'https://api.rajaongkir.com/basic';

  bool _loading = false;
  List<dynamic> _provinces = [];
  Map<String, List<dynamic>> _citiesByProvince = {};
  Map<String, bool> _loadingCities = {};

  String? _originProvinceId;
  String? _originCityId;
  String? _destinationProvinceId;
  String? _destinationCityId;
  final _weightController = TextEditingController(text: '1000');
  String _courier = 'jne';
  String _price = 'lowest';

  List<Map<String, dynamic>> _results = [];

  @override
  void initState() {
    super.initState();
    _fetchProvinces();
  }

  Future<void> _fetchProvinces() async {
    setState(() => _loading = true);
    try {
      // Use komerce wrapper endpoint which returns { meta: {...}, data: [...] }
      final res = await http.get(Uri.parse('https://rajaongkir.komerce.id/api/v1/destination/province'), headers: {'Key': _apiKey});
      // Debug log: print status and full response body to help diagnose empty data
      print('KOMERCE RAJAONGKIR /destination/province status=${res.statusCode}');
      print('KOMERCE RAJAONGKIR /destination/province body=${res.body}');

      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final meta = json['meta'];
      final code = meta != null ? meta['code'] as int? : null;
      if (code == null || code != 200) {
        print('KOMERCE RAJAONGKIR /province meta=$meta');
        throw Exception('API error fetching provinces');
      }
      final data = json['data'];
      final list = (data is List ? data : (data != null ? [data] : [])).map((item) {
        // normalize to existing UI shape (province_id / province)
        final id = item['id']?.toString() ?? '';
        final name = item['name']?.toString() ?? '';
        return {'province_id': id, 'province': name};
      }).toList();
      list.sort((a, b) => (a['province'] ?? '').toString().compareTo((b['province'] ?? '').toString()));
      setState(() {
        _provinces = list.cast<dynamic>();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching provinces: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _fetchCities(String provinceId) async {
    // cache per province
    if (_citiesByProvince[provinceId] != null) return;
    setState(() => _loadingCities[provinceId] = true);
    try {
      // komerce city endpoint: returns { meta: {...}, data: [...] }
      final res = await http.get(Uri.parse('https://rajaongkir.komerce.id/api/v1/destination/city/$provinceId'), headers: {'Key': _apiKey});
      // Debug log: print status and body for city fetch
      print('KOMERCE RAJAONGKIR /destination/city/$provinceId status=${res.statusCode}');
      print('KOMERCE RAJAONGKIR /destination/city/$provinceId body=${res.body}');

      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final meta = json['meta'];
      final code = meta != null ? meta['code'] as int? : null;
      if (code == null || code != 200) {
        print('KOMERCE RAJAONGKIR /city meta=$meta');
        throw Exception('API error fetching cities');
      }
      final data = json['data'];
      final list = (data is List ? data : (data != null ? [data] : [])).map((item) {
        final id = item['id']?.toString() ?? '';
        final name = item['name']?.toString() ?? '';
        final zip = item['zip_code']?.toString() ?? '';
        // normalize to previous API shape: city_id, city_name, type
        return {'city_id': id, 'city_name': name, 'type': '', 'zip_code': zip};
      }).toList();
      list.sort((a, b) => (a['city_name'] ?? '').toString().compareTo((b['city_name'] ?? '').toString()));
      setState(() {
        _citiesByProvince[provinceId] = list.cast<dynamic>();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching cities: $e')));
    } finally {
      setState(() => _loadingCities[provinceId] = false);
    }
  }

  Future<void> _estimate() async {
    if (_originCityId == null || _destinationCityId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select origin and destination cities')));
      return;
    }
    final weight = int.tryParse(_weightController.text) ?? 0;
    if (weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid weight in grams')));
      return;
    }

    setState(() {
      _loading = true;
      _results = [];
    });

    try {
      // Use komerce calculate endpoint
      final res = await http.post(
        Uri.parse('https://rajaongkir.komerce.id/api/v1/calculate/domestic-cost'),
        headers: {
          'key': _apiKey,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'origin': _originCityId!,
          'destination': _destinationCityId!,
          'weight': weight.toString(),
          'courier': _courier,
          'price': _price,
        },
      );

      // Debug: print status and full response body for the calculate request
      print('KOMERCE /calculate/domestic-cost status=${res.statusCode}');
      print('KOMERCE /calculate/domestic-cost body=${res.body}');

      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final meta = json['meta'];
      final code = meta != null ? meta['code'] as int? : null;
      if (code == null || code != 200) {
        // Print full response for debugging
        print('Calculate API error response: ${res.body}');
        throw Exception('API error calculating cost');
      }

      final data = json['data'];
      final list = (data is List ? data : (data != null ? [data] : []));
      final parsed = <Map<String, dynamic>>[];
      for (final item in list) {
        parsed.add({
          'courier': item['name'] ?? item['code'] ?? _courier,
          'service': item['service'] ?? '',
          'description': item['description'] ?? '',
          'value': item['cost'] ?? null,
          'etd': item['etd'] ?? null,
        });
      }

      setState(() {
        _results = parsed;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error estimating cost: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estimate Shipment Cost')),
      body: _loading && _provinces.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                const Text('Origin', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        value: _originProvinceId,
                        isExpanded: true,
                        items: _provinces.map((p) {
                          final id = p['province_id'].toString();
                          return DropdownMenuItem(value: id, child: Text(p['province'] ?? ''));
                        }).toList(),
                        onChanged: (v) async {
                          setState(() {
                            _originProvinceId = v;
                            _originCityId = null;
                          });
                          if (v != null) await _fetchCities(v);
                        },
                        decoration: const InputDecoration(labelText: 'Province'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: _loadingCities[_originProvinceId ?? ''] == true
                          ? const SizedBox(height: 56, child: Center(child: CircularProgressIndicator()))
              : DropdownButtonFormField<String>(
                value: _originCityId,
                isExpanded: true,
                              items: (_originProvinceId != null
                                      ? (_citiesByProvince[_originProvinceId!] ?? [])
                                          .map((c) {
                                          final id = c['city_id'].toString();
                                          final name = '${c['type'] ?? ''} ${c['city_name'] ?? ''}';
                                          return DropdownMenuItem(value: id, child: Text(name));
                                        }).toList()
                                      : []),
                              onChanged: (v) => setState(() => _originCityId = v),
                              decoration: const InputDecoration(labelText: 'City'),
                            ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Text('Destination', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        value: _destinationProvinceId,
                        isExpanded: true,
                        items: _provinces.map((p) {
                          final id = p['province_id'].toString();
                          return DropdownMenuItem(value: id, child: Text(p['province'] ?? ''));
                        }).toList(),
                        onChanged: (v) async {
                          setState(() {
                            _destinationProvinceId = v;
                            _destinationCityId = null;
                          });
                          if (v != null) await _fetchCities(v);
                        },
                        decoration: const InputDecoration(labelText: 'Province'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: _loadingCities[_destinationProvinceId ?? ''] == true
                          ? const SizedBox(height: 56, child: Center(child: CircularProgressIndicator()))
              : DropdownButtonFormField<String>(
                value: _destinationCityId,
                isExpanded: true,
                              items: (_destinationProvinceId != null
                                      ? (_citiesByProvince[_destinationProvinceId!] ?? [])
                                          .map((c) {
                                          final id = c['city_id'].toString();
                                          final name = '${c['type'] ?? ''} ${c['city_name'] ?? ''}';
                                          return DropdownMenuItem(value: id, child: Text(name));
                                        }).toList()
                                      : []),
                              onChanged: (v) => setState(() => _destinationCityId = v),
                              decoration: const InputDecoration(labelText: 'City'),
                            ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                TextFormField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Weight (grams)', hintText: 'e.g. 1700'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _courier,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'jne', child: Text('JNE')),
                    DropdownMenuItem(value: 'pos', child: Text('POS')),
                    DropdownMenuItem(value: 'tiki', child: Text('TIKI')),
                  ],
                  onChanged: (v) => setState(() => _courier = v ?? 'jne'),
                  decoration: const InputDecoration(labelText: 'Courier'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _price,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'lowest', child: Text('Lowest')),
                    DropdownMenuItem(value: 'highest', child: Text('Highest')),
                  ],
                  onChanged: (v) => setState(() => _price = v ?? 'lowest'),
                  decoration: const InputDecoration(labelText: 'Price'),
                ),

                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.local_shipping),
                  label: const Padding(padding: EdgeInsets.symmetric(vertical: 12.0), child: Text('Estimate')),
                  onPressed: _loading ? null : _estimate,
                ),

                const SizedBox(height: 24),
                const Text('Results', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _loading && _provinces.isNotEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _results.isEmpty
                        ? const Text('No estimate yet')
                        : Column(
                            children: _results.map((r) {
                              return Card(
                                child: ListTile(
                                  title: Text('${r['courier']} — ${r['service']}'),
                                  subtitle: Text(r['description'] ?? ''),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(r['value'] != null ? 'Rp ${r['value']}' : '-'),
                                      if (r['etd'] != null) Text('${r['etd']}', style: const TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
              ]),
            ),
    );
  }
}

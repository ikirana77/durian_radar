import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class LocationPickerResult {
  const LocationPickerResult({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;
}

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({
    super.key,
    required this.initialLatitude,
    required this.initialLongitude,
  });

  final double initialLatitude;
  final double initialLongitude;

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late LatLng _selectedPoint;

  @override
  void initState() {
    super.initState();
    _selectedPoint = LatLng(
      widget.initialLatitude,
      widget.initialLongitude,
    );
  }

  void _confirmLocation() {
    Navigator.pop(
      context,
      LocationPickerResult(
        latitude: _selectedPoint.latitude,
        longitude: _selectedPoint.longitude,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        backgroundColor: AppColors.creamBackground,
        foregroundColor: AppColors.durianGreen,
        elevation: 0,
        title: const Text(
          'Pilih Lokasi Gerai',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(AppSpacing.m),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: AppColors.borderSoft),
              ),
              clipBehavior: Clip.antiAlias,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: _selectedPoint,
                  initialZoom: 15,
                  onTap: (tapPosition, point) {
                    setState(() {
                      _selectedPoint = point;
                    });
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.durian_radar',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _selectedPoint,
                        width: 80,
                        height: 80,
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: AppColors.durianGreen,
                          size: 56,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.l),
            decoration: const BoxDecoration(
              color: AppColors.softCardWhite,
              border: Border(
                top: BorderSide(color: AppColors.borderSoft),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tap pada peta untuk letak pin lokasi gerai.',
                  style: AppTextStyles.cardTitle,
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  'Latitude: ${_selectedPoint.latitude.toStringAsFixed(6)}\n'
                  'Longitude: ${_selectedPoint.longitude.toStringAsFixed(6)}',
                  style: AppTextStyles.helper,
                ),
                const SizedBox(height: AppSpacing.m),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _confirmLocation,
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Guna Lokasi Ini'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

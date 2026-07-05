import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/report_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../profile/screens/profile_screen.dart';
import 'location_picker_screen.dart';

class AddReportScreen extends StatefulWidget {
  const AddReportScreen({super.key});

  @override
  State<AddReportScreen> createState() => _AddReportScreenState();
}

class _AddReportScreenState extends State<AddReportScreen> {
  final TextEditingController _stallNameController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _varietyController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _sellerPhoneController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  String _selectedStockStatus = 'Banyak';
  bool _isSubmitting = false;
  bool _isGettingLocation = false;
  bool _isPickingPhoto = false;
  XFile? _selectedPhoto;
  String? _statusMessage;
  bool _isStatusError = false;

  static const String _temporarySpotId = '00000000-0000-0000-0000-000000000001';

  @override
  void dispose() {
    _stallNameController.dispose();
    _areaController.dispose();
    _varietyController.dispose();
    _priceController.dispose();
    _sellerPhoneController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (_isSubmitting) return;

    final stallName = _stallNameController.text.trim();
    final area = _areaController.text.trim();
    final variety = _varietyController.text.trim();
    final priceText = _priceController.text.trim();
    final sellerPhone = _sellerPhoneController.text.trim();
    final latitudeText = _latitudeController.text.trim();
    final longitudeText = _longitudeController.text.trim();

    if (stallName.isEmpty) {
      _showStatus('Sila masukkan nama gerai atau lokasi.', isError: true);
      return;
    }

    if (area.isEmpty) {
      _showStatus('Sila masukkan kawasan.', isError: true);
      return;
    }

    if (variety.isEmpty) {
      _showStatus('Sila masukkan jenis durian.', isError: true);
      return;
    }

    final latitude = _parseOptionalCoordinate(latitudeText);
    final longitude = _parseOptionalCoordinate(longitudeText);

    if ((latitudeText.isNotEmpty && latitude == null) ||
        (longitudeText.isNotEmpty && longitude == null)) {
      _showStatus(
        'Sila masukkan koordinat yang sah. Contoh latitude: 3.3400, longitude: 101.2500.',
        isError: true,
      );
      return;
    }

    final price = _parsePrice(priceText);

    if (price == null || price <= 0) {
      _showStatus(
        'Sila masukkan harga yang sah. Contoh: 38 atau RM38.',
        isError: true,
      );
      return;
    }

    if (!AuthService.isLoggedIn) {
      final shouldContinue = await _askUserToLogin();

      if (shouldContinue != true || !AuthService.isLoggedIn) {
        _showStatus(
          'Sila log masuk dahulu sebelum menghantar laporan.',
          isError: true,
        );
        return;
      }
    }

    setState(() {
      _isSubmitting = true;
      _statusMessage = 'Sedang menyediakan laporan...';
      _isStatusError = false;
    });

    try {
      String? photoUrl;

      if (_selectedPhoto != null) {
        if (mounted) {
          setState(() {
            _statusMessage = 'Sedang upload gambar gerai...';
            _isStatusError = false;
          });
        }

        final photoBytes = await _selectedPhoto!.readAsBytes();

        photoUrl = await ReportService.uploadReportPhoto(
          bytes: photoBytes,
          originalFileName: _selectedPhoto!.name,
        );
      }

      if (mounted) {
        setState(() {
          _statusMessage = 'Sedang menghantar laporan ke Supabase...';
          _isStatusError = false;
        });
      }

      await ReportService.createPendingReport(
        spotId: _temporarySpotId,
        stallName: stallName,
        area: area,
        variety: variety,
        pricePerKg: price,
        stockStatus: _selectedStockStatus,
        latitude: latitude,
        longitude: longitude,
        sellerPhone: sellerPhone,
        photoUrl: photoUrl,
      );

      if (!mounted) return;

      _showStatus('Laporan berjaya dihantar untuk semakan admin.');

      await Future<void>.delayed(const Duration(milliseconds: 900));

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      _showStatus(ReportService.getReadableError(error), isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _pickPhotoFromGallery() async {
    await _pickPhoto(ImageSource.gallery);
  }

  Future<void> _takePhotoWithCamera() async {
    await _pickPhoto(ImageSource.camera);
  }

  Future<void> _pickPhoto(ImageSource source) async {
    if (_isSubmitting || _isPickingPhoto) {
      return;
    }

    setState(() {
      _isPickingPhoto = true;
      _statusMessage = source == ImageSource.camera
          ? 'Sedang membuka kamera...'
          : 'Sedang membuka gallery...';
      _isStatusError = false;
    });

    try {
      final pickedPhoto = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1280,
        imageQuality: 78,
      );

      if (!mounted) {
        return;
      }

      if (pickedPhoto == null) {
        _showStatus('Tiada gambar dipilih.');
        return;
      }

      setState(() {
        _selectedPhoto = pickedPhoto;
        _statusMessage = 'Gambar gerai berjaya dipilih.';
        _isStatusError = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showStatus(
        'Gagal memilih gambar. Sila cuba semula atau pilih dari gallery.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPickingPhoto = false;
        });
      }
    }
  }

  void _clearSelectedPhoto() {
    if (_isSubmitting) {
      return;
    }

    setState(() {
      _selectedPhoto = null;
      _statusMessage = 'Gambar gerai dibuang daripada laporan.';
      _isStatusError = false;
    });
  }

  Future<bool?> _askUserToLogin() async {
    _showStatus(
      'Anda perlu log masuk sebelum menghantar laporan.',
      isError: true,
    );

    return Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  }

  Future<void> _pickLocationOnMap() async {
    if (_isSubmitting || _isGettingLocation) {
      return;
    }

    final startLatitude =
        _parseOptionalCoordinate(_latitudeController.text) ?? 3.3400;
    final startLongitude =
        _parseOptionalCoordinate(_longitudeController.text) ?? 101.2500;

    try {
      final result = await Navigator.push<LocationPickerResult>(
        context,
        MaterialPageRoute(
          builder: (context) => LocationPickerScreen(
            initialLatitude: startLatitude,
            initialLongitude: startLongitude,
          ),
        ),
      );

      if (!mounted || result == null) {
        return;
      }

      _latitudeController.text = result.latitude.toStringAsFixed(6);
      _longitudeController.text = result.longitude.toStringAsFixed(6);

      _showStatus('Lokasi peta berjaya dipilih.');
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showStatus(
        'Gagal membuka pilihan lokasi peta. Sila cuba lagi atau isi koordinat secara manual.',
        isError: true,
      );
    }
  }

  Future<void> _useCurrentLocation() async {
    if (_isGettingLocation || _isSubmitting) {
      return;
    }

    setState(() {
      _isGettingLocation = true;
      _statusMessage = 'Sedang mendapatkan lokasi semasa...';
      _isStatusError = false;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!mounted) {
        return;
      }

      if (!serviceEnabled) {
        _showStatus(
          'Location service belum diaktifkan. Sila aktifkan GPS/location pada device.',
          isError: true,
        );
        return;
      }

      var permission = await Geolocator.checkPermission();

      if (!mounted) {
        return;
      }

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (!mounted) {
          return;
        }
      }

      if (permission == LocationPermission.denied) {
        _showStatus(
          'Permission lokasi tidak dibenarkan. Sila allow location untuk guna fungsi ini.',
          isError: true,
        );
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        _showStatus(
          'Permission lokasi disekat. Sila buka Settings dan benarkan location permission.',
          isError: true,
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(const Duration(seconds: 15));

      if (!mounted) {
        return;
      }

      _latitudeController.text = position.latitude.toStringAsFixed(6);
      _longitudeController.text = position.longitude.toStringAsFixed(6);

      _showStatus('Lokasi semasa berjaya diambil.');
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showStatus(_getLocationErrorMessage(error), isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isGettingLocation = false;
        });
      }
    }
  }

  String _getLocationErrorMessage(Object error) {
    final rawMessage = error.toString().toLowerCase();

    if (error is TimeoutException || rawMessage.contains('timeout')) {
      return 'GPS mengambil masa terlalu lama. Sila cuba lagi, pilih lokasi atas peta, atau isi koordinat manual.';
    }

    if (rawMessage.contains('permission')) {
      return 'Aplikasi tidak mendapat kebenaran lokasi. Sila semak permission location dalam Settings.';
    }

    if (rawMessage.contains('location service') ||
        rawMessage.contains('disabled')) {
      return 'Location service belum aktif. Sila aktifkan GPS/location pada device.';
    }

    return 'Gagal mendapatkan lokasi semasa. Sila cuba lagi, pilih lokasi atas peta, atau isi koordinat secara manual.';
  }

  double? _parseOptionalCoordinate(String value) {
    if (value.trim().isEmpty) {
      return null;
    }

    return double.tryParse(value.trim().replaceAll(',', '.'));
  }

  double? _parsePrice(String value) {
    final cleaned = value
        .replaceAll('RM', '')
        .replaceAll('rm', '')
        .replaceAll(',', '.')
        .replaceAll('/kg', '')
        .replaceAll('kg', '')
        .trim();

    return double.tryParse(cleaned);
  }

  void _showStatus(String message, {bool isError = false}) {
    if (!mounted) {
      return;
    }

    setState(() {
      _statusMessage = message;
      _isStatusError = isError;
    });

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _ReportHeader(),
              const SizedBox(height: AppSpacing.xl),
              const _LocationPreviewCard(),
              const SizedBox(height: AppSpacing.l),
              const _FormSectionTitle(number: '1', title: 'Maklumat Lokasi'),
              const SizedBox(height: AppSpacing.m),
              _AppTextField(
                controller: _stallNameController,
                label: 'Nama gerai / lokasi',
                hint: 'Contoh: Gerai Durian Bukit Rotan',
                icon: Icons.storefront,
                enabled: !_isSubmitting,
              ),
              const SizedBox(height: AppSpacing.m),
              _AppTextField(
                controller: _areaController,
                label: 'Kawasan',
                hint: 'Contoh: Kuala Selangor',
                icon: Icons.location_on_outlined,
                enabled: !_isSubmitting,
              ),
              const SizedBox(height: AppSpacing.m),
              _AppTextField(
                controller: _sellerPhoneController,
                label: 'Telefon / WhatsApp penjual',
                hint: 'Contoh: 60123456789',
                icon: Icons.phone_android,
                keyboardType: TextInputType.phone,
                enabled: !_isSubmitting,
              ),
              const SizedBox(height: AppSpacing.m),
              _LocationPickerCard(
                latitudeController: _latitudeController,
                longitudeController: _longitudeController,
                isSubmitting: _isSubmitting,
                isGettingLocation: _isGettingLocation,
                onUseCurrentLocation: _useCurrentLocation,
                onPickLocationOnMap: _pickLocationOnMap,
              ),
              const SizedBox(height: AppSpacing.xl),
              const _FormSectionTitle(number: '2', title: 'Jenis & Harga'),
              const SizedBox(height: AppSpacing.m),
              _AppTextField(
                controller: _varietyController,
                label: 'Jenis durian',
                hint: 'Contoh: Musang King, D24, XO',
                icon: Icons.eco,
                enabled: !_isSubmitting,
              ),
              const SizedBox(height: AppSpacing.m),
              _AppTextField(
                controller: _priceController,
                label: 'Harga per kg',
                hint: 'Contoh: RM38',
                icon: Icons.sell,
                keyboardType: TextInputType.number,
                enabled: !_isSubmitting,
              ),
              const SizedBox(height: AppSpacing.xl),
              const _FormSectionTitle(number: '3', title: 'Status Stok'),
              const SizedBox(height: AppSpacing.m),
              _StockStatusRow(
                selectedStatus: _selectedStockStatus,
                enabled: !_isSubmitting,
                onSelected: (status) {
                  setState(() {
                    _selectedStockStatus = status;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              _PhotoUploadCard(
                selectedPhoto: _selectedPhoto,
                isSubmitting: _isSubmitting,
                isPickingPhoto: _isPickingPhoto,
                onPickFromGallery: _pickPhotoFromGallery,
                onTakePhoto: _takePhotoWithCamera,
                onClearPhoto: _clearSelectedPhoto,
              ),
              if (_statusMessage != null) ...[
                const SizedBox(height: AppSpacing.l),
                _StatusBox(message: _statusMessage!, isError: _isStatusError),
              ],
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitReport,
                  icon: _isSubmitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  label: Text(
                    _isSubmitting ? 'Sedang Hantar...' : 'Hantar Laporan',
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              Center(
                child: TextButton(
                  onPressed: _isSubmitting
                      ? null
                      : () {
                          Navigator.pop(context);
                        },
                  child: const Text('Batal'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportHeader extends StatelessWidget {
  const _ReportHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
          color: AppColors.durianGreen,
        ),
        const SizedBox(width: AppSpacing.s),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Laporkan Durian', style: AppTextStyles.pageTitle),
              SizedBox(height: 4),
              Text(
                'Tambah laporan durian fresh untuk komuniti',
                style: AppTextStyles.helper,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LocationPreviewCard extends StatelessWidget {
  const _LocationPreviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.softCardWhite,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.paleGreen,
            child: Icon(Icons.location_on, color: AppColors.durianGreen),
          ),
          SizedBox(width: AppSpacing.m),
          Expanded(
            child: Text(
              'Pilih lokasi gerai menggunakan GPS semasa atau peta. Koordinat akan disimpan untuk navigasi Google Maps.',
              style: AppTextStyles.helper,
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationPickerCard extends StatelessWidget {
  const _LocationPickerCard({
    required this.latitudeController,
    required this.longitudeController,
    required this.isSubmitting,
    required this.isGettingLocation,
    required this.onUseCurrentLocation,
    required this.onPickLocationOnMap,
  });

  final TextEditingController latitudeController;
  final TextEditingController longitudeController;
  final bool isSubmitting;
  final bool isGettingLocation;
  final VoidCallback onUseCurrentLocation;
  final VoidCallback onPickLocationOnMap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.softCardWhite,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.paleGreen,
                  borderRadius: BorderRadius.circular(AppRadius.button),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: AppColors.durianGreen,
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Lokasi gerai', style: AppTextStyles.cardTitle),
                    SizedBox(height: 4),
                    Text(
                      'Pilih cara paling mudah untuk simpan lokasi.',
                      style: AppTextStyles.helper,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isSubmitting || isGettingLocation
                  ? null
                  : onUseCurrentLocation,
              icon: isGettingLocation
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location_rounded),
              label: Text(
                isGettingLocation
                    ? 'Sedang Ambil Lokasi...'
                    : 'Gunakan Lokasi Semasa',
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isSubmitting || isGettingLocation
                  ? null
                  : onPickLocationOnMap,
              icon: const Icon(Icons.map_rounded),
              label: const Text('Pilih Lokasi Atas Peta'),
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.m),
            decoration: BoxDecoration(
              color: AppColors.creamBackground,
              borderRadius: BorderRadius.circular(AppRadius.button),
              border: Border.all(color: AppColors.borderSoft),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Koordinat teknikal',
                  style: TextStyle(
                    color: AppColors.durianGreen,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'Auto-fill selepas guna lokasi semasa atau pilih atas peta.',
                  style: AppTextStyles.helper,
                ),
                const SizedBox(height: AppSpacing.m),
                Row(
                  children: [
                    Expanded(
                      child: _SmallCoordinateField(
                        controller: latitudeController,
                        label: 'Latitude',
                        hint: '3.3400',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s),
                    Expanded(
                      child: _SmallCoordinateField(
                        controller: longitudeController,
                        label: 'Longitude',
                        hint: '101.2500',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallCoordinateField extends StatelessWidget {
  const _SmallCoordinateField({
    required this.controller,
    required this.label,
    required this.hint,
  });

  final TextEditingController controller;
  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      decoration: InputDecoration(
        isDense: true,
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: AppColors.softCardWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: const BorderSide(color: AppColors.borderSoft),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: const BorderSide(color: AppColors.borderSoft),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: const BorderSide(color: AppColors.durianGreen, width: 2),
        ),
      ),
    );
  }
}

class _FormSectionTitle extends StatelessWidget {
  const _FormSectionTitle({required this.number, required this.title});

  final String number;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: AppColors.durianGreen,
          child: Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.s),
        Text(title, style: AppTextStyles.sectionTitle),
      ],
    );
  }
}

class _AppTextField extends StatelessWidget {
  const _AppTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.durianGreen),
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: AppColors.softCardWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: const BorderSide(color: AppColors.borderSoft),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: const BorderSide(color: AppColors.borderSoft),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: const BorderSide(color: AppColors.borderSoft),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: const BorderSide(color: AppColors.durianGreen, width: 2),
        ),
      ),
    );
  }
}

class _StockStatusRow extends StatelessWidget {
  const _StockStatusRow({
    required this.selectedStatus,
    required this.enabled,
    required this.onSelected,
  });

  final String selectedStatus;
  final bool enabled;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.s,
      runSpacing: AppSpacing.s,
      children: [
        _StatusChoice(
          label: 'Banyak',
          color: AppColors.freshGreen,
          icon: Icons.check_circle,
          selected: selectedStatus == 'Banyak',
          enabled: enabled,
          onTap: () {
            onSelected('Banyak');
          },
        ),
        _StatusChoice(
          label: 'Sikit',
          color: AppColors.warningYellow,
          icon: Icons.warning_amber,
          selected: selectedStatus == 'Sikit',
          enabled: enabled,
          onTap: () {
            onSelected('Sikit');
          },
        ),
        _StatusChoice(
          label: 'Habis',
          color: AppColors.soldOutRed,
          icon: Icons.cancel,
          selected: selectedStatus == 'Habis',
          enabled: enabled,
          onTap: () {
            onSelected('Habis');
          },
        ),
      ],
    );
  }
}

class _StatusChoice extends StatelessWidget {
  const _StatusChoice({
    required this.label,
    required this.color,
    required this.icon,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final Color color;
  final IconData icon;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.chip),
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.m,
            vertical: AppSpacing.s,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: selected ? 0.22 : 0.12),
            borderRadius: BorderRadius.circular(AppRadius.chip),
            border: Border.all(
              color: selected ? color : color.withValues(alpha: 0.35),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: AppTextStyles.helper.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoUploadCard extends StatelessWidget {
  const _PhotoUploadCard({
    required this.selectedPhoto,
    required this.isSubmitting,
    required this.isPickingPhoto,
    required this.onPickFromGallery,
    required this.onTakePhoto,
    required this.onClearPhoto,
  });

  final XFile? selectedPhoto;
  final bool isSubmitting;
  final bool isPickingPhoto;
  final VoidCallback onPickFromGallery;
  final VoidCallback onTakePhoto;
  final VoidCallback onClearPhoto;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = selectedPhoto != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.softCardWhite,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FormSectionTitle(number: '4', title: 'Gambar Gerai'),
          const SizedBox(height: AppSpacing.m),
          if (hasPhoto)
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.button),
              child: Image.file(
                File(selectedPhoto!.path),
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                color: AppColors.creamBackground,
                borderRadius: BorderRadius.circular(AppRadius.button),
                border: Border.all(color: AppColors.borderSoft),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo_outlined,
                    color: AppColors.durianGreen,
                    size: 38,
                  ),
                  SizedBox(height: AppSpacing.s),
                  Text(
                    'Tambah gambar gerai / papan harga',
                    style: AppTextStyles.cardTitle,
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.m),
                    child: Text(
                      'Gambar akan diupload ke Supabase Storage bersama laporan.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.helper,
                    ),
                  ),
                ],
              ),
            ),
          if (hasPhoto) ...[
            const SizedBox(height: AppSpacing.s),
            Text(
              selectedPhoto!.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.helper,
            ),
          ],
          const SizedBox(height: AppSpacing.m),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isSubmitting || isPickingPhoto
                      ? null
                      : onPickFromGallery,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Gallery'),
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isSubmitting || isPickingPhoto
                      ? null
                      : onTakePhoto,
                  icon: isPickingPhoto
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.photo_camera_outlined),
                  label: Text(isPickingPhoto ? 'Buka...' : 'Kamera'),
                ),
              ),
            ],
          ),
          if (hasPhoto) ...[
            const SizedBox(height: AppSpacing.s),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: isSubmitting ? null : onClearPhoto,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Buang gambar'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusBox extends StatelessWidget {
  const _StatusBox({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError ? AppColors.soldOutRed : AppColors.durianGreen;
    final backgroundColor = isError
        ? AppColors.soldOutRed.withValues(alpha: 0.08)
        : AppColors.paleGreen;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.button),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: color,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.helper.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

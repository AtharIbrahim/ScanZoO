import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/theme/app_theme.dart';
import '../bloc/sticker_bloc.dart';
import '../bloc/sticker_event.dart';
import '../bloc/sticker_state.dart';
import '../repositories/sticker_repository.dart';
import '../models/vehicle_info.dart';

class ActivateStickerScreen extends StatelessWidget {
  const ActivateStickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StickerBloc(
        stickerRepository: StickerRepository(),
      ),
      child: const _ActivateStickerView(),
    );
  }
}

class _ActivateStickerView extends StatelessWidget {
  const _ActivateStickerView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Activate Sticker',
          style: AppTypography.h3.copyWith(color: theme.colorScheme.onSurface),
        ),
      ),
      body: BlocListener<StickerBloc, StickerState>(
        listener: (context, state) {
          if (state.status == StickerSubmissionStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sticker activated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true); // Return true to refresh home screen
          } else if (state.status == StickerSubmissionStatus.failure ||
              state.status == StickerSubmissionStatus.invalid) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'An error occurred'),
                backgroundColor: AppColors.emergencyRed,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _HeaderSection(),
              const SizedBox(height: AppSpacing.xl),
              const _QRScannerSection(),
              const SizedBox(height: AppSpacing.xl),
              const _ValidationStatusSection(),
              const SizedBox(height: AppSpacing.xl),
              const _VehicleInfoSection(),
              const SizedBox(height: AppSpacing.xl),
              const _EmergencyContactSelectionSection(),
              const SizedBox(height: AppSpacing.xl),
              const _ActivateButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.qr_code_scanner,
          size: 64,
          color: AppColors.sticker_color,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Scan Your Sticker QR Code',
          style: AppTypography.h2.copyWith(color: theme.colorScheme.onSurface),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Point your camera at the QR code on your car sticker to activate it.',
          style: AppTypography.bodyMedium.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

class _QRScannerSection extends StatefulWidget {
  const _QRScannerSection();

  @override
  State<_QRScannerSection> createState() => _QRScannerSectionState();
}

class _QRScannerSectionState extends State<_QRScannerSection> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanning = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onQRCodeDetected(BarcodeCapture capture) {
    if (_isScanning) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    
    final String? code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    setState(() {
      _isScanning = true;
    });

    // Extract sticker ID from URL or use as-is
    final stickerId = _extractStickerIdFromQR(code);

    // Update sticker ID and check validity
    context.read<StickerBloc>().add(StickerIdChanged(stickerId));
    context.read<StickerBloc>().add(CheckStickerValidity(stickerId));

    // Vibrate or provide feedback
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    });
  }

  String _extractStickerIdFromQR(String qrData) {
    // Check if it's a URL
    if (qrData.startsWith('http://') || qrData.startsWith('https://')) {
      final uri = Uri.tryParse(qrData);
      if (uri != null) {
        // Extract the last segment from the path
        // Example: https://yourapp.com/s/STK-92FJ3A8Q -> STK-92FJ3A8Q
        final segments = uri.pathSegments;
        if (segments.isNotEmpty) {
          return segments.last;
        }
      }
    }
    
    // If not a URL or extraction failed, return the original data
    return qrData;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSecondary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.sticker_color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Stack(
          children: [
            MobileScanner(
              controller: cameraController,
              onDetect: _onQRCodeDetected,
            ),
            // Scanning overlay
            Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.accentAmber,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
            // Instructions overlay
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  'Align QR code within the frame',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ValidationStatusSection extends StatelessWidget {
  const _ValidationStatusSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StickerBloc, StickerState>(
      builder: (context, state) {
        if (state.status == StickerSubmissionStatus.checking) {
          return _buildCheckingCard();
        } else if (state.status == StickerSubmissionStatus.valid) {
          return _buildValidCard(state);
        } else if (state.status == StickerSubmissionStatus.invalid) {
          return _buildInvalidCard(state);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCheckingCard() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        
        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSecondary,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentAmber),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Checking sticker validity...',
                style: AppTypography.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildValidCard(StickerState state) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        
        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            border: Border.all(color: Colors.green),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 28,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Sticker Available',
                    style: AppTypography.h4.copyWith(
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'This sticker is valid and ready to be activated.',
                style: AppTypography.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              if (state.validatedSticker != null) ...[
                const SizedBox(height: AppSpacing.md),
                _buildInfoRow('Sticker ID', state.validatedSticker!.stickerId),
                _buildInfoRow('QR Code', state.validatedSticker!.qrCode),
                _buildInfoRow('Status', state.validatedSticker!.status.value),
              ],
            ],
          ),
        );
      }
    );
  }

  Widget _buildInvalidCard(StickerState state) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        
        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.emergencyRed.withOpacity(0.1),
            border: Border.all(color: AppColors.emergencyRed),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.error,
                    color: AppColors.emergencyRed,
                    size: 28,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Invalid Sticker',
                    style: AppTypography.h4.copyWith(
                      color: AppColors.emergencyRed,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                state.errorMessage ?? 'This sticker is not available for activation.',
                style: AppTypography.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  '$label:',
                  style: AppTypography.bodySmall.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: AppTypography.bodySmall.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

class _EmergencyContactSelectionSection extends StatefulWidget {
  const _EmergencyContactSelectionSection();

  @override
  State<_EmergencyContactSelectionSection> createState() =>
      _EmergencyContactSelectionSectionState();
}

class _EmergencyContactSelectionSectionState
    extends State<_EmergencyContactSelectionSection> {
  final Set<String> _selectedContactIds = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return BlocBuilder<StickerBloc, StickerState>(
      builder: (context, state) {
        if (state.status != StickerSubmissionStatus.valid) {
          return const SizedBox.shrink();
        }

        if (state.availableContacts.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              border: Border.all(color: Colors.orange),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                      size: 24,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'No Emergency Contacts',
                      style: AppTypography.h4.copyWith(
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Please add emergency contacts first before activating this sticker. You can add contacts from the home screen.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Emergency Contacts',
                style: AppTypography.h4.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Choose which contacts will be shown when this sticker is scanned',
                style: AppTypography.bodySmall.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ...state.availableContacts.map((contact) {
                final isSelected = _selectedContactIds.contains(contact.id);
                return _ContactCheckbox(
                  contact: contact,
                  isSelected: isSelected,
                  onChanged: (selected) {
                    setState(() {
                      if (selected == true) {
                        _selectedContactIds.add(contact.id);
                      } else {
                        _selectedContactIds.remove(contact.id);
                      }
                    });
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Set<String> get selectedContactIds => _selectedContactIds;
}

class _VehicleInfoSection extends StatefulWidget {
  const _VehicleInfoSection();

  @override
  State<_VehicleInfoSection> createState() => _VehicleInfoSectionState();
}

class _VehicleInfoSectionState extends State<_VehicleInfoSection> {
  final TextEditingController _makeController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _plateController = TextEditingController();

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  VehicleInfo? get vehicleInfo {
    if (_makeController.text.isEmpty &&
        _modelController.text.isEmpty &&
        _yearController.text.isEmpty &&
        _colorController.text.isEmpty &&
        _plateController.text.isEmpty) {
      return null;
    }

    return VehicleInfo(
      make: _makeController.text,
      model: _modelController.text,
      year: int.tryParse(_yearController.text) ?? DateTime.now().year,
      color: _colorController.text,
      plateNumber: _plateController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return BlocBuilder<StickerBloc, StickerState>(
      builder: (context, state) {
        if (state.status != StickerSubmissionStatus.valid) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSecondary,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vehicle Information (Optional)',
                style: AppTypography.h4.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Add details to help identify your vehicle',
                style: AppTypography.bodySmall.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _makeController,
                      decoration: const InputDecoration(
                        labelText: 'Make',
                        hintText: 'e.g., Toyota',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextField(
                      controller: _modelController,
                      decoration: const InputDecoration(
                        labelText: 'Model',
                        hintText: 'e.g., Camry',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _yearController,
                      decoration: const InputDecoration(
                        labelText: 'Year',
                        hintText: 'e.g., 2024',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextField(
                      controller: _colorController,
                      decoration: const InputDecoration(
                        labelText: 'Color',
                        hintText: 'e.g., Silver',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _plateController,
                decoration: const InputDecoration(
                  labelText: 'Plate Number',
                  hintText: 'e.g., ABC-1234',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ContactCheckbox extends StatelessWidget {
  final dynamic contact;
  final bool isSelected;
  final Function(bool?) onChanged;

  const _ContactCheckbox({
    required this.contact,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.accentAmber.withOpacity(0.1)
            : (isDark ? AppColors.darkSecondary : AppColors.lightSurface),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: isSelected ? AppColors.accentAmber : theme.colorScheme.outline,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: isSelected,
            onChanged: onChanged,
            activeColor: AppColors.accentAmber,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: AppTypography.bodyMedium.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs / 2),
                Text(
                  '${contact.phone} • ${contact.relationship}',
                  style: AppTypography.bodySmall.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          if (contact.isPrimary)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs / 2,
              ),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                'PRIMARY',
                style: AppTypography.bodySmall.copyWith(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ActivateButton extends StatelessWidget {
  const _ActivateButton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return BlocBuilder<StickerBloc, StickerState>(
      builder: (context, state) {
        final isEnabled = state.status == StickerSubmissionStatus.valid;
        final isLoading = state.status == StickerSubmissionStatus.activating;

        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isEnabled && !isLoading
                ? () {
                    // Get selected contact IDs from the parent widget
                    final contactSelectionState = context
                        .findAncestorStateOfType<_EmergencyContactSelectionSectionState>();
                    final selectedIds =
                        contactSelectionState?.selectedContactIds.toList() ?? [];

                    // Get vehicle info from the parent widget
                    final vehicleInfoState = context
                        .findAncestorStateOfType<_VehicleInfoSectionState>();
                    final vehicleInfo = vehicleInfoState?.vehicleInfo;

                    // Activate the sticker with contacts and vehicle info
                    context.read<StickerBloc>().add(
                          ActivateStickerRequested(
                            stickerId: state.stickerId,
                            emergencyContactIds: selectedIds,
                            vehicleInfo: vehicleInfo,
                          ),
                        );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentAmber,
              disabledBackgroundColor: theme.colorScheme.onSurface.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Activate Sticker',
                    style: AppTypography.button.copyWith(
                      fontSize: 16,
                    ),
                  ),
          ),
        );
      },
    );
  }
}

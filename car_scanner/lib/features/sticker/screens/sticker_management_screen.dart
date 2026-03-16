import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../sticker/models/sticker.dart';
import '../../sticker/models/emergency_contact.dart';
import '../../sticker/models/vehicle_info.dart';
import '../../sticker/repositories/sticker_repository.dart';
import '../../sticker/bloc/sticker_bloc.dart';
import '../../sticker/bloc/sticker_event.dart';
import '../../sticker/bloc/sticker_state.dart';

class StickerManagementScreen extends StatelessWidget {
  final Sticker sticker;

  const StickerManagementScreen({
    super.key,
    required this.sticker,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StickerBloc(
        stickerRepository: StickerRepository(),
      ),
      child: _StickerManagementView(sticker: sticker),
    );
  }
}

class _StickerManagementView extends StatefulWidget {
  final Sticker sticker;

  const _StickerManagementView({
    required this.sticker,
  });

  @override
  State<_StickerManagementView> createState() => _StickerManagementViewState();
}

class _StickerManagementViewState extends State<_StickerManagementView> {
  late Sticker _currentSticker;
  final StickerRepository _repository = StickerRepository();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentSticker = widget.sticker;
    // Load contacts for this sticker
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StickerBloc>().add(LoadContactsForSticker(_currentSticker.stickerId));
    });
  }

  Future<void> _reloadSticker() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final updatedSticker = await _repository.getStickerById(_currentSticker.stickerId);
      if (updatedSticker != null && mounted) {
        setState(() {
          _currentSticker = updatedSticker;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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
          onPressed: () => Navigator.pop(context, true),
        ),
        title: Text(
          'Manage Sticker',
          style: AppTypography.h3.copyWith(color: theme.colorScheme.onSurface),
        ),
      ),
      body: BlocListener<StickerBloc, StickerState>(
        listener: (context, state) {
          if (state.status == StickerSubmissionStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sticker updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            // Reload sticker to show updated status
            _reloadSticker();
          } else if (state.status == StickerSubmissionStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'An error occurred'),
                backgroundColor: AppColors.emergencyRed,
              ),
            );
          }
        },
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StickerInfoCard(sticker: _currentSticker),
                    const SizedBox(height: AppSpacing.xl),
                    _VehicleInfoCard(sticker: _currentSticker),
                    const SizedBox(height: AppSpacing.xl),
                    _EmergencyContactsSection(sticker: _currentSticker),
                    const SizedBox(height: AppSpacing.xl),
                    _buildActionSection(context),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildActionSection(BuildContext context) {
    final theme = Theme.of(context);
    final isBlocked = _currentSticker.status == StickerStatus.suspended;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sticker Actions',
          style: AppTypography.h3.copyWith(color: theme.colorScheme.onSurface),
        ),
        const SizedBox(height: AppSpacing.md),
        
        if (!isBlocked) ...[
          _ActionButton(
            icon: Icons.block,
            title: 'Temporarily Block Sticker',
            subtitle: 'Prevent scanning until you unblock it',
            color: Colors.orange,
            onTap: () => _showBlockConfirmation(context),
          ),
          const SizedBox(height: AppSpacing.sm),
        ] else ...[
          _ActionButton(
            icon: Icons.check_circle,
            title: 'Unblock Sticker',
            subtitle: 'Allow scanning again',
            color: Colors.green,
            onTap: () => _unblockSticker(context),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        
        _ActionButton(
          icon: Icons.delete_forever,
          title: 'Deactivate Sticker',
          subtitle: 'Permanently remove from your account',
          color: AppColors.emergencyRed,
          onTap: () => _showDeactivateConfirmation(context),
        ),
      ],
    );
  }

  void _showBlockConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Block Sticker?'),
        content: const Text(
          'This will temporarily prevent anyone from scanning this sticker. You can unblock it anytime.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<StickerBloc>().add(BlockStickerRequested(_currentSticker.stickerId));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }

  void _unblockSticker(BuildContext context) {
    context.read<StickerBloc>().add(UnblockStickerRequested(_currentSticker.stickerId));
  }

  void _showDeactivateConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Deactivate Sticker?'),
        content: const Text(
          'This will permanently remove this sticker from your account and disconnect it from your emergency contacts. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<StickerBloc>().add(DeactivateStickerRequested(_currentSticker.stickerId));
              // Close the management screen after deactivation
              Future.delayed(const Duration(milliseconds: 500), () {
                if (context.mounted) {
                  Navigator.pop(context, true);
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.emergencyRed,
            ),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }
}

class _StickerInfoCard extends StatelessWidget {
  final Sticker sticker;

  const _StickerInfoCard({required this.sticker});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSecondary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getStatusColor(),
                      _getStatusColor().withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: [
                    BoxShadow(
                      color: _getStatusColor().withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.qr_code_2,
                  size: 32,
                  color: AppColors.sticker_color,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sticker ID',
                      style: AppTypography.bodySmall.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      sticker.stickerId,
                      style: AppTypography.h4.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Divider(color: theme.dividerColor),
          const SizedBox(height: AppSpacing.md),
          _InfoRow(
            label: 'Status',
            value: _getStatusText(),
            valueColor: _getStatusColor(),
          ),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(
            label: 'Activated',
            value: sticker.activatedAt != null
                ? '${sticker.activatedAt!.day}/${sticker.activatedAt!.month}/${sticker.activatedAt!.year}'
                : 'N/A',
          ),
          if (sticker.vehicleInfo != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _InfoRow(
              label: 'Vehicle',
              value: '${sticker.vehicleInfo!.make} ${sticker.vehicleInfo!.model}',
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (sticker.status) {
      case StickerStatus.active:
        return Colors.green;
      case StickerStatus.suspended:
        return Colors.orange;
      case StickerStatus.expired:
        return Colors.red;
      case StickerStatus.inactive:
        return Colors.grey;
    }
  }

  String _getStatusText() {
    switch (sticker.status) {
      case StickerStatus.active:
        return 'Active';
      case StickerStatus.suspended:
        return 'Blocked';
      case StickerStatus.expired:
        return 'Expired';
      case StickerStatus.inactive:
        return 'Inactive';
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            color: valueColor ?? theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Material(
      color: isDark ? AppColors.darkSurface : AppColors.lightSecondary,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.bodyLarge.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textHint,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VehicleInfoCard extends StatelessWidget {
  final Sticker sticker;

  const _VehicleInfoCard({required this.sticker});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSecondary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Vehicle Information',
                style: AppTypography.h4.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () => _showVehicleInfoDialog(context, sticker),
                icon: Icon(
                  sticker.vehicleInfo == null ? Icons.add : Icons.edit,
                  size: 18,
                ),
                label: Text(sticker.vehicleInfo == null ? 'Add' : 'Edit'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.sticker_color,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (sticker.vehicleInfo == null)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.secondaryBackground,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'No vehicle information added yet',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: [
                _VehicleInfoRow(
                  icon: Icons.directions_car,
                  label: 'Make & Model',
                  value: '${sticker.vehicleInfo!.make} ${sticker.vehicleInfo!.model}',
                ),
                const SizedBox(height: AppSpacing.sm),
                _VehicleInfoRow(
                  icon: Icons.calendar_today,
                  label: 'Year',
                  value: '${sticker.vehicleInfo!.year}',
                ),
                const SizedBox(height: AppSpacing.sm),
                _VehicleInfoRow(
                  icon: Icons.palette,
                  label: 'Color',
                  value: sticker.vehicleInfo!.color,
                ),
                const SizedBox(height: AppSpacing.sm),
                _VehicleInfoRow(
                  icon: Icons.confirmation_number,
                  label: 'Plate Number',
                  value: sticker.vehicleInfo!.plateNumber,
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _showVehicleInfoDialog(BuildContext context, Sticker sticker) {
    final makeController = TextEditingController(text: sticker.vehicleInfo?.make ?? '');
    final modelController = TextEditingController(text: sticker.vehicleInfo?.model ?? '');
    final yearController = TextEditingController(
        text: sticker.vehicleInfo?.year.toString() ?? '');
    final colorController = TextEditingController(text: sticker.vehicleInfo?.color ?? '');
    final plateController = TextEditingController(text: sticker.vehicleInfo?.plateNumber ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(sticker.vehicleInfo == null ? 'Add Vehicle Info' : 'Edit Vehicle Info'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: makeController,
                decoration: const InputDecoration(
                  labelText: 'Make',
                  hintText: 'e.g., Toyota',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: modelController,
                decoration: const InputDecoration(
                  labelText: 'Model',
                  hintText: 'e.g., Camry',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: yearController,
                decoration: const InputDecoration(
                  labelText: 'Year',
                  hintText: 'e.g., 2024',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: colorController,
                decoration: const InputDecoration(
                  labelText: 'Color',
                  hintText: 'e.g., Silver',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: plateController,
                decoration: const InputDecoration(
                  labelText: 'Plate Number',
                  hintText: 'e.g., ABC-1234',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: AppColors.sticker_color)),
          ),
          ElevatedButton(
            onPressed: () {
              final vehicleInfo = VehicleInfo(
                make: makeController.text,
                model: modelController.text,
                year: int.tryParse(yearController.text) ?? DateTime.now().year,
                color: colorController.text,
                plateNumber: plateController.text,
              );

              context.read<StickerBloc>().add(
                    AddVehicleInfoRequested(
                      stickerId: sticker.stickerId,
                      vehicleInfo: vehicleInfo,
                    ),
                  );
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sticker_color,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _VehicleInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _VehicleInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSecondary : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.sticker_color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              icon,
              color: AppColors.sticker_color,
              size: 18,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.bodySmall.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTypography.bodyMedium.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
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

class _EmergencyContactsSection extends StatelessWidget {
  final Sticker sticker;

  const _EmergencyContactsSection({required this.sticker});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return BlocBuilder<StickerBloc, StickerState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSecondary,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Emergency Contacts',
                    style: AppTypography.h4.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _showContactSelectionDialog(context, state),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.sticker_color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (state.linkedContacts.isEmpty)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'No emergency contacts linked to this sticker',
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...state.linkedContacts.map((contact) => _ContactCard(contact: contact)),
            ],
          ),
        );
      },
    );
  }

  void _showContactSelectionDialog(BuildContext context, StickerState state) {
    final selectedIds = Set<String>.from(sticker.emergencyContactIds);
    // Capture the context that has BLoC access
    final blocContext = context;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Select Emergency Contacts'),
          content: SizedBox(
            width: double.maxFinite,
            child: state.availableContacts.isEmpty
                ? const Text('No contacts available. Add contacts from the home screen.')
                : ListView(
                    shrinkWrap: true,
                    children: state.availableContacts.map((contact) {
                      final isSelected = selectedIds.contains(contact.id);
                      return CheckboxListTile(
                        value: isSelected,
                        onChanged: (selected) {
                          setState(() {
                            if (selected == true) {
                              selectedIds.add(contact.id);
                            } else {
                              selectedIds.remove(contact.id);
                            }
                          });
                        },
                        title: Text(contact.name),
                        subtitle: Text('${contact.phone} • ${contact.relationship}'),
                        secondary: contact.isPrimary
                            ? Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      );
                    }).toList(),
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                blocContext.read<StickerBloc>().add(
                      LinkContactsToStickerRequested(
                        stickerId: sticker.stickerId,
                        contactIds: selectedIds.toList(),
                      ),
                    );
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentBlue,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final EmergencyContact contact;

  const _ContactCard({required this.contact});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: contact.isPrimary ? Colors.green : theme.dividerColor,
          width: contact.isPrimary ? 2 : 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.sticker_color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              Icons.person,
              color: AppColors.sticker_color,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      contact.name,
                      style: AppTypography.bodyMedium.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (contact.isPrimary) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'PRIMARY',
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.xs / 2),
                Text(
                  contact.phone,
                  style: AppTypography.bodySmall.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(1),
                  ),
                ),
                Text(
                  contact.relationship,
                  style: AppTypography.bodySmall.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(1),
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

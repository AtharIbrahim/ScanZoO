import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../bloc/scan_history_bloc.dart';
import '../bloc/scan_history_event.dart';
import '../bloc/scan_history_state.dart';
import '../repositories/sticker_repository.dart';
import '../models/scan_history.dart';
import '../models/sticker.dart';

class ScanHistoryScreen extends StatelessWidget {
  const ScanHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ScanHistoryBloc(
        stickerRepository: StickerRepository(),
      )..add(const LoadScanHistory()),
      child: const _ScanHistoryView(),
    );
  }
}

class _ScanHistoryView extends StatelessWidget {
  const _ScanHistoryView();

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
          'Scan History',
          style: AppTypography.h3.copyWith(color: theme.colorScheme.onSurface),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: theme.colorScheme.onSurface),
            onPressed: () {
              context.read<ScanHistoryBloc>().add(RefreshScanHistory());
            },
          ),
        ],
      ),
      body: BlocBuilder<ScanHistoryBloc, ScanHistoryState>(
        builder: (context, state) {
          if (state.status == ScanHistoryStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.sticker_color,
              ),
            );
          }

          if (state.status == ScanHistoryStatus.failure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.emergencyRed,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Failed to load history',
                    style: AppTypography.h4.copyWith(color: theme.colorScheme.onSurface),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    state.errorMessage ?? 'Unknown error',
                    style: AppTypography.bodyMedium.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (state.historyWithDetails.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 80,
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'No Scan History',
                    style: AppTypography.h3.copyWith(color: theme.colorScheme.onSurface),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Your scanned stickers will appear here',
                    style: AppTypography.bodyMedium.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ScanHistoryBloc>().add(RefreshScanHistory());
              await Future.delayed(const Duration(seconds: 1));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: state.historyWithDetails.length,
              itemBuilder: (context, index) {
                final item = state.historyWithDetails[index];
                final scanHistory = item['history'] as ScanHistory;
                final sticker = item['sticker'] as Sticker;

                return _HistoryCard(
                  scanHistory: scanHistory,
                  sticker: sticker,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final ScanHistory scanHistory;
  final Sticker sticker;

  const _HistoryCard({
    required this.scanHistory,
    required this.sticker,
  });

  IconData _getActionIcon(String action) {
    switch (action) {
      case 'activated':
        return Icons.check_circle;
      case 'viewed':
        return Icons.visibility;
      case 'blocked':
        return Icons.block;
      case 'unblocked':
        return Icons.lock_open;
      default:
        return Icons.info;
    }
  }

  Color _getActionColor(String action) {
    switch (action) {
      case 'activated':
        return Colors.green;
      case 'viewed':
        return AppColors.accentAmber;
      case 'blocked':
        return AppColors.emergencyRed;
      case 'unblocked':
        return AppColors.accentOrange;
      default:
        return AppColors.accentYellow;
    }
  }

  String _formatAction(String action) {
    return action[0].toUpperCase() + action.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSecondary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getActionColor(scanHistory.action).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    _getActionIcon(scanHistory.action),
                    color: _getActionColor(scanHistory.action),
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatAction(scanHistory.action),
                        style: AppTypography.h4.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateFormat.format(scanHistory.scannedAt),
                        style: AppTypography.bodySmall.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStickerStatusColor(sticker.status),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    sticker.status.value.toUpperCase(),
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Divider(color: theme.dividerColor, height: 1),
            const SizedBox(height: AppSpacing.md),
            _InfoRow(
              label: 'Sticker ID',
              value: sticker.stickerId,
              icon: Icons.qr_code,
            ),
            if (sticker.vehicleInfo != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _InfoRow(
                label: 'Vehicle',
                value: '${sticker.vehicleInfo!.make} ${sticker.vehicleInfo!.model}',
                icon: Icons.directions_car,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStickerStatusColor(StickerStatus status) {
    switch (status) {
      case StickerStatus.active:
        return Colors.green;
      case StickerStatus.inactive:
        return Colors.grey;
      case StickerStatus.suspended:
        return Colors.orange;
      case StickerStatus.expired:
        return AppColors.emergencyRed;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurface.withOpacity(0.7),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '$label: ',
          style: AppTypography.bodySmall.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.bodySmall.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

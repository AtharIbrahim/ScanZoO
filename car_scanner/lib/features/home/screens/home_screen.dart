import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_provider.dart';
import '../../sticker/screens/activate_sticker_screen.dart';
import '../../sticker/screens/sticker_management_screen.dart';
import '../../sticker/screens/scan_history_screen.dart';
import '../../contacts/screens/emergency_contacts_screen.dart';
import '../../sticker/bloc/sticker_bloc.dart';
import '../../sticker/bloc/sticker_event.dart';
import '../../sticker/bloc/sticker_state.dart';
import '../../sticker/repositories/sticker_repository.dart';
import '../../sticker/models/sticker.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late StickerBloc _stickerBloc;
  StreamSubscription? _stickerSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _stickerBloc = StickerBloc(stickerRepository: StickerRepository());
    _stickerBloc.add(const LoadUserStickers());
    
    // Set up proper real-time listener using BLoC state stream
    _setupRealtimeListener();
  }

  void _setupRealtimeListener() {
    // Listen to app lifecycle to refresh when app comes to foreground
    // This is more efficient than polling every 30 seconds
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh stickers when app comes back to foreground
      _stickerBloc.add(const LoadUserStickers());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stickerSubscription?.cancel();
    _stickerBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final isDark = themeProvider.isDarkMode;
    
    return BlocProvider.value(
      value: _stickerBloc,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          title: const Text(
              'Car Scanner',
              style: TextStyle(
                color: AppColors.sticker_color,
                fontWeight: FontWeight.w800,
              ),
            ),
          actions: [
            // Theme toggle with animated icon
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isDark 
                    ? AppColors.darkSurface.withOpacity(0.6)
                    : AppColors.lightSecondary.withOpacity(0.6),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return RotationTransition(
                      turns: animation,
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: Icon(
                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    key: ValueKey(isDark),
                  ),
                ),
                onPressed: () {
                  themeProvider.toggleTheme();
                },
                tooltip: isDark ? 'Light Mode' : 'Dark Mode',
              ),
            ),
            // Menu button
            Container(
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isDark 
                    ? AppColors.darkSurface.withOpacity(0.6)
                    : AppColors.lightSecondary.withOpacity(0.6),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                onSelected: (value) async {
                  if (value == 'theme') {
                    // Show theme selection dialog
                    await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        title: const Text('Theme Settings'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _ThemeOption(
                              icon: Icons.brightness_auto_rounded,
                              title: 'System',
                              subtitle: 'Follow device theme',
                              isSelected: themeProvider.themeMode == ThemeMode.system,
                              onTap: () {
                                themeProvider.followSystem();
                                Navigator.pop(context);
                              },
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _ThemeOption(
                              icon: Icons.light_mode_rounded,
                              title: 'Light',
                              subtitle: 'Always use light theme',
                              isSelected: themeProvider.themeMode == ThemeMode.light,
                              onTap: () {
                                themeProvider.setThemeMode(ThemeMode.light);
                                Navigator.pop(context);
                              },
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _ThemeOption(
                              icon: Icons.dark_mode_rounded,
                              title: 'Dark',
                              subtitle: 'Always use dark theme',
                              isSelected: themeProvider.themeMode == ThemeMode.dark,
                              onTap: () {
                                themeProvider.setThemeMode(ThemeMode.dark);
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (value == 'logout') {
                    final shouldLogout = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.emergencyRed,
                            ),
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    );

                    if (shouldLogout == true && context.mounted) {
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, '/login');
                      }
                    }
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'theme',
                    child: Row(
                      children: [
                        Icon(
                          themeProvider.followSystemTheme 
                              ? Icons.brightness_auto_rounded 
                              : (isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        const Text('Theme Settings'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout_rounded, color: AppColors.emergencyRed, size: 20),
                        const SizedBox(width: 12),
                        Text('Logout', style: TextStyle(color: AppColors.emergencyRed)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: isDark 
                ? AppColors.darkBackgroundGradient
                : const LinearGradient(
                    colors: [AppColors.lightPrimary, AppColors.lightSecondary],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
          ),
          child: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                _stickerBloc.add(const LoadUserStickers());
                await Future.delayed(const Duration(seconds: 1));
              },
              color: AppColors.accentAmber,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Header Section with Welcome Message
                  // SliverToBoxAdapter(
                  //   child: Padding(
                  //     padding: const EdgeInsets.fromLTRB(
                  //       AppSpacing.lg, 
                  //       AppSpacing.md, 
                  //       AppSpacing.lg, 
                  //       AppSpacing.xl,
                  //     ),
                  //     child: Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Text(
                  //           'Welcome back',
                  //           style: AppTypography.bodyLarge.copyWith(
                  //             color: isDark 
                  //                 ? AppColors.darkTextSecondary 
                  //                 : AppColors.lightTextSecondary,
                  //           ),
                  //         ),
                  //         const SizedBox(height: AppSpacing.xs),
                  //         ShaderMask(
                  //           shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
                  //           child: Text(
                  //             FirebaseAuth.instance.currentUser?.displayName?.split(' ').first ?? 'User',
                  //             style: AppTypography.displayMedium.copyWith(
                  //               color: Colors.white,
                  //             ),
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  
                  // Sticker Section
                  const SliverToBoxAdapter(
                    child: _StickerSection(),
                  ),
                  
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.xl),
                  ),
                  
                  // Quick Actions Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: Text(
                        'Quick Actions',
                        style: AppTypography.h3.copyWith(
                          color: isDark 
                              ? AppColors.darkTextPrimary 
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                  ),
                  
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.md),
                  ),
                  
                  // Action Cards Grid
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        children: [
                          _ModernActionCard(
                            icon: Icons.qr_code_scanner_rounded,
                            title: 'Activate Sticker',
                            subtitle: 'Register your emergency sticker',
                            gradient: AppColors.sticker_color,
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ActivateStickerScreen(),
                                ),
                              );
                              
                              if (result == true && context.mounted) {
                                context.read<StickerBloc>().add(const LoadUserStickers());
                              }
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                          
                          _ModernActionCard(
                            icon: Icons.contact_emergency_rounded,
                            title: 'Emergency Contacts',
                            subtitle: 'Manage your emergency contacts',
                            gradient: AppColors.sticker_color,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const EmergencyContactsScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                          
                          Row(
                            children: [
                              Expanded(
                                child: _CompactActionCard(
                                  icon: Icons.history_rounded,
                                  title: 'Scan History',
                                  color: AppColors.sticker_color,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const ScanHistoryScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: _CompactActionCard(
                                  icon: Icons.help_rounded,
                                  title: 'Help Center',
                                  color: AppColors.sticker_color,
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text('Help center coming soon!'),
                                        backgroundColor: AppColors.sticker_color,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(AppRadius.md),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StickerSection extends StatelessWidget {
  const _StickerSection();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return BlocBuilder<StickerBloc, StickerState>(
      builder: (context, state) {
        if (state.status == StickerSubmissionStatus.loading) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            padding: const EdgeInsets.all(AppSpacing.xxl),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSecondary,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Center(
              child: Column(
                children: [
                  CircularProgressIndicator(
                    color: AppColors.sticker_color,
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Loading your stickers...',
                    style: AppTypography.bodyMedium.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (state.status == StickerSubmissionStatus.failure &&
            state.errorMessage != null) {
          return _ModernErrorCard(
            message: state.errorMessage!,
            onRetry: () =>
                context.read<StickerBloc>().add(const LoadUserStickers()),
          );
        }
        
        if (state.userStickers.isEmpty) {
          return const _ModernEmptyCard();
        } else {
          // Show all stickers in modern horizontal scroll
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  children: [
                    Icon(
                        Icons.style_rounded,
                        size: 24,
                        color: AppColors.sticker_color,
                      ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'My Stickers',
                      style: AppTypography.h3.copyWith(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.sticker_color,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        '${state.userStickers.length}',
                        style: AppTypography.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  physics: const BouncingScrollPhysics(),
                  itemCount: state.userStickers.length,
                  itemBuilder: (context, index) {
                    return _ModernStickerCard(
                      sticker: state.userStickers[index],
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }
}

// Modern Sticker Card with sticker image background
class _ModernStickerCard extends StatelessWidget {
  final Sticker sticker;
  
  const _ModernStickerCard({
    required this.sticker,
  });

  bool get _isBlocked => sticker.status == StickerStatus.suspended;

  @override
  Widget build(BuildContext context) {
    
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StickerManagementScreen(sticker: sticker),
          ),
        );
        
        if (result == true && context.mounted) {
          context.read<StickerBloc>().add(const LoadUserStickers());
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        margin: const EdgeInsets.only(right: AppSpacing.md),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: Stack(
            children: [
              // Sticker Background Image
              Positioned.fill(
                child: Image.asset(
                  'assets/qr_sticker_.png',
                  fit: BoxFit.cover,
                ),
              ),
              // Subtle overlay for better text readability
              Positioned.fill(
                child: Container(
                  // decoration: BoxDecoration(
                  //   gradient: LinearGradient(
                  //     colors: [
                  //       // Colors.transparent,
                  //       // Colors.transparent,
                  //     ],
                  //     begin: Alignment.topCenter,
                  //     end: Alignment.bottomCenter,
                  //   ),
                  // ),
                ),
              ),
              // Content directly on image - Left side only to avoid QR code
              Positioned(
                left: -2,
                top: 24,
                bottom: 0,
                right: MediaQuery.of(context).size.width * 0.40, // Leave space for QR code
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Badges stacked vertically
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Status badge
                          Row(
                            children: [Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.xs,
                              ),
                              // decoration: BoxDecoration(
                              //   color: _isBlocked 
                              //       ? AppColors.warning
                              //       : AppColors.success,
                              //   borderRadius: BorderRadius.circular(AppRadius.full),
                              //   boxShadow: [
                              //     BoxShadow(
                              //       color: Colors.black.withOpacity(0.5),
                              //       blurRadius: 12,
                              //       offset: const Offset(0, 3),
                              //     ),
                              //   ],
                              // ),
                              
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _isBlocked ? Icons.block_rounded : Icons.check_circle_rounded,
                                    size: 16,
                                    color: Colors.green,
                                  ),
                                  
                                ],
                              ),
                            ),
                            const SizedBox(width: 0),
                                Text(
                                  _isBlocked ? 'BLOCKED' : 'ACTIVE',
                                  style: AppTypography.overline.copyWith(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                            ]
                          ),
                          
                          // const SizedBox(height: AppSpacing.xs),
                          // // Emergency contacts count
                          // Container(
                          //   padding: const EdgeInsets.symmetric(
                          //     horizontal: AppSpacing.md,
                          //     vertical: AppSpacing.xs,
                          //   ),
                          //   decoration: BoxDecoration(
                          //     color: Colors.white.withOpacity(0.35),
                          //     borderRadius: BorderRadius.circular(AppRadius.full),
                          //     boxShadow: [
                          //       BoxShadow(
                          //         color: Colors.black.withOpacity(0.5),
                          //         blurRadius: 12,
                          //         offset: const Offset(0, 3),
                          //       ),
                          //     ],
                          //   ),
                          //   child: Row(
                          //     mainAxisSize: MainAxisSize.min,
                          //     children: [
                          //       Icon(
                          //         Icons.contacts_rounded,
                          //         size: 16,
                          //         color: Colors.white,
                          //       ),
                          //       const SizedBox(width: AppSpacing.xs),
                          //       Text(
                          //         '${sticker.emergencyContactIds.length}',
                          //         style: AppTypography.labelSmall.copyWith(
                          //           color: Colors.white,
                          //           fontWeight: FontWeight.w800,
                          //           fontSize: 13,
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                        ],
                      ),
                      
                      // Vehicle information
                      if (sticker.vehicleInfo != null) ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${sticker.vehicleInfo!.make} ${sticker.vehicleInfo!.model}',
                              style: AppTypography.h3.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.8),
                                    blurRadius: 12,
                                    offset: const Offset(0, 3),
                                  ),
                                  Shadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: AppSpacing.xxs,
                                  ),
                                  // decoration: BoxDecoration(
                                  //   color: Colors.white.withOpacity(0.3),
                                  //   borderRadius: BorderRadius.circular(AppRadius.sm),
                                  //   boxShadow: [
                                  //     BoxShadow(
                                  //       color: Colors.black.withOpacity(0.3),
                                  //       blurRadius: 4,
                                  //       offset: const Offset(0, 2),
                                  //     ),
                                  //   ],
                                  // ),
                                  child: Text(
                                    sticker.vehicleInfo!.year.toString(),
                                    style: AppTypography.bodySmall.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Icon(
                                  Icons.circle,
                                  size: 8,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  sticker.vehicleInfo!.color,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.6),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ] else ...[
                        Text(
                          'Vehicle Sticker',
                          style: AppTypography.h3.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.8),
                                blurRadius: 12,
                                offset: const Offset(0, 3),
                              ),
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      // Bottom row - Plate number
                      if (sticker.vehicleInfo != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.pin_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                sticker.vehicleInfo!.plateNumber,
                                style: AppTypography.labelMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
          ),
              ),
          ),
            ]
      ),
    ),),);
  }
}

// Modern Empty State Card
class _ModernEmptyCard extends StatelessWidget {
  const _ModernEmptyCard();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: isDark 
            ? LinearGradient(
                colors: [
                  AppColors.darkSurface,
                  AppColors.darkSecondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [
                  AppColors.lightSecondary,
                  AppColors.lightSurface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: isDark 
              ? AppColors.darkBorder.withOpacity(0.5)
              : AppColors.lightBorder,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Gradient Icon Container
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentAmber.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.qr_code_2_rounded,
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          
          Text(
            'No Active Stickers',
            style: AppTypography.h2.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          
          Text(
            'Activate your first emergency sticker to enable quick contact access for anyone who scans it.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          
          // Gradient Button
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentAmber.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ActivateStickerScreen(),
                  ),
                );

                if (result == true && context.mounted) {
                  context.read<StickerBloc>().add(const LoadUserStickers());
                }
              },
              icon: const Icon(Icons.add_circle_rounded),
              label: const Text('Activate Sticker'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.md,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Modern Error Card
class _ModernErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ModernErrorCard({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSecondary,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: AppColors.error.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_rounded,
              color: AppColors.error,
              size: 40,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          
          Text(
            'Something went wrong',
            style: AppTypography.h4.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          
          FilledButton.icon(
            onPressed: onRetry,
            icon: Icon(Icons.refresh_rounded),
            label: Text('Try Again'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}

// Modern Action Card with Gradient
class _ModernActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color gradient;
  final VoidCallback onTap;

  const _ModernActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSecondary,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: gradient.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Icon with backdrop
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: gradient.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  icon,
                  color: gradient,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              
              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.h4.copyWith(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary, 
                      ),
                    ),
                  ],
                ),
              ),
              
              // Arrow Icon
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Compact Action Card for Grid Layout
class _CompactActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _CompactActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSecondary,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// Theme Option Widget for Theme Selection Dialog
class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.accentAmber.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected 
                ? AppColors.accentAmber
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppColors.accentAmber
                    : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                icon,
                color: isSelected 
                    ? Colors.white
                    : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                size: 20,
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
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.accentAmber,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}

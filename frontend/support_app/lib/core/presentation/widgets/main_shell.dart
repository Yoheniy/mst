import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:support_app/utils/app_theme.dart';

class MainShell extends StatefulWidget {
  final Widget child;
  final String currentLocation;

  const MainShell({
    super.key,
    required this.child,
    required this.currentLocation,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: widget.child,
            ),
          );
        },
      ),
      bottomNavigationBar: _buildModernBottomNav(context),
      // Add floating action button for quick chat access
      floatingActionButton:
          _shouldShowFAB() ? _buildQuickChatFAB(context) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  bool _shouldShowFAB() {
    // Show FAB on home page and chat sessions page
    return widget.currentLocation == '/home' ||
        widget.currentLocation == '/chat';
  }

  Widget _buildQuickChatFAB(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentGreenPrimary,
            AppTheme.accentGreenSecondary,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentGreenPrimary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          context.go('/chat');
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(
          Icons.chat_bubble_outline_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildModernBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 80,
            maxHeight: 90,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Home',
                route: '/home',
                index: 0,
              ),
              _buildNavItem(
                context,
                icon: Icons.build_outlined,
                activeIcon: Icons.build_rounded,
                label: 'Machines',
                route: '/machines',
                index: 1,
              ),
              _buildNavItem(
                context,
                icon: Icons.chat_bubble_outline_rounded,
                activeIcon: Icons.chat_bubble_rounded,
                label: 'Chat',
                route: '/chat',
                index: 2,
              ),
              _buildNavItem(
                context,
                icon: Icons.book_outlined,
                activeIcon: Icons.book_rounded,
                label: 'Knowledge',
                route: '/knowledge-base',
                index: 3,
              ),
              _buildNavItem(
                context,
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Profile',
                route: '/profile',
                index: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required String route,
    required int index,
  }) {
    final isActive = _isCurrentRoute(route);

    return Expanded(
      child: GestureDetector(
        onTap: () => _navigateToRoute(context, route),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon Container with Animation
              Flexible(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppTheme.accentGreenPrimary.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      isActive ? activeIcon : icon,
                      key: ValueKey(isActive),
                      color: isActive
                          ? AppTheme.accentGreenPrimary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              // Label with Animation
              Flexible(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: AppTheme.inter(
                    fontSize: isActive ? 11 : 10,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive
                        ? AppTheme.accentGreenPrimary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isCurrentRoute(String route) {
    // Handle special cases for chat routes
    if (route == '/chat') {
      return widget.currentLocation.startsWith('/chat');
    }
    return widget.currentLocation == route;
  }

  void _navigateToRoute(BuildContext context, String route) {
    if (!_isCurrentRoute(route)) {
      // Add a subtle haptic feedback
      HapticFeedback.lightImpact();

      // Navigate with animation
      context.go(route);
    }
  }
}

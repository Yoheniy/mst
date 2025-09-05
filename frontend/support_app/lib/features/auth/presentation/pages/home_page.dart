import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:support_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:support_app/core/services/theme_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          final user = state.user;
          return Scaffold(
            body: CustomScrollView(
              slivers: [
                // Custom App Bar with Theme Toggle
                SliverAppBar(
                  expandedHeight: 120,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.primaryContainer,
                          ],
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              // User Profile Section
                              CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.white24,
                                child: Text(
                                  user.fullName
                                      .split(' ')
                                      .map((e) => e[0])
                                      .join(''),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Greeting and Name
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _getGreeting(),
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      user.fullName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Theme Toggle Button
                              Consumer<ThemeService>(
                                builder: (context, themeService, child) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white24,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: IconButton(
                                      onPressed: () =>
                                          themeService.toggleTheme(),
                                      icon: Icon(
                                        themeService.isDarkMode
                                            ? Icons.light_mode
                                            : Icons.dark_mode,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                      tooltip: themeService.isDarkMode
                                          ? 'Switch to Light Mode'
                                          : 'Switch to Dark Mode',
                                    ),
                                  );
                                },
                              ),
                              // Notifications
                              IconButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Notifications coming soon!')),
                                  );
                                },
                                icon: const Icon(
                                  Icons.notifications_outlined,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Main Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Main Question
                        Text(
                          'How Can I Assist You Today?',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                        const SizedBox(height: 24),

                        // Feature Cards Grid
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.85,
                          children: [
                            _buildFeatureCard(
                              context,
                              icon: Icons.chat_bubble_outline,
                              title: 'Chat with AI',
                              description:
                                  'Get instant technical support and answers from our AI assistant.',
                              buttonText: 'Ask Now',
                              buttonColor:
                                  Theme.of(context).colorScheme.primary,
                              onTap: () => context.go('/chat'),
                            ),
                            _buildFeatureCard(
                              context,
                              icon: Icons.mic,
                              title: 'Voice Chat',
                              description:
                                  'Talk to our AI assistant using voice commands for hands-free support.',
                              buttonText: 'Start',
                              buttonColor:
                                  Theme.of(context).colorScheme.secondary,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Voice chat coming soon!')),
                                );
                              },
                            ),
                            _buildFeatureCard(
                              context,
                              icon: Icons.build,
                              title: 'My Machines',
                              description:
                                  'Manage your machine tools, view status, and access manuals.',
                              buttonText: 'View',
                              buttonColor:
                                  Theme.of(context).colorScheme.tertiary,
                              onTap: () => context.go('/machines'),
                            ),
                            _buildFeatureCard(
                              context,
                              icon: Icons.support_agent,
                              title: 'Support Tickets',
                              description:
                                  'Create and track support tickets for technical issues.',
                              buttonText: 'Create',
                              buttonColor: Theme.of(context).colorScheme.error,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Support tickets coming soon!')),
                                );
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // History Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Activity',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                            ),
                            TextButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Full history coming soon!')),
                                );
                              },
                              child: const Text('See all'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Recent Items List
                        _buildRecentItem(
                          context,
                          icon: Icons.chat_bubble_outline,
                          title: 'AI Chat Session',
                          description:
                              'Technical support for CNC machine calibration',
                          time: '2 hours ago',
                          onTap: () => context.go('/chat'),
                        ),
                        _buildRecentItem(
                          context,
                          icon: Icons.build,
                          title: 'Machine Maintenance',
                          description:
                              'Scheduled maintenance for Lathe Machine #3',
                          time: '1 day ago',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Machine details coming soon!')),
                            );
                          },
                        ),
                        _buildRecentItem(
                          context,
                          icon: Icons.support_agent,
                          title: 'Support Ticket #1234',
                          description:
                              'Issue resolved: Tool calibration problem',
                          time: '3 days ago',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Ticket details coming soon!')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Floating Action Button for Quick Chat
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => context.go('/chat'),
              icon: const Icon(Icons.chat_bubble),
              label: const Text('Quick Chat'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            // Bottom Navigation
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: 0,
              onTap: (index) {
                switch (index) {
                  case 0:
                    // Already on home
                    break;
                  case 1:
                    context.go('/machines');
                    break;
                  case 2:
                    context.go('/chat');
                    break;
                  case 3:
                    context.go('/knowledge-base');
                    break;
                  case 4:
                    context.go('/profile');
                    break;
                }
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.build),
                  label: 'Machines',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat_bubble),
                  label: 'Chat',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.book),
                  label: 'Knowledge',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          );
        } else if (state is AuthLoading) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/login');
          });
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required String buttonText,
    required Color buttonColor,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 32,
              color: buttonColor,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: Colors.white,
                ),
                child: Text(buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required String time,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description),
            const SizedBox(height: 4),
            Text(
              time,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

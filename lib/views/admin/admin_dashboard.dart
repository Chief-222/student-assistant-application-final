//Admin Dashboard
//Main screen for admins to manage all applications.

//Tyam M - 222056708
//Masita TM - 223043636
//Mabusela PA - 222021446
//Mkhonza ZZ - 223043927
//Matthews LKM - 222044118

//Admin login:
//admin@gmail.com
//Admin123!

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/application_viewmodel.dart';
import 'manage_applications.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    // Load all applications when dashboard opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApplicationViewModel>().loadAllApplications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await context.read<ApplicationViewModel>().loadAllApplications();
            },
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await context.read<AuthViewModel>().logout();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Admin Header
            const Card(
              elevation: 4,
              color: Color(0xFF1A1A2E),
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.verified_user,
                      size: 64,
                      color: Color(0xFFE2B13C),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Administrator Panel',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Manage Student Applications',
                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Application Statistics
            Consumer<ApplicationViewModel>(
              builder: (context, appVM, child) {
                if (appVM.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _StatsCard(
                            title: 'Pending',
                            count: appVM.pendingApplications.length,
                            color: const Color(0xFFF59E0B),
                            icon: Icons.schedule,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatsCard(
                            title: 'Approved',
                            count: appVM.approvedApplications.length,
                            color: const Color(0xFF10B981),
                            icon: Icons.verified,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatsCard(
                            title: 'Rejected',
                            count: appVM.rejectedApplications.length,
                            color: const Color(0xFFEF4444),
                            icon: Icons.do_not_disturb_on,
                          ),
                        ),
                      ],
                    ),
                    if (appVM.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          appVM.errorMessage!,
                          style: const TextStyle(color: Color(0xFFEF4444)),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Manage Applications Button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ManageApplicationsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.grid_view),
              label: const Text('Manage All Applications'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: const Color(0xFF1A1A2E),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final IconData icon;

  const _StatsCard({
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

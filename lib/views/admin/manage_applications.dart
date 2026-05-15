//Manage Applications Screen
//Admin screen to view, approve, reject, and delete applications.

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
import '../../models/application.dart';
import '../../viewmodels/application_viewmodel.dart';

class ManageApplicationsScreen extends StatefulWidget {
  const ManageApplicationsScreen({super.key});

  @override
  State<ManageApplicationsScreen> createState() =>
      _ManageApplicationsScreenState();
}

class _ManageApplicationsScreenState extends State<ManageApplicationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApplicationViewModel>().loadAllApplications();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Applications'),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFE2B13C),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Approved'),
            Tab(text: 'Rejected'),
          ],
        ),
      ),
      body: Consumer<ApplicationViewModel>(
        builder: (context, appVM, child) {
          if (appVM.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _ApplicationsList(
                applications: appVM.pendingApplications,
                isPending: true,
              ),
              _ApplicationsList(
                applications: appVM.approvedApplications,
                isPending: false,
              ),
              _ApplicationsList(
                applications: appVM.rejectedApplications,
                isPending: false,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ApplicationsList extends StatelessWidget {
  final List<Application> applications;
  final bool isPending;

  const _ApplicationsList({
    required this.applications,
    required this.isPending,
  });

  @override
  Widget build(BuildContext context) {
    if (applications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No applications',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: applications.length,
      itemBuilder: (context, index) {
        final application = applications[index];
        return _AdminApplicationCard(
          application: application,
          isPending: isPending,
        );
      },
    );
  }
}

class _AdminApplicationCard extends StatelessWidget {
  final Application application;
  final bool isPending;

  const _AdminApplicationCard({
    required this.application,
    required this.isPending,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Info
            Row(
              children: [
                const Icon(Icons.account_circle, color: Color(0xFF1A1A2E)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    application.studentName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Modules
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📚 ${application.module1}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  if (application.module2 != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '📚 ${application.module2}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Date
            Text(
              'Submitted: ${_formatDate(application.createdAt)}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 12),

            // Action Buttons
            if (isPending)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showConfirmDialog(
                          context,
                          'Approve Application',
                          'Are you sure you want to approve this application?',
                          () {
                            context
                                .read<ApplicationViewModel>()
                                .approveApplication(application.id);
                          },
                        );
                      },
                      icon: const Icon(Icons.verified),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showConfirmDialog(
                          context,
                          'Reject Application',
                          'Are you sure you want to reject this application?',
                          () {
                            context
                                .read<ApplicationViewModel>()
                                .rejectApplication(application.id);
                          },
                        );
                      },
                      icon: const Icon(Icons.do_not_disturb_on),
                      label: const Text('Reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              )
            else
              ElevatedButton.icon(
                onPressed: () {
                  _showConfirmDialog(
                    context,
                    'Delete Application',
                    'Are you sure you want to delete this application?',
                    () {
                      context
                          .read<ApplicationViewModel>()
                          .deleteApplication(application.id);
                    },
                  );
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showConfirmDialog(
    BuildContext context,
    String title,
    String message,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                onConfirm();
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}

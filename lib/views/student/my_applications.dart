//My Applications Screen
//Displays all applications submitted by the current student.

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
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/application_viewmodel.dart';

class MyApplicationsScreen extends StatefulWidget {
  const MyApplicationsScreen({super.key});

  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVM = context.read<AuthViewModel>();
      final appVM = context.read<ApplicationViewModel>();
      if (authVM.userId != null) {
        appVM.loadStudentApplications(authVM.userId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Applications'),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
      ),
      body: Consumer<ApplicationViewModel>(
        builder: (context, appVM, child) {
          if (appVM.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (appVM.applications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No applications yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Submit your first module assistance application!',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appVM.applications.length,
            itemBuilder: (context, index) {
              final application = appVM.applications[index];
              return _ApplicationCard(application: application);
            },
          );
        },
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final Application application;

  const _ApplicationCard({required this.application});

  Color _getStatusColor() {
    switch (application.status) {
      case 'approved':
        return const Color(0xFF10B981);
      case 'rejected':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  IconData _getStatusIcon() {
    switch (application.status) {
      case 'approved':
        return Icons.verified;
      case 'rejected':
        return Icons.do_not_disturb_on;
      default:
        return Icons.schedule;
    }
  }

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
            // Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Module Assistance',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _getStatusColor()),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(),
                        size: 16,
                        color: _getStatusColor(),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        application.applicationStatus.displayName,
                        style: TextStyle(
                          color: _getStatusColor(),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),

            // Module 1
            _ModuleRow(label: 'Module 1', value: application.module1),
            const SizedBox(height: 8),

            // Module 2 (if exists)
            if (application.module2 != null)
              _ModuleRow(label: 'Module 2', value: application.module2!),
            const SizedBox(height: 12),

            // Dates
            Text(
              'Submitted: ${_formatDate(application.createdAt)}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            Text(
              'Last Updated: ${_formatDate(application.updatedAt)}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _ModuleRow extends StatelessWidget {
  final String label;
  final String value;

  const _ModuleRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }
}

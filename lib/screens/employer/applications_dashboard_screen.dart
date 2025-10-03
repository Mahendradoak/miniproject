import 'package:flutter/material.dart';

class ApplicationsDashboardScreen extends StatefulWidget {
  const ApplicationsDashboardScreen({super.key});

  @override
  State<ApplicationsDashboardScreen> createState() => _ApplicationsDashboardScreenState();
}

class _ApplicationsDashboardScreenState extends State<ApplicationsDashboardScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Applications Dashboard'),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.dashboard, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Applications Dashboard',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'View and manage all applications here',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

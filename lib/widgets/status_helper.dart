import 'package:flutter/material.dart';

// Helper to get the next status in your flow
String getNextStatus(String currentStatus) {
  if (currentStatus == 'PENDING') return 'COMPLETED';
  if (currentStatus == 'COMPLETED') return 'SUBMITTED';
  if (currentStatus == 'SUBMITTED') return 'CORRECTED';
  return currentStatus;
}

// Add this helper to the same file
TextStyle getStatusTextStyle(BuildContext context) {
  return const TextStyle(
    color: Colors.white,
    fontSize: 10,
    fontWeight: FontWeight.bold,
  );
}

String rightButtonStatus(String currentStatus) {
  if (currentStatus == 'PENDING') return 'Complete';
  if (currentStatus == 'COMPLETED') return 'Submit';
  if (currentStatus == 'SUBMITTED') return 'Corrected';
  return currentStatus;
}

Color getUrgencyColor(DateTime deadline, String status) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  if (status == 'PENDING') {
    if (deadline.isBefore(today)) return Colors.redAccent;
    if (deadline.difference(today).inDays <= 1) return Colors.orange;
    return Colors.blueGrey;
  }
  if (status == 'COMPLETED') {
    if (deadline.isBefore(today)) return Colors.redAccent;
    if (deadline.difference(today).inDays <= 1) return Colors.green;
    return Colors.blueGrey;
  }

  return Colors.green;
}

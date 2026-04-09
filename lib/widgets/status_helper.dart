import 'package:flutter/material.dart';

Color getStatusColor(BuildContext context, String status) {
  final colorScheme = Theme.of(context).colorScheme;

  switch (status) {
    case 'PENDING':
      return colorScheme.outline; // Neutral grey-ish from theme
    case 'COMPLETED':
      return colorScheme.primary; // Indigo from theme
    case 'SUBMITTED':
      return Colors.green; // Semantic colors like Green are usually okay
    case 'CORRECTED':
      return Colors.teal;
    default:
      return colorScheme.outline;
  }
}

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

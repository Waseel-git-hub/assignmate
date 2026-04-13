import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:assignmate/models/subject.dart';
import 'package:assignmate/widgets/subject_card.dart'; // Import your new card
import 'package:assignmate/screens/add_subject_screen.dart';
import 'package:assignmate/screens/subject_info_screen.dart';

class SubjectScreen extends StatefulWidget {
  const SubjectScreen({super.key});

  @override
  State<SubjectScreen> createState() => _SubjectScreenState();
}

class _SubjectScreenState extends State<SubjectScreen> {
  // 1. Define the state for selection
  final Set<dynamic> _selectedIds = {};

  void _toggleSelection(dynamic key) {
    setState(() {
      if (_selectedIds.contains(key)) {
        _selectedIds.remove(key);
      } else {
        _selectedIds.add(key);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIds.isEmpty
            ? "Subjects"
            : "${_selectedIds.length} Selected"),
        actions: [
          // Inside your SubjectScreen AppBar actions
          if (_selectedIds.length ==
              1) // Only show edit if exactly one item is selected
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // Find the actual subject object using the selected ID
                final subjectToEdit =
                    Hive.box<Subject>('subjectsBox').get(_selectedIds.first);

                if (subjectToEdit != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddSubjectScreen(subject: subjectToEdit),
                    ),
                  );
                  // Clear selection after navigating
                  setState(() => _selectedIds.clear());
                }
              },
            ),
          if (_selectedIds.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                final box = Hive.box<Subject>('subjectsBox');
                for (var key in _selectedIds) {
                  box.delete(key);
                }
                setState(() => _selectedIds.clear());
              },
            ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Subject>('subjectsBox').listenable(),
        builder: (context, Box<Subject> box, _) {
          final subjects = box.values.toList();

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              final subject = subjects[index];
              final isSelected = _selectedIds.contains(subject.key);

              return SubjectCard(
                subject: subject,
                isSelected: isSelected,
                onTap: () {
                  if (_selectedIds.isNotEmpty) {
                    _toggleSelection(subject.key);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SubjectInfoScreen(subject: subject),
                      ),
                    );
                  }
                },
                onLongPress: () => _toggleSelection(subject.key),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddSubjectScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

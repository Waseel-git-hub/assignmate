import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:assignmate/screens/add_subject_screen.dart';
import '../models/subject.dart';
import '../models/assignment.dart';

class SubjectInfoScreen extends StatelessWidget {
  final Subject subject;

  const SubjectInfoScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    final Color subjectColor = Color(subject.colorValue);

    return Scaffold(
      appBar: AppBar(
        title: Text(subject.name),
        backgroundColor: subjectColor.withOpacity(0.1),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  // Passing the current subject object here triggers "Edit Mode"
                  builder: (context) => AddSubjectScreen(subject: subject),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 30),
            decoration: BoxDecoration(
              color: subjectColor.withOpacity(0.1),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: subjectColor,
                  child: Icon(
                    IconData(subject.iconCodePoint,
                        fontFamily: 'MaterialIcons'),
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  subject.name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: subjectColor,
                      ),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Assignments",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // List of Assignments for this subject
          Expanded(
            child: ValueListenableBuilder(
              valueListenable:
                  Hive.box<Assignment>('assignmentsBox').listenable(),
              builder: (context, Box<Assignment> box, _) {
                // Filter assignments by the current subject's name
                final filteredList = box.values
                    .where((a) => a.subjectId == subject.key)
                    .toList();

                if (filteredList.isEmpty) {
                  return Center(
                    child: Text("No assignments for ${subject.name} yet."),
                  );
                }

                return ListView.builder(
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final assignment = filteredList[index];
                    return ListTile(
                      leading: const Icon(Icons.assignment_outlined),
                      title: Text(assignment.title),
                      subtitle: Text(
                          "Due: ${assignment.deadline.toString().split(' ')[0]}"),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Navigate to assignment details if you have that screen
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
//  MODELS
import 'package:assignmate/models/assignment.dart';
import 'package:assignmate/models/subject.dart';
//  SCREENS
import 'package:assignmate/screens/add_assignment_screen.dart';
import 'package:assignmate/screens/add_subject_screen.dart';
import 'package:assignmate/screens/assignment_info_screen.dart';
//  SERVICES
import 'package:assignmate/services/database_service.dart';
//  WIDGETS
import 'package:assignmate/widgets/status_helper.dart';
//------------------------------------------------------------

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
                  builder: (context) => AddSubjectScreen(subject: subject),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
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
              valueListenable: DatabaseService.assignmentBox.listenable(),
              builder: (context, Box<Assignment> box, _) {
                final filteredList =
                    DatabaseService.getAssignments(subjectId: subject.key);
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
                      subtitle: Row(
                        children: [
                          Text(
                              "Due: ${assignment.deadline.toString().split(' ')[0]}"),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: getUrgencyColor(
                                      assignment.deadline, assignment.status)
                                  .withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              assignment.status,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: getUrgencyColor(
                                    assignment.deadline, assignment.status),
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AssignmentInfoScreen(
                                      assignment: assignment,
                                    )));
                      },
                      onLongPress: () {},
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddAssignmentScreen(
                assignment: Assignment(
                  id: "",
                  title: "",
                  subjectId: subject.key,
                  description: "",
                  deadline: DateTime.now().add(const Duration(days: 1)),
                  status: 'PENDING',
                ),
              ),
            ),
          );
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Assignment", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

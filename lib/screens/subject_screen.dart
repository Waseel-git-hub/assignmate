// lib/screens/subject_screen.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/subject.dart';
import 'add_subject_screen.dart';

class SubjectScreen extends StatelessWidget {
  const SubjectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Subjects"), centerTitle: true),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Subject>('subjectsBox').listenable(),
        builder: (context, Box<Subject> box, _) {
          final subjects = box.values.toList();

          if (subjects.isEmpty) {
            return const Center(child: Text("No subjects added yet."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              final subject = subjects[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(subject.colorValue).withOpacity(0.1),
                    child: Icon(
                      IconData(subject.iconCodePoint,
                          fontFamily: 'MaterialIcons'),
                      color: Color(subject.colorValue),
                    ),
                  ),
                  title: Text(subject.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                AddSubjectScreen(subject: subject)),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
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

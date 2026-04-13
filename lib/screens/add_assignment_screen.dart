import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/assignment.dart';
import '../models/subject.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'add_subject_screen.dart';

class AddAssignmentScreen extends StatefulWidget {
  final Assignment? assignment;
  const AddAssignmentScreen({super.key, this.assignment});

  @override
  State<AddAssignmentScreen> createState() => _AddAssignmentScreenState();
}

class _AddAssignmentScreenState extends State<AddAssignmentScreen> {
  final FocusNode _subjectFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();
  late TextEditingController _titleController;
  late TextEditingController _subjectController;
  late TextEditingController _descController;
  late DateTime _selectedDate;
  final List<String> _statusOptions = [
    'PENDING',
    'COMPLETED',
    'SUBMITTED',
    'CORRECTED',
  ];
  late String _currentStatus;
  @override
  void dispose() {
    // Crucial: Clean them up when the screen closes
    _subjectFocus.dispose();
    _descriptionFocus.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.assignment?.title ?? "",
    );
    _subjectController = TextEditingController(
      text: widget.assignment?.subject ?? "",
    );
    _descController = TextEditingController(
      text: widget.assignment?.description ?? "",
    );
    _selectedDate = widget.assignment?.deadline ??
        DateTime.now().add(const Duration(days: 1));
    _currentStatus = widget.assignment?.status ?? 'PENDING';
  }

  void _saveAssignment() async {
    final box = Hive.box<Assignment>('assignmentsBox');
    if (widget.assignment != null) {
      widget.assignment!.title = _titleController.text;
      widget.assignment!.subject = _subjectController.text;
      widget.assignment!.description = _descController.text;
      widget.assignment!.deadline = _selectedDate;
      widget.assignment!.status = _currentStatus;
      await widget.assignment!.save();
    } else {
      final newAsgn = Assignment(
        id: const Uuid().v4(),
        title: _titleController.text,
        subject: _subjectController.text,
        description: _descController.text,
        deadline: _selectedDate,
        status: _currentStatus,
      );
      await box.put(newAsgn.id, newAsgn);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(widget.assignment != null ? "Edit" : "New")),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextField(
            autofocus: true,
            textInputAction: TextInputAction.next,
            controller: _titleController,
            onSubmitted: (_) {
              // When 'Next' is pressed, jump to Subject
              FocusScope.of(context).requestFocus(_subjectFocus);
            },
            decoration: const InputDecoration(labelText: "Title"),
          ),
          const SizedBox(height: 16),
          // In add_assignment_screen.dart
          ValueListenableBuilder(
            valueListenable: Hive.box<Subject>('subjectsBox').listenable(),
            builder: (context, Box<Subject> box, _) {
              final subjects = box.values.toList();

              return DropdownButtonFormField<String>(
                // Still store the name in the assignment subject field
                value: subjects.any((s) => s.name == _subjectController.text)
                    ? _subjectController.text
                    : null,
                items: [
                  ...subjects.map((sub) => DropdownMenuItem(
                        value: sub.name,
                        child: Row(
                          children: [
                            Icon(IconData(sub.iconCodePoint,
                                fontFamily: 'MaterialIcons')),
                            const SizedBox(width: 10),
                            Text(sub.name),
                          ],
                        ),
                      )),
                  const DropdownMenuItem(
                    value: "ADD_NEW",
                    child: Text("+ Add New Subject",
                        style: TextStyle(color: Colors.blue)),
                  )
                ],
                onChanged: (val) {
                  if (val == "ADD_NEW") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddSubjectScreen()),
                    );
                  } else {
                    _subjectController.text = val!;
                  }
                },
              );
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descController,
            decoration: const InputDecoration(labelText: "Description"),
            maxLines: 3,
            focusNode:
                _descriptionFocus, // Tell this field it's the 'Description' node
            textInputAction:
                TextInputAction.done, // Shows 'Done' or 'Check' icon
          ),
          const SizedBox(height: 24),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text("Deadline"),
            subtitle: Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
            trailing: Icon(Icons.calendar_month, color: colorScheme.primary),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
              );
              if (picked != null) setState(() => _selectedDate = picked);
            },
          ),
          const SizedBox(height: 24),
          const Text("Status", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _statusOptions.map((status) {
                final isSelected = _currentStatus == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (val) =>
                        setState(() => _currentStatus = status),
                    selectedColor: colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : colorScheme.onSurface,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _saveAssignment,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              widget.assignment != null
                  ? "Update Assignment"
                  : "Save Assignment",
            ),
          ),
        ],
      ),
    );
  }
}

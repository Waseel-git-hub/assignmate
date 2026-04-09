import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/assignment.dart';
import 'package:hive/hive.dart';

class AddAssignmentScreen extends StatefulWidget {
  final Assignment? assignment;
  const AddAssignmentScreen({super.key, this.assignment});

  @override
  State<AddAssignmentScreen> createState() => _AddAssignmentScreenState();
}

class _AddAssignmentScreenState extends State<AddAssignmentScreen> {
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
    _selectedDate =
        widget.assignment?.deadline ??
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
            controller: _titleController,
            decoration: const InputDecoration(labelText: "Title"),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _subjectController,
            decoration: const InputDecoration(labelText: "Subject"),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descController,
            decoration: const InputDecoration(labelText: "Description"),
            maxLines: 3,
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
              foregroundColor: colorScheme.onPrimary,
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

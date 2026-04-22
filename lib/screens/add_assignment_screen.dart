import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:hive_flutter/hive_flutter.dart';
//  MODELS
import '../models/assignment.dart';
import '../models/subject.dart';
//  SCREENS
import '../screens/add_subject_screen.dart';
//  SERVICES
import '../services/database_service.dart';
import '../services/notification_services.dart';
//------------------------------------------------------------

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
  late TextEditingController _descController;
  late DateTime _deadlineDate;
  late DateTime? _reminderDate;
  bool _isAutoReminder = true;
  final List<String> _statusOptions = [
    'PENDING',
    'COMPLETED',
    'SUBMITTED',
    'CORRECTED',
  ];
  late String _currentStatus;
  dynamic _selectedSubjectId;

  void _updateDeadline(DateTime deadline) {
    setState(() {
      _deadlineDate = deadline;
      if (_isAutoReminder) {
        // Automatically set reminder to 1 day before at 9:00 AM
        _reminderDate = deadline
            .subtract(const Duration(days: 1))
            .copyWith(hour: 9, minute: 0);
      }
    });
  }

  @override
  void dispose() {
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
    _selectedSubjectId = widget.assignment?.subjectId;
    _descController = TextEditingController(
      text: widget.assignment?.description ?? "",
    );
    _deadlineDate = widget.assignment?.deadline ??
        DateTime.now().add(const Duration(days: 1));
    _reminderDate = widget.assignment?.reminder;

    // If there's already a reminder, don't force 'Auto' back to true
    if (widget.assignment != null && widget.assignment?.reminder != null) {
      _isAutoReminder = false;
    } else {
      _isAutoReminder = true;
      _reminderDate = _deadlineDate
          .subtract(const Duration(days: 1))
          .copyWith(hour: 9, minute: 0);
    }
    _currentStatus = widget.assignment?.status ?? 'PENDING';
  }

  void _saveAssignment() async {
    Assignment activeAssignment;

    if (widget.assignment != null && widget.assignment!.id.isNotEmpty) {
      activeAssignment = widget.assignment!;
      activeAssignment.title = _titleController.text.trim();
      activeAssignment.subjectId = _selectedSubjectId;
      activeAssignment.description = _descController.text.trim();
      activeAssignment.deadline = _deadlineDate;
      activeAssignment.reminder = _reminderDate;
      activeAssignment.status = _currentStatus;
    } else {
      activeAssignment = Assignment(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        subjectId: _selectedSubjectId,
        description: _descController.text.trim(),
        deadline: _deadlineDate,
        reminder: _reminderDate,
        status: _currentStatus,
      );
    }
    await DatabaseService.saveAssignment(activeAssignment);
    await NotificationService().cancelNotification(activeAssignment.id);

    if (_reminderDate != null && _reminderDate!.isAfter(DateTime.now())) {
      await NotificationService().scheduleAssignmentReminder(
        id: activeAssignment.id, // Now this won't be null
        title: activeAssignment.title,
        subjectId: activeAssignment.subjectId,
        reminder: _reminderDate!,
        deadline: _deadlineDate,
      );
    }

    if (mounted) Navigator.pop(context);
  }

  void _onDeadlinePicked() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadlineDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() {
        _deadlineDate = picked;
        // If auto-reminder is on, set it to 1 day before at a sensible time (e.g., 9 AM)
        if (_isAutoReminder) {
          _reminderDate = picked
              .subtract(const Duration(days: 1))
              .copyWith(hour: 9, minute: 0);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          appBar:
              AppBar(title: Text(widget.assignment != null ? "Edit" : "New")),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              TextField(
                autofocus: true,
                textInputAction: TextInputAction.next,
                controller: _titleController,
                onSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_subjectFocus);
                },
                decoration: const InputDecoration(labelText: "Title"),
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder(
                valueListenable: DatabaseService.subjectBox.listenable(),
                builder: (context, Box<Subject> box, _) {
                  final subjects = box.values.toList();
                  return DropdownButtonFormField<dynamic>(
                    // Still store the name in the assignment subject field
                    value: _selectedSubjectId,
                    items: [
                      ...subjects.map((sub) => DropdownMenuItem(
                            value: sub.key,
                            child: Row(
                              children: [
                                Icon(
                                  IconData(sub.iconCodePoint,
                                      fontFamily: 'MaterialIcons'),
                                  color: Color(sub.colorValue),
                                ),
                                const SizedBox(width: 10),
                                Text(sub.name),
                              ],
                            ),
                          )),
                      DropdownMenuItem(
                        value: "ADD_NEW",
                        child: Text("+ Add New Subject",
                            style: TextStyle(color: Colors.blue)),
                      ),
                    ],
                    onChanged: (val) {
                      if (val == "ADD_NEW") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AddSubjectScreen()),
                        );
                      } else {
                        setState(() => _selectedSubjectId = val);
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
                subtitle:
                    Text(DateFormat('MMM dd, yyyy').format(_deadlineDate)),
                trailing:
                    Icon(Icons.calendar_month, color: colorScheme.primary),
                onTap: _onDeadlinePicked,
              ),
              const Divider(),
              SwitchListTile(
                title: const Text("Default Reminder"),
                subtitle: const Text("1 day before deadline at 21:00"),
                value: _isAutoReminder,
                onChanged: (val) {
                  setState(() {
                    _isAutoReminder = val;
                    if (val) _updateDeadline(_deadlineDate);
                  });
                },
              ),
              if (!_isAutoReminder)
                ListTile(
                  leading: Icon(
                    Icons.notifications_active_outlined,
                    color: _reminderDate != null
                        ? theme.colorScheme.primary
                        : Colors.grey,
                  ),
                  title: const Text("Custom Reminder Time"),
                  subtitle: Text(
                    _reminderDate == null
                        ? "No reminder set"
                        : "${DateFormat('dd MMM, hh:mm').format(_reminderDate!)} ", // Clarify source
                  ),
                  onTap: () async {
                    FocusScope.of(context).unfocus();
                    // 1. Pick the DATE
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _reminderDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate:
                          _deadlineDate, // User can't set a reminder AFTER the deadline
                      helpText: 'Select Reminder Date',
                    );

                    if (pickedDate == null) return;

                    // 2. Pick the TIME
                    if (!mounted) return;
                    final TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(
                          _reminderDate ?? DateTime.now()),
                      helpText: 'Select Reminder Time',
                    );

                    if (pickedTime != null) {
                      setState(() {
                        _reminderDate = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                      });
                    }
                  },
                ),
              const SizedBox(height: 24),
              const Text("Status",
                  style: TextStyle(fontWeight: FontWeight.bold)),
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
                          color:
                              isSelected ? Colors.white : colorScheme.onSurface,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  if (_titleController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please enter a title")),
                    );
                    return;
                  }

                  if (_selectedSubjectId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please select a subject")),
                    );
                    return;
                  }
                  _saveAssignment();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  (widget.assignment != null &&
                          widget.assignment!.id.isNotEmpty)
                      ? "Update Assignment"
                      : "Save Assignment",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ));
  }
}

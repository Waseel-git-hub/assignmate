import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
//  MODELS
import 'package:assignmate/models/assignment.dart';
//  SCREENS
import 'package:assignmate/screens/add_assignment_screen.dart';
import 'package:assignmate/screens/assignment_info_screen.dart';
//  WIDGETS
import 'package:assignmate/widgets/assignment_card.dart';
import 'package:assignmate/widgets/status_helper.dart';
//  SERVICES
import 'package:assignmate/services/database_service.dart';
//------------------------------------------------------------

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Set<String> _selectedIds = {};
  bool get _isSelectionMode => _selectedIds.isNotEmpty;
  bool _isOverdueExpanded = true;
  bool _isTomorrowExpanded = true;
  bool _isUpcomingExpanded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _clearSelection() => setState(() => _selectedIds.clear());

  void _deleteSelected() async {
    for (var id in _selectedIds) {
      await DatabaseService.deleteAssignment(id);
    }
    _clearSelection();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: _isSelectionMode
          ? AppBar(
              backgroundColor: colorScheme.primaryContainer,
              title: Text(
                "${_selectedIds.length} Selected",
                style: TextStyle(color: colorScheme.onPrimaryContainer),
              ),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: _clearSelection,
                color: colorScheme.onPrimaryContainer,
              ),
              actions: [
                if (_selectedIds.length == 1)
                  IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        final assignmentToEdit =
                            DatabaseService.getAssignmentById(
                                _selectedIds.first);

                        if (assignmentToEdit != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddAssignmentScreen(
                                  assignment: assignmentToEdit),
                            ),
                          );
                          setState(() => _selectedIds.clear());
                        }
                      }),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _deleteSelected,
                  color: colorScheme.onPrimaryContainer,
                ),
              ],
            )
          : null,
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: DatabaseService.assignmentBox.listenable(),
          builder: (context, Box<Assignment> box, _) {
            // Date Logic for Grouping
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            final tomorrow = today.add(const Duration(days: 1));

            final pending = DatabaseService.getAssignments(
              completionStatus: 'PENDING',
            );
            // Sub-categories for Pending
            final p_overdue = pending.where((t) {
              final deadlineDate =
                  DateTime(t.deadline.year, t.deadline.month, t.deadline.day);
              return deadlineDate.isBefore(today);
            }).toList();

            final p_dueTomorrow = pending.where((t) {
              final d = t.deadline;
              final deadlineDate = DateTime(d.year, d.month, d.day);
              return deadlineDate.isAtSameMomentAs(tomorrow);
            }).toList();

            // Anything that is NOT overdue and NOT tomorrow is upcoming
            final p_upcoming = pending.where((t) {
              final d = t.deadline;
              final deadlineDate = DateTime(d.year, d.month, d.day);
              return deadlineDate.isAfter(tomorrow);
            }).toList();
            final completed = DatabaseService.getAssignments(
              completionStatus: "COMPLETED",
            );
            final c_overdue =
                completed.where((t) => t.deadline.isBefore(today)).toList();
            final c_dueTomorrow = completed.where((t) {
              final d = t.deadline;
              final deadlineDate = DateTime(d.year, d.month, d.day);
              return deadlineDate.isAtSameMomentAs(tomorrow);
            }).toList();
            final c_upcoming = completed.where((t) {
              final d = t.deadline;
              final deadlineDate = DateTime(d.year, d.month, d.day);
              return deadlineDate.isAfter(tomorrow);
            }).toList();

            final submitted = DatabaseService.getAssignments(
              completionStatus: "SUBMITTED",
            );

            return Column(
              children: [
                if (!_isSelectionMode)
                  _buildHeader(
                    context,
                    pending.length,
                    completed.length,
                    submitted.length,
                  ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Pending Tab
                      _buildGroupedList(p_overdue, p_dueTomorrow, p_upcoming),
                      // Completed Tab
                      _buildGroupedList(
                        c_overdue,
                        c_dueTomorrow,
                        c_upcoming,
                        tomorrowColor: Colors.green,
                      ),

                      // Submission Tab (Standard list)
                      _buildSListWidget(submitted, submitted.length),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorScheme.primary,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddAssignmentScreen()),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Widget Expandable list
  List<Widget> _buildExpandableList(
    String heading,
    Color color,
    List<Assignment> tasks,
    bool isExpanded,
    VoidCallback onToggle,
  ) {
    // If no tasks, return an empty list (equivalent to "empty function" return)
    if (tasks.isEmpty) return [];

    return [
      _buildSectionHeader(heading, color, tasks.length, isExpanded, onToggle),
      if (isExpanded)
        ...tasks.map(
          (t) => AssignmentCard(
            assignment: t,
            showExpandableButton:
                t.status == 'COMPLETED', // Toggle the type here
            isSelected: _selectedIds.contains(t.id),
            rightButtonFunction: () async {
              t.status = getNextStatus(t.status);
              await t.save();
              setState(() {});
            },
            onLongPress: () => _toggleSelection(t.id),
            onTap: () {
              if (_isSelectionMode) {
                _toggleSelection(t.id);
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AssignmentInfoScreen(assignment: t),
                  ),
                );
              }
            },
            textExpanded: "Checked",
            expandedFunction: () async {
              t.status = 'CORRECTED';
              await t.save();
              setState(() {});
            },
            onStatusUpdate: () {
              setState(() {});
            },
          ),
        ),
    ];
  }

  // New Widget to handle the grouped sections
  Widget _buildGroupedList(
    List<Assignment> overdue,
    List<Assignment> tomorrow,
    List<Assignment> upcoming, {
    Color overdueColor = Colors.redAccent,
    Color tomorrowColor = Colors.orange,
    Color upcomingColor = Colors.blueGrey,
  }) {
    if (overdue.isEmpty && tomorrow.isEmpty && upcoming.isEmpty) {
      return const Center(child: Text("No pending assignments"));
    }

    return ListView(
      children: [
        // CRITICAL: You MUST use '...' before each function call
        ..._buildExpandableList(
          "Overdue",
          overdueColor,
          overdue,
          _isOverdueExpanded,
          () => setState(() => _isOverdueExpanded = !_isOverdueExpanded),
        ),
        ..._buildExpandableList(
          "Tomorrow",
          tomorrowColor,
          tomorrow,
          _isTomorrowExpanded,
          () => setState(() => _isTomorrowExpanded = !_isTomorrowExpanded),
        ),
        ..._buildExpandableList(
          "Upcoming",
          upcomingColor,
          upcoming,
          _isUpcomingExpanded,
          () => setState(() => _isUpcomingExpanded = !_isUpcomingExpanded),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  List<Widget> _buildSubmittedList(List<Assignment> assignments) {
    if (assignments.isEmpty) return [];

    return [
      ...assignments.map(
        (assignment) => AssignmentCard(
          assignment: assignment,
          submitted: true,
          isSelected: _selectedIds.contains(assignment.id),
          onLongPress: () => _toggleSelection(assignment.id),
          onTap: () {
            if (_isSelectionMode) {
              _toggleSelection(assignment.key);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AssignmentInfoScreen(assignment: assignment),
                ),
              );
            }
          },
          showExpandableButton: false,
          showRightButton: true,
          rightButtonFunction: () async {
            assignment.status = getNextStatus(assignment.status);
            await assignment.save();
            setState(() {});
          },
          onStatusUpdate: () {
            // This makes the Home Screen rebuild so the "Completed" count updates
            setState(() {});
          },
        ),
      ),
    ];
  }

  Widget _buildSListWidget(List<Assignment> assignments, int count) {
    if (assignments.isEmpty)
      return const Center(child: Text("No Assignment Submitted"));

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            24,
            16,
            12,
            8,
          ), // Reduced right padding for the button
          child: Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.greenAccent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                // Added Expanded so the text takes up space and pushes the button to the right
                child: Text(
                  "Submitted ($count)",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        ..._buildSubmittedList(assignments),
      ],
    );
  }

  // Helper for Section Headers
  Widget _buildSectionHeader(
    String title,
    Color color,
    int count,
    bool isExpanded,
    VoidCallback onToggle,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        24,
        16,
        12,
        8,
      ), // Reduced right padding for the button
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            // Added Expanded so the text takes up space and pushes the button to the right
            child: Text(
              "$title ($count)",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          IconButton(
            onPressed: onToggle,
            visualDensity: VisualDensity.compact,
            icon: Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    int pCount,
    int cCount,
    int sCount,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "My Assignments",
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
              tabs: [
                Tab(text: "Pending ($pCount)"),
                Tab(text: "Completed ($cCount)"),
                Tab(text: "Submitted ($sCount)"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

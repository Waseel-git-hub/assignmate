import 'package:assignmate/screens/add_assignment_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/assignment.dart';
import '../widgets/status_helper.dart';

class AssignmentCard extends StatelessWidget {
  final Assignment assignment;
  final bool showRightButton;
  final String textRightButton;
  final Color colorRightButton;
  final VoidCallback? rightButtonFunction;
  final bool isSelected; // Added for selection
  final VoidCallback onLongPress; // Added for selection
  final VoidCallback onTap; // Added for selection
  final bool showExpandableButton;
  final String textExpanded;
  final VoidCallback? expandedFunction;
  final bool submitted;
  final VoidCallback onStatusUpdate; // Used to refresh the Home Screen

  const AssignmentCard({
    super.key,
    required this.assignment,
    this.showRightButton = true,
    this.textRightButton = '',
    this.colorRightButton = Colors.green,
    this.rightButtonFunction,
    this.showExpandableButton = false,
    this.textExpanded = "",
    this.expandedFunction,
    this.isSelected = false,
    required this.onLongPress,
    required this.onTap,
    this.submitted = false,
    required this.onStatusUpdate,
  });

  Color _getUrgencyColor(DateTime deadline, String status) {
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final urgencyColor = _getUrgencyColor(
      assignment.deadline,
      assignment.status,
    );
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        // Change background color when selected
        color: isSelected
            ? theme.colorScheme.primaryContainer.withOpacity(isDark ? 0.5 : 0.9)
            : (isDark
                ? theme.colorScheme
                    .surfaceContainerHigh // Matches the tinted dark bg
                : theme.colorScheme.surface), // Matches the light bg
        borderRadius: BorderRadius.circular(24),
        // Add a border when selected
        border: Border.all(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        // Using InkWell for better touch feedback
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        onLongPress: onLongPress,
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Your original Urgency Bar
              Container(
                width: 5,
                decoration: BoxDecoration(
                  color: urgencyColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    bottomLeft: Radius.circular(24),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Subject Icon Box
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: (Colors.blueGrey).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              isSelected
                                  ? Icons.check_circle
                                  : Icons.assignment_outlined,
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : Colors.blueGrey,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  assignment.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF1E293B),
                                  ),
                                ),
                                Text(
                                  assignment.subject,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today_outlined,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      DateFormat('dd MMM yyyy').format(
                                        submitted
                                            ? (assignment.submittedAt ??
                                                DateTime.now())
                                            : assignment.deadline,
                                      ),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Keep your popup menu but disable if in selection mode
                          if (!isSelected &&
                              (showExpandableButton || showRightButton))
                            PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.more_vert,
                                color: Colors.grey,
                              ),
                              onSelected: (value) {
                                if (value == 'delete')
                                  assignment.delete();
                                else if (value == 'edit') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddAssignmentScreen(
                                        assignment: assignment,
                                      ),
                                    ),
                                  );
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text("Edit"),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text(
                                    "Delete",
                                    style: TextStyle(color: Colors.redAccent),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      if (showExpandableButton || showRightButton)
                        const SizedBox(height: 20),
                      if (showExpandableButton || showRightButton)
                        Row(
                          children: [
                            _buildStatusBadge(urgencyColor),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 1,
                              child: showExpandableButton
                                  ? ExpandableButton(
                                      label: "Submit",
                                      onMainTap: () {
                                        rightButtonFunction?.call();
                                      },
                                      onOptionTap: () async {
                                        assignment.status = 'CORRECTED';
                                        await assignment.save();
                                        onStatusUpdate();
                                      },
                                    )
                                  : _buildNormalButton(
                                      colorRightButton,
                                      Colors.white,
                                      rightButtonStatus(assignment.status),
                                      isSelected ? null : rightButtonFunction,
                                    ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        assignment.status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildNormalButton(
    Color buttonColor,
    Color TextColor,
    String textButton,
    VoidCallback? buttonFunction,
  ) {
    return Expanded(
      child: ElevatedButton(
        onPressed: isSelected ? null : buttonFunction,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: TextColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(textButton),
      ),
    );
  }
}

class ExpandableButton extends StatefulWidget {
  final String label;
  final VoidCallback onMainTap;
  final VoidCallback onOptionTap;
  final Color textColor;
  final Color buttonColor;

  const ExpandableButton({
    super.key,
    required this.label,
    required this.onMainTap,
    required this.onOptionTap,
    this.textColor = Colors.white,
    this.buttonColor = Colors.green,
  });

  @override
  State<ExpandableButton> createState() => _ExpandableActionButtonState();
}

class _ExpandableActionButtonState extends State<ExpandableButton> {
  bool _isExpanded = false;
  Color buttonColor = ExpandableButton(
    label: "",
    onMainTap: () {},
    onOptionTap: () {},
  ).buttonColor;
  Color textColor = ExpandableButton(
    label: "",
    onMainTap: () {},
    onOptionTap: () {},
  ).textColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: widget.buttonColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Row: Split into two clickable areas
          IntrinsicHeight(
            // Ensures the divider matches the button height
            child: Row(
              children: [
                // 1. MAIN BUTTON AREA (The label)
                Expanded(
                  child: InkWell(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    onTap: widget.onMainTap,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Center(
                        child: Text(
                          widget.label,
                          style: TextStyle(
                            color: widget.textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // 2. THE DIVIDER
                VerticalDivider(
                  color: widget.textColor.withOpacity(0.3),
                  width: 1,
                  indent: 8,
                  endIndent: 8,
                ),

                // 3. THE ARROW AREA (Much larger hit target now)
                InkWell(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  child: Container(
                    // We use horizontal padding to widen the click area
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    child: AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 150),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: widget.textColor.withOpacity(0.8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 4. EXPANDABLE OPTION
          ClipRect(
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 150),
              alignment: Alignment.topCenter,
              heightFactor: _isExpanded ? 1.0 : 0.0,
              child: Column(
                children: [
                  Divider(color: widget.textColor.withOpacity(0.2), height: 1),
                  InkWell(
                    onTap: () {
                      widget.onOptionTap();
                      setState(() => _isExpanded = false);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        "Mark as Corrected",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: widget.textColor, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

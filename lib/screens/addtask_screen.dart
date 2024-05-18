import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:task_synchro/providers/notification_service.dart';

class AddTaskScreen extends StatefulWidget {
  final String userId;

  const AddTaskScreen({super.key, required this.userId});
  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  DateTime _selectedStartDate = DateTime.now();
  DateTime _selectedEndDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now();

  Future<void> _selectStartDate() async {
    final DateTime pickedDate = (await showDatePicker(
      barrierDismissible: false,
      context: context,
      initialDate: _selectedStartDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    ))!;
    if (pickedDate != null && pickedDate != _selectedStartDate) {
      setState(() {
        _selectedStartDate = pickedDate;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime pickedDate = (await showDatePicker(
      barrierDismissible: false,
      context: context,
      initialDate: _selectedEndDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    ))!;
    if (pickedDate != null && pickedDate != _selectedEndDate) {
      setState(() {
        _selectedEndDate = pickedDate;
      });
    }
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? pickedStartTime = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (pickedStartTime != null && pickedStartTime != _startTime) {
      setState(() {
        _startTime = pickedStartTime;
      });
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? pickedEndTime = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (pickedEndTime != null && pickedEndTime != _endTime) {
      setState(() {
        _endTime = pickedEndTime;
      });
    }
  }

  bool _validateDates() {
    final startDateTime = DateTime(
      _selectedStartDate.year,
      _selectedStartDate.month,
      _selectedStartDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    final endDateTime = DateTime(
      _selectedEndDate.year,
      _selectedEndDate.month,
      _selectedEndDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    return startDateTime.isBefore(endDateTime);
  }

  void _showValidationError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Validation Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _addTaskToFirestore() async {
    if (_formKey.currentState!.validate()) {
      if (_validateDates()) {
        try {
          final startDateTime = DateTime(
            _selectedStartDate.year,
            _selectedStartDate.month,
            _selectedStartDate.day,
            _startTime.hour,
            _startTime.minute,
          );

          final endDateTime = DateTime(
            _selectedEndDate.year,
            _selectedEndDate.month,
            _selectedEndDate.day,
            _endTime.hour,
            _endTime.minute,
          );

          // Calculate duration in hours
          int durationInHours = endDateTime.difference(startDateTime).inHours;

          // Format duration
          String formattedDuration = _formatDuration(durationInHours);

          await FirebaseFirestore.instance
              .collection('Users')
              .doc(widget.userId) // Replace with the actual user ID
              .collection('tasks')
              .add({
            'title': titleController.text,
            'description': descController.text,
            'startDate': startDateTime,
            'startTime': _startTime.format(context),
            'endDate': endDateTime,
            'endTime': _endTime.format(context),
            'duration': formattedDuration,
            'status': 'pending'
          });
          DateTime dateTime = DateTime(endDateTime.year, endDateTime.month,
              endDateTime.day, _endTime.hour, _endTime.minute);
          NotificationService.scheduledNotification(
              titleController.text, descController.text, dateTime);

          Navigator.of(context).pop();
        } catch (e) {
          _showValidationError('Failed to add task. Please try again.');
        }
      } else {
        _showValidationError(
            'Start date and time must be before the deadline date and time');
      }
    }
  }

  String _formatDuration(int durationInHours) {
    // Convert hours to "x hrs" format
    if (durationInHours < 24) {
      return '$durationInHours hrs';
    }
    // If duration is greater than 24 hours, convert to days
    int days = durationInHours ~/ 24;
    int remainingHours = durationInHours % 24;
    if (remainingHours == 0) {
      return '$days days';
    } else {
      return '$days days, $remainingHours hrs';
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedStartDate =
        DateFormat('d MMMM yyyy').format(_selectedStartDate);
    String formattedDeadlineDate =
        DateFormat('d MMMM yyyy').format(_selectedEndDate);
    String formattedStartTime = _startTime.format(context);
    String formattedEndTime = _endTime.format(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Task Title',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 5),
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.black26)),
                    hintText: "Title",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                Text(
                  'Description',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 5),
                TextFormField(
                  controller: descController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.black26)),
                      hintText: "Description"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 20),
                // Text(
                //   'Date',
                //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                // ),
                // SizedBox(height: 5),
                // Container(
                //   decoration: BoxDecoration(
                //     border: Border.all(color: Colors.black38),
                //     borderRadius: BorderRadius.circular(10),
                //   ),
                //   child: Padding(
                //     padding:
                //         const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                //     child: GestureDetector(
                //       onTap: () {
                //         _selectDate();
                //       },
                //       child: Row(
                //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         children: [
                //           Text(
                //             formattedStartDate,
                //             style: TextStyle(
                //                 fontSize: 16.0, fontWeight: FontWeight.w500),
                //           ),
                //           Icon(Icons.calendar_today),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                // SizedBox(height: 20),
                Text(
                  'Start Date and Time : ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _selectStartDate();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black38),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  formattedStartDate,
                                  style: TextStyle(fontSize: 16),
                                ),
                                Icon(Icons.calendar_today),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _selectStartTime();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black38),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  formattedStartTime,
                                  style: TextStyle(fontSize: 16),
                                ),
                                Icon(Icons.access_time),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  'Deadline Date and Time : ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _selectEndDate();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black38),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  formattedDeadlineDate,
                                  style: TextStyle(fontSize: 16),
                                ),
                                Icon(Icons.calendar_today),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _selectEndTime();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black38),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  formattedEndTime,
                                  style: TextStyle(fontSize: 16),
                                ),
                                Icon(Icons.access_time),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 50),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      _addTaskToFirestore();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(
                            10), // Adjust the radius as needed
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      child: Text(
                        "Add Task",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

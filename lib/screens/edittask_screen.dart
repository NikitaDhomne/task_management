import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditTaskScreen extends StatefulWidget {
  final String userId;
  final String taskId;
  const EditTaskScreen({super.key, required this.userId, required this.taskId});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descController = TextEditingController();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  String _startTime = '';
  String _endTime = '';

  @override
  void initState() {
    super.initState();
    // Call function to fetch task data when the screen initializes
    fetchTaskData();
  }

  // Function to fetch task data from Firestore
  void fetchTaskData() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.userId)
          .collection('tasks')
          .doc(widget.taskId)
          .get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        String title =
            data['title']; // Assuming 'title' is the field name in Firestore
        _titleController.text = title; // Set title to the text field controller

        String desciption = data['description'];
        _descController.text = desciption;

        Timestamp startDateTimestamp = data[
            'startDate']; // Assuming 'start_date' is the field name in Firestore
        if (startDateTimestamp != null) {
          startDate =
              startDateTimestamp.toDate(); // Convert Timestamp to DateTime
        }

        Timestamp endDateTimestamp = data['endDate'];
        if (endDateTimestamp != null) {
          endDate = endDateTimestamp.toDate(); // Convert Timestamp to DateTime
        }

        String startTime = data['startTime'];
        _startTime = startTime;

        String endTime = data['endTime'];
        _endTime = endTime;

        // Trigger rebuild to update UI
        setState(() {});
        // print(startTime);

        print(startDate);
      } else {
        print('Document not found!');
      }
    } catch (e) {
      print('Error fetching task data: $e');
    }
  }

  Future<void> _selectStartDate() async {
    final DateTime pickedDate = (await showDatePicker(
      barrierDismissible: false,
      context: context,
      initialDate: startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    ))!;
    if (pickedDate != null && pickedDate != startDate) {
      setState(() {
        startDate = pickedDate;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime pickedDate = (await showDatePicker(
      barrierDismissible: false,
      context: context,
      initialDate: endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    ))!;
    if (pickedDate != null && pickedDate != endDate) {
      setState(() {
        endDate = pickedDate;
      });
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        final String formattedTime = pickedTime.format(context);
        _endTime = formattedTime;
      });
    }
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        final String formattedTime = pickedTime.format(context);
        _startTime = formattedTime;
      });
    }
  }

  Future<void> _updateTaskToFirestore() async {
    final String title = _titleController.text;
    final String description = _descController.text;
    final Timestamp startDateTimestamp = Timestamp.fromDate(startDate);
    final Timestamp endDateTimestamp = Timestamp.fromDate(endDate);

    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.userId)
          .collection('tasks')
          .doc(widget.taskId)
          .update({
        'title': title,
        'description': description,
        'startDate': startDateTimestamp,
        'endDate': endDateTimestamp,
        'startTime': _startTime, // Assuming 'startTime' is a String field
        'endTime': _endTime, // Assuming 'endTime' is a String field
      });

      print('Task updated successfully!');
      Navigator.pop(context); // Close the edit screen
    } catch (e) {
      print('Error updating task: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedStartDate = DateFormat('d MMMM yyyy').format(startDate);
    String formattedEndDate = DateFormat('d MMMM yyyy').format(endDate);

    print('.....');
    print(_startTime);
    print(formattedStartDate);

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Task'),
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
                  controller: _titleController,
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
                  controller: _descController,
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
                                  _startTime,
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
                                  formattedEndDate,
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
                                  _endTime,
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
                      _updateTaskToFirestore();
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
                        "Update Task",
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

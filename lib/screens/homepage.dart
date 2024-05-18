import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_synchro/providers/notification_service.dart';

import 'package:task_synchro/screens/addtask_screen.dart';
import 'package:task_synchro/screens/edittask_screen.dart';
import 'package:task_synchro/screens/signIn_screen.dart';

class Homepage extends StatefulWidget {
  static const routeName = '/homepage';
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  DateTime selectedDate = DateTime.now();

  void onDaySelected(int day) {
    setState(() {
      if (day == DateTime.now().day) {
        selectedDate = DateTime.now(); // Set selectedDate to today's date
      } else {
        selectedDate = DateTime(selectedDate.year, selectedDate.month, day);
      }
      print(selectedDate);
    });
  }

  Future<void> updateTaskStatus(
      String userId, String taskId, String newStatus) async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('tasks')
        .doc(taskId)
        .update({'status': newStatus});
  }

  Future<void> deleteTask(String userId, String taskId) async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('d MMMM yyyy').format(now);
    int daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    int today = now.day;

    // Get the current user ID
    User? user = FirebaseAuth.instance.currentUser;
    String userId = user!.uid;

    List<Widget> dayCircles = List.generate(daysInMonth - today + 1, (index) {
      // Generating circles for each day from today to the end of the month
      int day = today + index;
      Color circleColor;
      if (day == today) {
        circleColor = Colors.pink; // Today's circle color
      } else if (day == selectedDate.day) {
        circleColor = Colors.brown; // Selected date circle color
      } else {
        circleColor = Colors.indigoAccent; // Other days' circle color
      }
      return GestureDetector(
        onTap: () => onDaySelected(day),
        child: Column(
          children: [
            Text(
              '${DateFormat('MMM').format(DateTime(now.year, now.month))}',
              style: TextStyle(fontSize: 12),
            ),
            SizedBox(height: 4),
            Container(
              width: 50,
              height: 50,
              margin: EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: circleColor,
              ),
              child: Center(
                child: Text(
                  '$day',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 4),
            Text(
              '${DateFormat('E').format(DateTime(now.year, now.month, day))}',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      );
    });

    List<Color> cardColors = [
      Colors.indigoAccent,
      Colors.lightGreen,
      Colors.orangeAccent
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Task Synchro'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              final FirebaseAuth _auth = FirebaseAuth.instance;

              Future<void> logout() async {
                await _auth.signOut();
                print('User logged out successfully!');
              }

              Navigator.pushNamed(context, SignInPage.routeName);
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddTaskScreen(
                                userId: userId,
                              )),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(
                          10), // Adjust the radius as needed
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    child: Text(
                      "New Task",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ),
                )
              ],
            ),
            Text(
              'Today',
              style: TextStyle(fontSize: 18),
            ),

            SizedBox(height: 10),
            // Horizontal list view of day circles
            Container(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: dayCircles,
              ),
            ),

            SizedBox(height: 20),
            Text(
              'Tasks',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Expanded(
              flex: 3,
              child: Center(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('Users')
                    .doc(userId)
                    .collection('tasks')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  // Filter tasks based on selected date
                  final List<DocumentSnapshot> tasks =
                      snapshot.data!.docs.where((doc) {
                    DateTime startDate = doc['startDate'].toDate();
                    DateTime endDate = doc['endDate'].toDate();

                    // Only compare the date components
                    DateTime startDateOnly = DateTime(
                        startDate.year, startDate.month, startDate.day);
                    DateTime endDateOnly =
                        DateTime(endDate.year, endDate.month, endDate.day);
                    DateTime selectedDateOnly = DateTime(selectedDate.year,
                        selectedDate.month, selectedDate.day);

                    return startDateOnly.isBefore(
                            selectedDateOnly.add(Duration(days: 1))) &&
                        endDateOnly.isAfter(
                            selectedDateOnly.subtract(Duration(days: 1)));
                  }).toList();

                  if (tasks.isEmpty) {
                    return Text(
                      'No tasks for the selected date',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    );
                  }

                  return ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final document = tasks[index];
                      final taskId = document.id;
                      final title = document['title'];
                      final description = document['description'];
                      final startDate =
                          (document['startDate'] as Timestamp).toDate();
                      final startTime = document['startTime'];
                      final endDate =
                          (document['endDate'] as Timestamp).toDate();
                      final endTime = document['endTime'];
                      final duration = document['duration'];
                      final status = document['status'];

                      // Format dates and times
                      String formattedStartDate =
                          DateFormat('d MMMM').format(startDate);
                      String formattedStartTime = startTime is Timestamp
                          ? DateFormat('h:mm a').format(startTime.toDate())
                          : startTime.toString(); // Convert to string if needed
                      String formattedEndDate =
                          DateFormat('d MMMM').format(endDate);
                      String formattedEndTime = endTime is Timestamp
                          ? DateFormat('h:mm a').format(endTime.toDate())
                          : endTime.toString(); // Convert to string if needed

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditTaskScreen(
                                      userId: userId, taskId: taskId)));
                        },
                        child: Card(
                            color: cardColors[index %
                                cardColors
                                    .length], // Assign color based on index
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 8),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$title',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        '$description',
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'Start Time : $formattedStartDate $formattedStartTime',
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'Deadline : $formattedEndDate $formattedEndTime',
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                        padding: EdgeInsets.only(right: 10),
                                        child: IconButton(
                                          icon: status == 'pending'
                                              ? Icon(
                                                  Icons.pending_actions_rounded,
                                                  color: Colors.pinkAccent,
                                                  size: 30,
                                                )
                                              : Icon(
                                                  Icons
                                                      .check_circle_outline_outlined,
                                                  color: Colors.amber,
                                                  size: 30,
                                                ),
                                          onPressed: () {
                                            if (status == 'pending') {
                                              updateTaskStatus(
                                                  userId, taskId, 'completed');
                                            } else {
                                              updateTaskStatus(
                                                  userId, taskId, 'pending');
                                            }
                                          },
                                        )),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Container(
                                        padding: EdgeInsets.only(
                                          right: 10,
                                        ),
                                        child: IconButton(
                                            onPressed: () async {
                                              await deleteTask(userId, taskId);
                                            },
                                            icon: Icon(Icons.delete,
                                                color: Colors.red, size: 30)))
                                  ],
                                )
                              ],
                            )),
                      );
                    },
                  );
                },
              )),
            ),
          ],
        ),
      ),
    );
  }
}

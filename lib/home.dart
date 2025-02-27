import 'package:flutter/material.dart';
import 'watch.dart';
import 'profile.dart';
import 'search.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/breathing_service.dart';
import 'breathing_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> tasks = [];
  static const String TASKS_KEY = 'tasks';
  late double screenWidth;
  late double screenHeight;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Custom App Bar
            SliverToBoxAdapter(
              child: Container(
                padding:
                    EdgeInsets.all(screenWidth * 0.05), // Responsive padding
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(
                        screenWidth * 0.08), // Responsive radius
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello Mejia',
                              style: TextStyle(
                                fontSize:
                                    screenWidth * 0.07, // Responsive font size
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            Text(
                              'Welcome back',
                              style: TextStyle(
                                fontSize:
                                    screenWidth * 0.04, // Responsive font size
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        CircleAvatar(
                          radius: screenWidth * 0.06, // Responsive radius
                          backgroundColor: Colors.green[100],
                          child: Icon(
                            Icons.person_outline,
                            color: Colors.green[800],
                            size: screenWidth * 0.07, // Responsive icon size
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02), // Responsive spacing
                    _buildBreathingCard(),
                  ],
                ),
              ),
            ),

            // Quick Actions Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildQuickActionsGrid(),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Today\'s Tasks',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _showDateTimePicker,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Task'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Tasks List
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: tasks.isEmpty
                  ? SliverToBoxAdapter(
                      child: _buildEmptyTasksPlaceholder(),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildTaskItem(tasks[index]),
                        childCount: tasks.length,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreathingCard() {
    return GestureDetector(
      onTap: _showBreathingExercises,
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.05),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.green[400]!,
              Colors.green[300]!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(screenWidth * 0.05),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.03,
                      vertical: screenHeight * 0.008,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(screenWidth * 0.05),
                    ),
                    child: Text(
                      'Featured',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  Text(
                    'Breathing Exercise',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.055,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    'Reduce anxiety with guided breathing',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.035,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: screenWidth * 0.2,
              height: screenWidth * 0.2,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.air,
                color: Colors.white,
                size: screenWidth * 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    final List<Map<String, dynamic>> actions = [
      {
        'icon': Icons.watch_outlined,
        'title': 'Watch',
        'screen': WatchScreen(),
      },
      {
        'icon': Icons.navigation,
        'title': 'Navigation',
        'screen': SearchScreen(),
      },
      {
        'icon': Icons.person_outline,
        'title': 'Profile',
        'screen': const ProfilePage(),
      },
      {
        'icon': Icons.calendar_today,
        'title': 'Calendar',
        'onTap': _showDateTimePicker,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: screenWidth * 0.04,
        mainAxisSpacing: screenWidth * 0.04,
        childAspectRatio: screenWidth / (screenHeight / 2.5),
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        return _buildActionCard(
          icon: actions[index]['icon'],
          title: actions[index]['title'],
          onTap: actions[index]['screen'] != null
              ? () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => actions[index]['screen'],
                    ),
                  )
              : actions[index]['onTap'],
        );
      },
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.green[700],
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyTasksPlaceholder() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          Icon(
            Icons.task_alt,
            size: 60,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No tasks for today',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add a new task',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(Task task) {
    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.015),
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.01,
        horizontal: screenWidth * 0.04,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 8,
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted ? Colors.grey : Colors.black87,
          ),
        ),
        subtitle: Text(
          _formatDateTime(task.dateTime),
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                task.isCompleted
                    ? Icons.check_circle
                    : Icons.check_circle_outline,
                color: task.isCompleted ? Colors.green[700] : Colors.grey[400],
              ),
              onPressed: () => _toggleTaskCompletion(task),
            ),
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: Colors.red[300],
              ),
              onPressed: () => _removeTask(task),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksJson = prefs.getString(TASKS_KEY);

    if (tasksJson != null) {
      setState(() {
        final List<dynamic> decodedTasks = jsonDecode(tasksJson);
        tasks = decodedTasks.map((task) => Task.fromJson(task)).toList();
      });
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String tasksJson =
        jsonEncode(tasks.map((task) => task.toJson()).toList());
    await prefs.setString(TASKS_KEY, tasksJson);
  }

  void _addTask(Task task) {
    setState(() {
      tasks.add(task);
      _saveTasks();
    });
  }

  void _removeTask(Task task) {
    setState(() {
      tasks.removeWhere((t) => t.id == task.id);
      _saveTasks();
    });
  }

  void _showDateTimePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    ).then((selectedDate) {
      if (selectedDate != null) {
        // Show time picker after date is selected
        showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        ).then((selectedTime) {
          if (selectedTime != null) {
            _showAddTaskDialog(selectedDate, selectedTime);
          }
        });
      }
    });
  }

  void _showAddTaskDialog(DateTime date, TimeOfDay time) {
    final TextEditingController taskController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: taskController,
              decoration: const InputDecoration(
                labelText: 'Task Description',
                hintText: 'Enter your task here',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Date: ${date.day}/${date.month}/${date.year}',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Time: ${time.format(context)}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (taskController.text.isNotEmpty) {
                final DateTime taskDateTime = DateTime(
                  date.year,
                  date.month,
                  date.day,
                  time.hour,
                  time.minute,
                );

                _addTask(Task(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: taskController.text,
                  dateTime: taskDateTime,
                  isCompleted: false,
                ));

                Navigator.pop(context);
              }
            },
            child: const Text('Add Task'),
          ),
        ],
      ),
    );
  }

  void _showBreathingExercises() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          itemCount: BreathingExercise.anxietyExercises.length,
          itemBuilder: (context, index) {
            final exercise = BreathingExercise.anxietyExercises[index];
            return ListTile(
              title: Text(exercise.name),
              subtitle: Text(exercise.description),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BreathingScreen(exercise: exercise),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${TimeOfDay.fromDateTime(dateTime).format(context)}';
  }

  void _toggleTaskCompletion(Task task) {
    setState(() {
      task.isCompleted = !task.isCompleted;
      _saveTasks();
    });
  }
}

class NotificationCard extends StatelessWidget {
  final String message;
  final String time;

  const NotificationCard({
    super.key,
    required this.message,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class BatteryIndicator extends StatelessWidget {
  final double batteryLevel;

  const BatteryIndicator({super.key, required this.batteryLevel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 20,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Stack(
        children: [
          Container(
            width: batteryLevel * 36,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: batteryLevel > 0.2 ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          Positioned(
            right: 2,
            top: 5,
            bottom: 5,
            child: Container(
              width: 2,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Task {
  final String id;
  final String title;
  final DateTime dateTime;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.dateTime,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'dateTime': dateTime.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      dateTime: DateTime.parse(json['dateTime']),
      isCompleted: json['isCompleted'],
    );
  }

  bool get isExpired => DateTime.now().isAfter(dateTime) && !isCompleted;
}

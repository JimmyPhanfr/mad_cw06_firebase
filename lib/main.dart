import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

final _formKey = GlobalKey<FormState>();

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final TextEditingController nameController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  void createTask(bool isCompleted, String date, String time, String name, String details) async {
    await FirebaseFirestore.instance.collection('list').add({
      "isCompleted" : isCompleted,
      "date" : date,
      "time" : time,
      "name" : name,
      "details" : details,
      // to implement later
      // "parent" : parent,
      // "children" : children
    });
  }

  void clearControllers() {
    dateController.clear();
    timeController.clear();
    nameController.clear();
    detailsController.clear();
  }

  Future<void> openAddTask(BuildContext context) async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: Text(
              "Add New Task",
              style: const TextStyle(color: Colors.black),
            ),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Name (required)",
                      hintText: "Give the task a name",
                      border: UnderlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: () {
                          nameController.clear();
                        },
                        icon: const Icon(Icons.clear),
                      ),
                    ),
                    validator: (name) => name!.isEmpty 
                      ? "Please provide a name"
                      : null,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  TextField(
                    controller: detailsController,
                    decoration: InputDecoration(
                      hintText: "Write a short description",
                      border: UnderlineInputBorder(),
                      labelText: "Details",
                      suffixIcon: IconButton(
                        onPressed: () {
                          detailsController.clear();
                        },
                        icon: const Icon(Icons.clear),
                      ),
                    ),
                  ),
                  TextField(
                    controller: dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Date",
                      hintText: "Set a date",
                      border: UnderlineInputBorder(),
                      suffixIcon: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              _selectDate(context);
                            },
                            icon: const Icon(Icons.calendar_month_outlined),
                          ),
                          IconButton(onPressed: () => dateController.clear(), icon: const Icon(Icons.clear)),
                        ],
                      ),
                    ),
                  ),
                  TextField(
                    controller: timeController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Time",
                      hintText: "Set a time",
                      border: UnderlineInputBorder(),
                      suffixIcon: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              _selectTime(context);
                            },
                            icon: const Icon(Icons.more_time_outlined),
                          ),
                          IconButton(onPressed: () => timeController.clear(), icon: const Icon(Icons.clear)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  clearControllers();
                  Navigator.pop(context);
                },
                child: Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    createTask(
                      false,
                      dateController.text,
                      timeController.text,
                      nameController.text,
                      detailsController.text,
                    );
                    clearControllers();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Task Added Successfully')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Background color
                  foregroundColor: Colors.white, // Text color
                ),
                child: Text("Add Task"),
              ),
            ],
          ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime.now(),
        lastDate: DateTime(2101)
      );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dateController.text = DateFormat('MM-dd-yyyy').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      initialEntryMode: TimePickerEntryMode.input,
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
        timeController.text = picked.format(context);
      });
    }
  }

  // Method to delete a task
  Future<void> deleteTask(String taskId) async {
    await _firestore.collection('list').doc(taskId).delete();
  }

  // Method to toggle task completion
  Future<void> toggleTaskCompletion(String taskId, bool currentStatus) async {
    await _firestore.collection('list').doc(taskId).update({
      'isCompleted': !currentStatus,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: StreamBuilder(
        stream: _firestore.collection('list').orderBy('date').orderBy('time').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final tasks = snapshot.data!.docs;

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              final taskId = task.id;
              final taskName = task['name'];
              final taskDetails = task['details'];
              final taskIsCompleted = task['isCompleted'];
              final taskDate = task['date'];
              final taskTime = task['time'];

              return Card(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: ListTile(
                  title: Text(taskName),
                  subtitle: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(taskDetails),
                      Text(taskDate),
                      Text(taskTime),
                    ],
                  ),
                  leading: Icon(
                    taskIsCompleted ? Icons.check_box : Icons.check_box_outline_blank,
                    color: taskIsCompleted ? Colors.green : Colors.grey,
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => deleteTask(taskId),
                  ),
                  onTap: () => toggleTaskCompletion(taskId, taskIsCompleted),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          openAddTask(context);
        }, 
        tooltip: "Create task",
        child: const Icon(Icons.add),
      ),
    );
  }
}

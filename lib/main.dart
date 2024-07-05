import 'package:flutter/material.dart';
import 'task.dart';
import 'task_card.dart';
import 'api_service.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do-App',
      theme: ThemeData(scaffoldBackgroundColor: const Color(0xFFF3F4F6)),
      home: const MyHomePage(title: 'To-Do List'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 5,
        lineLength: 120,
        colors: true,
        printEmojis: true),
  );
  List<Task> tasks = [];
  bool isLoading = false; // State for loading
  String errorMessage = '';
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  DateTime? selectedDate;
  String filter = 'all';
  String search = '';

  @override
  void initState() {
    super.initState();
    _fetchTasks();
    searchController.addListener(() {
      if (search != searchController.text) {
        setState(() {
          search = searchController.text;
          _fetchTasks(); // Refetch tasks with new search term
        });
      }
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    dateController.dispose();
    searchController.dispose(); // Dispose the search controller
    super.dispose();
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<void> _fetchTasks() async {
    setState(() {
      isLoading = true;
    });
    try {
      final fetchedTasks = await ApiService.fetchTasks(
        limit: 100,
        offset: 0,
        search: search,
        filter: filter,
      );
      setState(() {
        tasks = fetchedTasks;
        errorMessage = ''; // Clear previous error message
      });
    } catch (error, stackTrace) {
      _logger.e('Failed to load tasks', error: error, stackTrace: stackTrace);
      setState(() {
        errorMessage = 'Failed to load tasks: $error';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _addTask() async {
    if (_formKey.currentState!.validate()) {
      _updateLoadingState(true);
      final newTask = Task(
        id: DateTime.now().toString(),
        title: titleController.text,
        description: descriptionController.text,
        duedate: selectedDate,
        createdAt: DateTime.now(),
      );

      // Close the dialog before making the API call
      Navigator.of(context).pop();

      try {
        await ApiService.addTask(newTask);
        await _fetchTasks(); // Refresh the task list after adding.
        _showToast('Task added successfully');
        _resetFields(); // Reset the input fields
      } catch (error, stackTrace) {
        _logger.e('Failed to add task', error: error, stackTrace: stackTrace);
        _showSnackBar('Failed to add task: $error'); // Show error in SnackBar.
      } finally {
        _updateLoadingState(false);
      }
    }
  }

  void _resetFields() {
    setState(() {
      titleController.clear();
      descriptionController.clear();
      dateController.clear();
      selectedDate = null;
    });
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Helper methods to manage state updates
  void _updateLoadingState(bool isLoading) {
    setState(() => this.isLoading = isLoading);
  }

  void _updateErrorMessage(String message) {
    setState(() => errorMessage = message);
  }

  Future<void> _markTaskAsDone(Task task) async {
    setState(() {
      isLoading = true;
    });
    try {
      await ApiService.markTaskCompleted(task.id);
      await _fetchTasks(); // Refresh the task list
      _showToast('Task marked as done');
    } catch (error, stackTrace) {
      _logger.e('Failed to mark task as done',
          error: error, stackTrace: stackTrace);
      setState(() {
        errorMessage = 'Failed to mark task as done: $error';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _markTaskAsUndone(Task task) async {
    setState(() {
      isLoading = true;
    });
    try {
      await ApiService.markTaskUncompleted(task.id);
      await _fetchTasks(); // Refresh the task list
      _showToast('Task marked as undone');
    } catch (error, stackTrace) {
      _logger.e('Failed to mark task as undone',
          error: error, stackTrace: stackTrace);
      setState(() {
        errorMessage = 'Failed to mark task as undone: $error';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteTask(Task task) async {
    setState(() {
      isLoading = true;
    });
    try {
      await ApiService.deleteTask(task.id);
      await _fetchTasks(); // Refresh the task list
      _showToast('Task deleted successfully');
    } catch (error, stackTrace) {
      _logger.e('Failed to delete task', error: error, stackTrace: stackTrace);
      setState(() {
        errorMessage = 'Failed to delete task: $error';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  List<Task> getFilteredTasks() {
    return tasks.where((task) {
      if (filter == 'completed' && !task.isDone) return false;
      if (filter == 'incomplete' && task.isDone) return false;
      if (search.isNotEmpty &&
          !task.title.toLowerCase().contains(search.toLowerCase()))
        return false;
      return true;
    }).toList();
  }

  final _formKey = GlobalKey<FormState>();

  void _showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: EdgeInsets.all(16),
        title: Text('Add New Task',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Task Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the task title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Task Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: dateController,
                decoration: InputDecoration(
                  labelText: 'Due Date',
                  suffixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a due date';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              // Validate returns true if the form is valid, or false otherwise.
              if (_formKey.currentState!.validate()) {
                _addTask();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Submit', style: TextStyle(color: Colors.white)),
          ),
          SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F4F6),
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          labelText: 'Search tasks...',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            search = value;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    DropdownButton<String>(
                      value: filter,
                      items: [
                        DropdownMenuItem(value: 'all', child: Text('All')),
                        DropdownMenuItem(
                            value: 'completed', child: Text('Completed')),
                        DropdownMenuItem(
                            value: 'incomplete', child: Text('Incomplete')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          filter = value!;
                          _fetchTasks();
                        });
                      },
                    ),
                  ],
                ),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(top: 16, bottom: 16),
                  child: ElevatedButton(
                    onPressed: () => _showAddTaskDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child:
                        Text('Add Task', style: TextStyle(color: Colors.white)),
                  ),
                ),
                if (errorMessage.isNotEmpty)
                  Text(errorMessage, style: TextStyle(color: Colors.red))
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: getFilteredTasks().length,
                      itemBuilder: (context, index) {
                        return TaskCard(
                          task: getFilteredTasks()[index],
                          onComplete: () =>
                              _markTaskAsDone(getFilteredTasks()[index]),
                          onUncomplete: () =>
                              _markTaskAsUndone(getFilteredTasks()[index]),
                          onDelete: () =>
                              _deleteTask(getFilteredTasks()[index]),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black45,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        tooltip: 'Add Task',
        child: Icon(Icons.add),
      ),
    );
  }
}

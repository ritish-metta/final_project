import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/task_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final TaskService _taskService = TaskService();
  List<Task> tasks = [];
  int _selectedIndex = 0;
  late TabController _tabController;
  bool _showCompleted = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTasks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    setState(() => isLoading = true);
    try {
      final loadedTasks = await _taskService.getTasks();
      setState(() => tasks = loadedTasks);
    } catch (e) {
      _showErrorSnackBar('Failed to load tasks: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _addTask() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return _NewTaskSheet(
          onTaskAdded: (Task newTask) async {
            try {
              final createdTask = await _taskService.createTask(newTask);
              setState(() {
                tasks.add(createdTask);
              });
              _showSuccessSnackBar('Task added successfully');
            } catch (e) {
              _showErrorSnackBar('Failed to add task: $e');
            }
          },
        );
      },
    );
  }

  Future<void> _toggleCompletion(Task task) async {
    try {
      final updatedTask = Task(
        id: task.id,
        title: task.title,
        priority: task.priority,
        category: task.category,
        isCompleted: !task.isCompleted,
        dueDate: task.dueDate,
        notes: task.notes,
        subtasks: task.subtasks,
        isStarred: task.isStarred,
      );

      final result = await _taskService.updateTask(task.id!, updatedTask);
      setState(() {
        final index = tasks.indexWhere((t) => t.id == task.id);
        if (index != -1) tasks[index] = result;
      });
    } catch (e) {
      _showErrorSnackBar('Failed to update task: $e');
    }
  }

  Future<void> _toggleStarred(Task task) async {
    try {
      final updatedTask = Task(
        id: task.id,
        title: task.title,
        priority: task.priority,
        category: task.category,
        isCompleted: task.isCompleted,
        dueDate: task.dueDate,
        notes: task.notes,
        subtasks: task.subtasks,
        isStarred: !task.isStarred,
      );

      final result = await _taskService.updateTask(task.id!, updatedTask);
      setState(() {
        final index = tasks.indexWhere((t) => t.id == task.id);
        if (index != -1) tasks[index] = result;
      });
    } catch (e) {
      _showErrorSnackBar('Failed to update task: $e');
    }
  }

  Future<void> _deleteTask(Task task) async {
    try {
      await _taskService.deleteTask(task.id!);
      setState(() {
        tasks.removeWhere((t) => t.id == task.id);
      });
      _showSuccessSnackBar('Task deleted successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to delete task: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _getCurrentDate() {
    return DateFormat('EEEE, d MMMM').format(DateTime.now());
  }

  List<Task> _getFilteredTasks() {
    return tasks.where((task) {
      final matchesSearch = task.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCompletion = _showCompleted ? true : !task.isCompleted;
      return matchesSearch && matchesCompletion;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? const Color(0xFFF5F5F5)
          : const Color(0xFF1E1E1E),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildTaskCategories(),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildTaskList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTask,
        label: const Text('Add Task'),
        icon: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getCurrentDate(),
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Task Manager',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              _buildProgressIndicator(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final completedTasks = tasks.where((task) => task.isCompleted).length;
    final progress = tasks.isEmpty ? 0.0 : completedTasks / tasks.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${(progress * 100).toInt()}% Complete',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 100,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search tasks...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Theme.of(context).cardColor,
        ),
      ),
    );
  }

  Widget _buildTaskCategories() {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Today'),
          Tab(text: 'Upcoming'),
        ],
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).primaryColor,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Theme.of(context).brightness == Brightness.light
            ? Colors.black54
            : Colors.white54,
      ),
    );
  }

  Widget _buildTaskList() {
    final filteredTasks = _getFilteredTasks();
    
    return TabBarView(
      controller: _tabController,
      children: [
        _buildTaskListView(filteredTasks),
        _buildTaskListView(filteredTasks.where((task) =>
          task.dueDate?.day == DateTime.now().day).toList()),
        _buildTaskListView(filteredTasks.where((task) =>
          task.dueDate?.isAfter(DateTime.now()) ?? false).toList()),
      ],
    );
  }

  Widget _buildTaskListView(List<Task> taskList) {
    if (taskList.isEmpty) {
      return const Center(
        child: Text(
          'No tasks found',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: taskList.length,
      itemBuilder: (context, index) {
        return _buildTaskCard(taskList[index]);
      },
    );
  }

  Widget _buildTaskCard(Task task) {
    return Dismissible(
      key: Key(task.id ?? task.title),
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(15),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => _deleteTask(task),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: Checkbox(
            value: task.isCompleted,
            onChanged: (bool? value) => _toggleCompletion(task),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              color: task.isCompleted
                  ? Theme.of(context).disabledColor
                  : Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          subtitle: task.dueDate != null
              ? Text(
                  DateFormat('MMM d, y').format(task.dueDate!),
                  style: TextStyle(
                    color: task.dueDate!.isBefore(DateTime.now())
                        ? Colors.red
                        : Theme.of(context).textTheme.bodySmall?.color,
                  ),
                )
              : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: task.priority,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  task.isStarred ? Icons.star : Icons.star_border,
                  color: task.isStarred ? Colors.amber : null,
                ),
                onPressed: () => _toggleStarred(task),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => _onItemTapped(0),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _onItemTapped(1),
          ),
          const SizedBox(width: 48), // Space for FAB
          IconButton(
            icon: const Icon(Icons.checklist),
            onPressed: () {
              setState(() {
                _showCompleted = !_showCompleted;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _onItemTapped(3),
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

class _NewTaskSheet extends StatefulWidget {
  final Function(Task) onTaskAdded;

  const _NewTaskSheet({required this.onTaskAdded});

  @override
  _NewTaskSheetState createState() => _NewTaskSheetState();
}

class _NewTaskSheetState extends State<_NewTaskSheet> {
  final TextEditingController _titleController = TextEditingController();
  Color _selectedPriority = Colors.orange;
  bool _isStarred = false;
  DateTime? _selectedDate;
  bool isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitTask() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task title cannot be empty')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final newTask = Task(
        title: _titleController.text,
        priority: _selectedPriority,
        isStarred: _isStarred,
        dueDate: _selectedDate,
      );

      widget.onTaskAdded(newTask);
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create task: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Task Title',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Priority'),
              DropdownButton<Color>(
                value: _selectedPriority,
                items: [
                  DropdownMenuItem(
                    value: Colors.red,
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          color: Colors.red,
                          margin: const EdgeInsets.only(right: 8),
                        ),
                        const Text('High'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: Colors.orange,
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          color: Colors.orange,
                          margin: const EdgeInsets.only(right: 8),
                        ),
                        const Text('Medium'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: Colors.green,
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          color: Colors.green,
                          margin: const EdgeInsets.only(right: 8),
                        ),
                        const Text('Low'),
                      ],
                    ),
                  ),
                ],
                onChanged: (Color? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedPriority = newValue;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Due Date'),
              TextButton(
                onPressed: () => _selectDate(context),
                child: Text(
                  _selectedDate == null
                      ? 'Select Date'
                      : DateFormat('MMM d, y').format(_selectedDate!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Star Task'),
              Switch(
                value: _isStarred,
                onChanged: (bool value) {
                  setState(() {
                    _isStarred = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : _submitTask,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Add Task'),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
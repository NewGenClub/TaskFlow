
import 'package:material_ui/material_ui.dart';

import '../core/network/api_client.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import 'tasks/task_form_screen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ApiClient _apiClient;
  late final TaskService _taskService;
  late Future<List<Task>> _tasksFuture;

  static const Color primaryColor = Color(0xFF4F46E5);
  static const Color backgroundColor = Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();

    _apiClient = ApiClient();
    _taskService = TaskService(_apiClient);
    _loadTasks();
  }

  void _loadTasks() {
    _tasksFuture = _taskService.getTasks();
  }

  Future<void> _refreshTasks() async {
    setState(_loadTasks);
    await _tasksFuture;
  }

  @override
  void dispose() {
    _apiClient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
  onPressed: () async {
    final createdTask = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TaskFormScreen(),
      ),
    );

    if (!mounted) return;

    if (createdTask != null) {
      setState(_loadTasks);
    }
  },
  backgroundColor: const Color(0xFF4F46E5),
  foregroundColor: Colors.white,
  child: const Icon(Icons.add),
),
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: primaryColor, size: 28),
            SizedBox(width: 10),
            Text(
              'TaskFlow',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Task>>(
        future: _tasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }

          if (snapshot.hasError) {
            return _buildErrorView(snapshot.error.toString());
          }

          final tasks = snapshot.data ?? [];

          final totalTasks = tasks.length;
          final completedTasks =
              tasks.where((task) => task.status == 'completed').length;
          final pendingTasks = totalTasks - completedTasks;

          return RefreshIndicator(
            color: primaryColor,
            onRefresh: _refreshTasks,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                const Text(
                  'YOUR WORKSPACE',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Stay on top of things.',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Organize your day, one task at a time.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 26),

                // Task summary
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'Total',
                        totalTasks.toString(),
                        Icons.assignment_outlined,
                        const Color(0xFF4F46E5),
                        const Color(0xFFEEF2FF),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildSummaryCard(
                        'Pending',
                        pendingTasks.toString(),
                        Icons.pending_actions,
                        const Color(0xFFD97706),
                        const Color(0xFFFFF7ED),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildSummaryCard(
                        'Done',
                        completedTasks.toString(),
                        Icons.check_circle_outline,
                        const Color(0xFF059669),
                        const Color(0xFFECFDF5),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Task section heading
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Your Tasks',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      '$totalTasks tasks',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                if (tasks.isEmpty)
                  _buildEmptyState()
                else
                  ...tasks.map(_buildTaskCard),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(
    String label,
    String value,
    IconData icon,
    Color foreground,
    Color background,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: foreground, size: 19),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    final isCompleted = task.status == 'completed';

    final statusColor = isCompleted
        ? const Color(0xFF059669)
        : const Color(0xFFD97706);

    final statusBackground = isCompleted
        ? const Color(0xFFECFDF5)
        : const Color(0xFFFFF7ED);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isCompleted
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color: statusColor,
            size: 23,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    task.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusBackground,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isCompleted ? 'Completed' : 'Pending',
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: Color(0xFF94A3B8),
          ),
          SizedBox(height: 12),
          Text(
            'No tasks yet',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Your tasks will appear here.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 48,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 12),
            const Text(
              'Unable to load tasks',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(_loadTasks);
              },
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

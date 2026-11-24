
import 'package:material_ui/material_ui.dart';
import '../../core/network/api_client.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';

class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedStatus = 'pending';
  late final ApiClient _apiClient;
  late final TaskService _taskService;

  bool _isSubmitting = false;

  static const Color primaryColor = Color(0xFF4F46E5);

@override
void initState() {
  super.initState();

  _apiClient = ApiClient();
  _taskService = TaskService(_apiClient);
}

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _apiClient.dispose();
    super.dispose();
  }

  Future<void> _createTask() async {
  if (!_formKey.currentState!.validate() || _isSubmitting) {
    return;
  }

  setState(() {
    _isSubmitting = true;
  });

  final task = Task(
    title: _titleController.text.trim(),
    description: _descriptionController.text.trim(),
    status: _selectedStatus,
  );

  try {
    final createdTask = await _taskService.createTask(task);

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    Navigator.pop(context, createdTask);
  } catch (e) {
    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to create task: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Create Task',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF8FAFC),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Create something great.',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add the details below to organize your work.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 30),

            // Task title
            const Text(
              'Task title *',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _titleController,
              maxLength: 255,
              decoration: const InputDecoration(
                hintText: 'e.g. Complete project documentation',
                prefixIcon: Icon(Icons.task_alt),
                counterText: '',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a task title';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Description
            const Text(
              'Description',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Add more details about this task...',
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 24),

            // Status
            const Text(
              'Task status',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  _buildStatusOption('pending', 'Pending'),
                  _buildStatusOption('completed', 'Completed'),
                ],
              ),
            ),

            const SizedBox(height: 36),

            // Save button
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _createTask,
                icon: _isSubmitting
                    ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                    ),
                    )
                    : const Icon(Icons.add),
                label: Text(
                    _isSubmitting ? 'Creating...' : 'Create Task',
                    style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOption(String value, String label) {
    final isSelected = _selectedStatus == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedStatus = value;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? primaryColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : const Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

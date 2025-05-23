import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/patient.dart';
import 'add_patient_screen.dart';
import 'patient_detail_screen.dart';
import 'login_screen.dart';
import '../helpers/database_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Patient> _patients = [];
  final TextEditingController _searchController = TextEditingController();
  List<Patient> _filteredPatients = [];
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Filter
  String _selectedFilter = 'Hari'; // Semua, Hari, Minggu, Bulan
  int _filteredCount = 0;
  final Map<String, DateTime> _lastVisitMap = {};

  @override
  void initState() {
    super.initState();
    _loadPatients();
    _searchController.addListener(_filterPatients);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPatients() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    List<Patient> patients;
    final now = DateTime.now();
    if (_selectedFilter == 'Hari') {
      final start = DateTime(now.year, now.month, now.day);
      final end = start
          .add(const Duration(days: 1))
          .subtract(const Duration(milliseconds: 1));
      patients = await _dbHelper.getPatientsByDateRange(start, end, userId);
    } else if (_selectedFilter == 'Minggu') {
      final start = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: now.weekday - 1));
      final end = start
          .add(const Duration(days: 7))
          .subtract(const Duration(milliseconds: 1));
      patients = await _dbHelper.getPatientsByDateRange(start, end, userId);
    } else if (_selectedFilter == 'Bulan') {
      final start = DateTime(now.year, now.month, 1);
      final end = DateTime(now.year, now.month + 1, 1)
          .subtract(const Duration(milliseconds: 1));
      patients = await _dbHelper.getPatientsByDateRange(start, end, userId);
    } else {
      // Semua
      patients = await _dbHelper.getAllPatients(userId);
    }
    // Ambil last visit untuk setiap pasien
    _lastVisitMap.clear();
    for (final patient in patients) {
      final lastVisit =
          await _dbHelper.getLastVisitDate(patient.id, patient.createdAt);
      _lastVisitMap[patient.id] = lastVisit;
    }
    setState(() {
      _patients.clear();
      _patients.addAll(patients);
      _filteredPatients = _patients;
      _filteredCount = _patients.length;
    });
  }

  void _onFilterChanged(String filter) async {
    setState(() {
      _selectedFilter = filter;
    });
    await _loadPatients();
  }

  void _filterPatients() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredPatients = _patients;
      } else {
        _filteredPatients = _patients.where((patient) {
          return patient.fullName.toLowerCase().contains(query) ||
              patient.id.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  String _getInitial() {
    if (_currentUser?.email != null && _currentUser!.email!.isNotEmpty) {
      return _currentUser.email![0].toUpperCase();
    }
    return '?';
  }

  Future<void> _handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to logout. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'DELETE',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _currentUser?.delete();
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete account. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _addPatient() async {
    final result = await Navigator.push<Patient>(
      context,
      MaterialPageRoute(builder: (context) => const AddPatientScreen()),
    );

    if (result != null) {
      await _dbHelper.insertPatient(result);
      await _loadPatients();
    }
  }

  Future<void> _viewPatientDetails(Patient patient) async {
    final updatedPatient = await Navigator.push<Patient>(
      context,
      MaterialPageRoute(
        builder: (context) => PatientDetailScreen(patient: patient),
      ),
    );

    if (updatedPatient != null) {
      await _dbHelper.updatePatient(updatedPatient);
      await _loadPatients();
    } else {
      // Patient was deleted
      await _dbHelper.deletePatient(patient.id);
      await _loadPatients();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'OctaKlinik',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        actions: [
          PopupMenuButton<void>(
            offset: const Offset(0, 50),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
              child: CircleAvatar(
                backgroundColor: const Color(0xFF8BA07E),
                child: Text(
                  _getInitial(),
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                ),
              ),
            ),
            itemBuilder: (context) => <PopupMenuEntry<void>>[
              PopupMenuItem<void>(
                enabled: false,
                child: Text(
                  _currentUser?.email ?? 'No email',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<void>(
                onTap: _handleLogout,
                child: const Row(
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
              PopupMenuItem<void>(
                onTap: _handleDeleteAccount,
                child: const Row(
                  children: [
                    Icon(Icons.delete_forever, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Delete Account', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search by name or ID',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Filter toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildFilterButton('Semua'),
                const SizedBox(width: 8),
                _buildFilterButton('Hari'),
                const SizedBox(width: 8),
                _buildFilterButton('Minggu'),
                const SizedBox(width: 8),
                _buildFilterButton('Bulan'),
              ],
            ),
            const SizedBox(height: 8),
            Text('Total pasien: $_filteredCount',
                style: const TextStyle(fontWeight: FontWeight.w500)),
            if (_patients.isNotEmpty) ...[
              const Text(
                'Latest patient',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredPatients.length,
                  itemBuilder: (context, index) {
                    final patient = _filteredPatients[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () => _viewPatientDetails(patient),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                patient.fullName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${patient.id} • ${patient.age}, ${patient.gender}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Last visit: ${_formatDate(_lastVisitMap[patient.id] ?? patient.createdAt)}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ] else
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'No patient records yet.',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start by adding your first patient.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.black54,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: ElevatedButton.icon(
        onPressed: _addPatient,
        icon: const Icon(Icons.add),
        label: const Text('Add Patient'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8BA07E),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildFilterButton(String label) {
    final isSelected = _selectedFilter == label;
    return ElevatedButton(
      onPressed: () => _onFilterChanged(label),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isSelected ? const Color(0xFF8BA07E) : Colors.grey[300],
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: isSelected ? 2 : 0,
      ),
      child: Text(label),
    );
  }
}

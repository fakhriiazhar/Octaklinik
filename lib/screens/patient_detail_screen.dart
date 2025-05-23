import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../models/visit.dart';
import 'edit_patient_screen.dart';
import 'new_visit_screen.dart';
import 'visit_detail_screen.dart';
import '../helpers/database_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PatientDetailScreen extends StatefulWidget {
  final Patient patient;

  const PatientDetailScreen({
    super.key,
    required this.patient,
  });

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  late Patient _patient;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _patient = widget.patient;
    _loadVisits();
  }

  Future<void> _loadVisits() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final visits = await _dbHelper.getVisits(_patient.id, userId);
    setState(() {
      _patient = _patient.copyWith(visits: visits);
    });
  }

  Future<void> _addNewVisit() async {
    final result = await Navigator.push<Visit>(
      context,
      MaterialPageRoute(
        builder: (context) => const NewVisitScreen(),
      ),
    );

    if (result != null) {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final visitWithUser = result.copyWith(userId: userId);
      await _dbHelper.insertVisit(visitWithUser, _patient.id);
      await _loadVisits();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('New visit has been recorded'),
            backgroundColor: Color(0xFF2D2D2D),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _editPatient() async {
    final updatedPatient = await Navigator.push<Patient>(
      context,
      MaterialPageRoute(
        builder: (context) => EditPatientScreen(patient: _patient),
      ),
    );

    if (updatedPatient != null) {
      await _dbHelper.updatePatient(updatedPatient);
      setState(() {
        _patient = updatedPatient;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Patient data has been updated'),
            backgroundColor: Color(0xFF2D2D2D),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _deletePatient() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Patient'),
        content: const Text(
            'Are you sure you want to delete this patient? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _dbHelper.deletePatient(_patient.id);
      if (!mounted) return;
      Navigator.pop(context, null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Patient has been deleted'),
            backgroundColor: Color(0xFF2D2D2D),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _viewVisitDetails(Visit visit) async {
    final updatedVisit = await Navigator.push<Visit>(
      context,
      MaterialPageRoute(
        builder: (context) => VisitDetailScreen(
          patient: _patient,
          visit: visit,
        ),
      ),
    );

    if (updatedVisit != null) {
      await _dbHelper.updateVisit(updatedVisit);
      await _loadVisits();
    } else {
      // Visit was deleted
      await _dbHelper.deleteVisit(visit.id);
      await _loadVisits();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, _patient),
        ),
        title: const Text(
          'Patient details',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _patient.fullName,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_patient.id} • ${_patient.age}, ${_patient.gender}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (value) {
                              switch (value) {
                                case 'edit':
                                  _editPatient();
                                  break;
                                case 'delete':
                                  _deletePatient();
                                  break;
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Delete',
                                        style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.phone, size: 20, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(_patient.phoneNumber),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 20, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(_patient.address),
                        ],
                      ),
                      if (_patient.medicalHistory != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.history,
                                size: 20, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(_patient.medicalHistory!),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Visit history',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _patient.visits.length,
                itemBuilder: (context, index) {
                  final visit = _patient.visits[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () => _viewVisitDetails(visit),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Complaint: ${visit.chiefComplaint}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _formatDate(visit.visitDate),
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
            ],
          ),
        ),
      ),
      floatingActionButton: ElevatedButton.icon(
        onPressed: _addNewVisit,
        icon: const Icon(Icons.add),
        label: const Text('New Visit'),
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
}

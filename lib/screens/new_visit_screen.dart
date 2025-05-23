import 'package:flutter/material.dart';
import '../models/visit.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NewVisitScreen extends StatefulWidget {
  final Visit? visitToEdit;

  const NewVisitScreen({
    super.key,
    this.visitToEdit,
  });

  @override
  State<NewVisitScreen> createState() => _NewVisitScreenState();
}

class _NewVisitScreenState extends State<NewVisitScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _complaintController;
  late TextEditingController _diagnosisController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _complaintController =
        TextEditingController(text: widget.visitToEdit?.chiefComplaint ?? '');
    _diagnosisController =
        TextEditingController(text: widget.visitToEdit?.diagnosis ?? '');
    _notesController =
        TextEditingController(text: widget.visitToEdit?.doctorNotes ?? '');
  }

  @override
  void dispose() {
    _complaintController.dispose();
    _diagnosisController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveVisit() {
    if (_formKey.currentState!.validate()) {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final visit = Visit(
        id: widget.visitToEdit?.id,
        chiefComplaint: _complaintController.text,
        diagnosis: _diagnosisController.text,
        doctorNotes:
            _notesController.text.isEmpty ? null : _notesController.text,
        visitDate: widget.visitToEdit?.visitDate ?? DateTime.now(),
        userId: userId,
      );

      Navigator.pop(context, visit);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.visitToEdit != null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Edit Visit' : 'New Visit',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _complaintController,
                decoration: const InputDecoration(
                  labelText: 'Chief Complaint',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter chief complaint';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _diagnosisController,
                decoration: const InputDecoration(
                  labelText: 'Diagnosis',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter diagnosis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: "Doctor's Notes (optional)",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveVisit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8BA07E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(isEditing ? 'Update' : 'Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
